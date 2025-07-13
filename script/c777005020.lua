--Everlasting Soul Preassure
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--(2)Negate monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.negmon)
	e2:SetOperation(s.negmop)
	c:RegisterEffect(e2)
	--(3)Negate S/T
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.negstcon)
	e3:SetOperation(s.negstop)
	c:RegisterEffect(e3)
	--(4)Return Synchro to Extra, then Special Summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.gysptg)
	e4:SetOperation(s.gyspop)
	c:RegisterEffect(e4)
	--(5)Set itself but banish it when it leaves the field
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e5:SetCountLimit(1,id+1)
	e5:SetCost(s.setcost)
	e5:SetCondition(s.setcon)
	e5:SetTarget(s.settg)
	e5:SetOperation(s.setop)
	c:RegisterEffect(e5)
end
--(2)Negate monster
function s.cmfilter(c,seq,p)
	return c:IsFaceup() and c:IsCode(777004920) and c:IsColumn(seq,p,LOCATION_MZONE)
end
function s.negmon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsMonsterEffect() then return false end
	local rc=re:GetHandler()
	local p,loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	return loc==LOCATION_MZONE and Duel.IsExistingMatchingCard(s.cmfilter,tp,LOCATION_MZONE,0,1,nil,seq,p)
end
function s.negmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
--(3)Negate S/T
function s.cstfilter(c,seq,p)
	return c:IsFaceup() and c:IsCode(777004920) and c:IsColumn(seq,p,LOCATION_SZONE)
end
function s.negstcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not (re:IsSpellEffect() or re:IsTrapEffect()) then return false end
	local rc=re:GetHandler()
	local p,loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and (loc&LOCATION_SZONE==0 or rc:IsControler(1-p)) then
		if rc:IsLocation(LOCATION_SZONE) and rc:IsControler(p) then
			seq=rc:GetSequence()
			loc=LOCATION_SZONE
		else
			seq=rc:GetPreviousSequence()
			loc=rc:GetPreviousLocation()
		end
	end
	return loc&LOCATION_SZONE==LOCATION_SZONE and Duel.IsExistingMatchingCard(s.cstfilter,tp,LOCATION_MZONE,0,1,nil,seq,p)
end
function s.negstop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
--(4)Return Synchro to Extra, then Special Summon
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra()
end
function s.gyspfilter(c,e,tp)
	return c:IsSetCard(0x258) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.scfilter(c)
	return c:IsSynchroSummonable(nil)
end
function s.gysptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.gyspop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	if Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)~=0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.IsExistingMatchingCard(s.gyspfilter,tp,LOCATION_GRAVE,0,2,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.gyspfilter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
		if #g>1 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
		local sg=Duel.GetMatchingGroup(s.scfilter,tp,LOCATION_EXTRA,0,nil)
	if #sg==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=sg:Select(tp,1,1,nil):GetFirst()
	if sc then
		Duel.SynchroSummon(tp,sc,nil)
	end
	end
end
--(5)Set itself but banish it when it leaves the field
function s.thcfilter(c,tp)
	return c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thcfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,e:GetHandler(),tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.thcfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,e:GetHandler(),tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,777004920),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() and Duel.SSet(tp,c)>0 then
		--Banish it if it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end