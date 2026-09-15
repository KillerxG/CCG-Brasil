--Ultimate Crystal Rainbow Dark Dragon Overdrive
--Scripted by Codex
local s,id=GetID()
s.copy_state={}

function s.initial_effect(c)
	c:EnableReviveLimit()

	--1 DARK "Ultimate Crystal" monster
	--+ 7 "Advanced Crystal Beast" monsters
	Fusion.AddProcMixRep(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_ADVANCED_CRYSTAL_BEAST),7,7,s.ucfilter)
	--Special Summon by banishing the above materials
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.contactlim,s.contactcon)

	--Register that an "Ultimate Crystal" monster
	--was Special Summoned during this Duel
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end)

	--Cannot be Special Summoned by other ways
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(
		EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)

	--Gain the effects of all face-up
	--"Advanced Crystal Beast" monsters you control
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.copyop)
	c:RegisterEffect(e1)

	--Destroy an "Advanced Crystal Beast" card instead
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.reptg)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)

	--Place an "Advanced Crystal Beast", negate,
	--then banish the activated card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_NEGATE|CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(
		EFFECT_FLAG_CARD_TARGET|
		EFFECT_FLAG_DAMAGE_STEP|
		EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.negcon)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end

s.listed_names={CARD_ADVANCED_DARK}
s.listed_series={
	SET_ULTIMATE_CRYSTAL,
	SET_ADVANCED_CRYSTAL_BEAST
}
s.material_setcode={
	SET_ULTIMATE_CRYSTAL,
	SET_ADVANCED_CRYSTAL_BEAST
}

--Fusion Material filter
function s.ucfilter(c,fc,sumtype,tp)
	return c:IsSetCard(
			SET_ULTIMATE_CRYSTAL,fc,sumtype,tp)
		and c:IsAttribute(
			ATTRIBUTE_DARK,fc,sumtype,tp)
end

--Contact Fusion procedure
function s.contactfil(tp)
	local loc=Duel.IsPlayerAffectedByEffect(
		tp,CARD_SPIRIT_ELIMINATION)
		and LOCATION_MZONE
		or LOCATION_MZONE|LOCATION_GRAVE

	return Duel.GetMatchingGroup(
		Card.IsAbleToRemoveAsCost,tp,loc,0,nil)
end

function s.contactop(g)
	Duel.Remove(
		g,POS_FACEUP,REASON_COST|REASON_MATERIAL)
end

function s.contactlim(e)
	return e:GetHandler():IsLocation(LOCATION_EXTRA)
end

function s.contactcon(tp)
	return Duel.GetFlagEffect(tp,id)>0
end

--Register an "Ultimate Crystal" Special Summon
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	for tc in eg:Iter() do
		if tc:IsFaceup()
			and tc:IsSetCard(SET_ULTIMATE_CRYSTAL) then
			Duel.RegisterFlagEffect(
				tc:GetSummonPlayer(),id,0,0,0)
		end
	end
end

--Copy effects
function s.copyfilter(c)
	return c:IsFaceup()	and c:IsSetCard(SET_ADVANCED_CRYSTAL_BEAST)
end

function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	local has_advanced_dark=
		Duel.IsEnvironment(CARD_ADVANCED_DARK,tp)

	local codes={}
	local registered_codes={}
	local g=Duel.GetMatchingGroup(
		s.copyfilter,tp,LOCATION_ONFIELD,0,c)

	if has_advanced_dark then
		for tc in g:Iter() do
			local code=tc:GetOriginalCode()
			if not registered_codes[code] then
				registered_codes[code]=true
				table.insert(codes,code)
			end
		end
	end

	table.sort(codes)

	local key=(has_advanced_dark and "1:" or "0:")
		..table.concat(codes,",")
	local previous=s.copy_state[fid]

	--Do nothing if the copied effects have not changed
	if previous and previous.key==key then
		return
	end

	--Remove effects that should no longer be copied
	if previous then
		for _,cid in ipairs(previous.copy_ids) do
			c:ResetEffect(cid,RESET_COPY)
		end
	end

	local state={
		key=key,
		copy_ids={}
	}
	s.copy_state[fid]=state

	if not has_advanced_dark then
		return
	end

	--Copy each different monster's effects
	for _,code in ipairs(codes) do
		local cid=c:CopyEffect(
			code,RESET_EVENT|RESETS_STANDARD,1)
		if cid and cid~=0 then
			table.insert(state.copy_ids,cid)
		end
	end
end

--Destruction replacement
function s.repfilter(c,e)
	return c:IsFaceup()
		and c:IsSetCard(SET_ADVANCED_CRYSTAL_BEAST)
		and c:IsDestructable(e)
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return not c:IsReason(REASON_REPLACE)
			and (c:IsReason(REASON_BATTLE)
				or c:IsReason(REASON_EFFECT))
			and Duel.IsExistingMatchingCard(
				s.repfilter,tp,LOCATION_ONFIELD,
				0,1,c,e)
	end

	if not Duel.SelectEffectYesNo(tp,c,96) then
		return false
	end

	Duel.Hint(
		HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
	local g=Duel.SelectMatchingCard(
		tp,s.repfilter,tp,LOCATION_ONFIELD,
		0,1,1,c,e)
	local tc=g:GetFirst()

	if not tc then
		return false
	end

	e:SetLabelObject(tc)
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,true)
	return true
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc then return end

	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(
		tc,REASON_EFFECT|REASON_REPLACE)
end

--Negation effect
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(
		STATUS_BATTLE_DESTROYED) then
		return false
	end

	return Duel.IsChainNegatable(ev)
		and (re:IsSpellTrapEffect()
			or re:IsMonsterEffect())
end

function s.placefilter(c,e)
	return c:IsMonster()
		and c:IsSetCard(SET_ADVANCED_CRYSTAL_BEAST)
		and (not c:IsLocation(LOCATION_REMOVED)
			or c:IsFaceup())
		and not c:IsForbidden()
		and c:IsCanBeEffectTarget(e)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(tp)
			and chkc:IsLocation(
				LOCATION_GRAVE|LOCATION_REMOVED)
			and s.placefilter(chkc,e)
	end

	if chk==0 then
		return Duel.GetLocationCount(
				tp,LOCATION_SZONE)>0
			and Duel.IsExistingTarget(
				aux.NecroValleyFilter(s.placefilter),
				tp,
				LOCATION_GRAVE|LOCATION_REMOVED,
				0,1,nil,e)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectTarget(
		tp,aux.NecroValleyFilter(s.placefilter),
		tp,LOCATION_GRAVE|LOCATION_REMOVED,
		0,1,1,nil,e)

	Duel.SetOperationInfo(
		0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(
		0,CATEGORY_REMOVE,eg,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc
		or not tc:IsRelateToEffect(e)
		or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then
		return
	end

	if not Duel.MoveToField(
		tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		return
	end

	--Treat the placed monster as a Continuous Spell
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
	e1:SetReset(
		RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
	tc:RegisterEffect(e1)

	Duel.RaiseEvent(
		tc,EVENT_CUSTOM+CARD_CRYSTAL_TREE,
		e,0,tp,0,0)

	--Negate the activation, then banish that card
	if Duel.NegateActivation(ev)
		and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end