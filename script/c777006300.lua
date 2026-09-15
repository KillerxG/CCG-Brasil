--Advanced Crystal Beast Rainbow Dark Dragon
--Scripted by Codex
local s,id=GetID()
function s.initial_effect(c)
	--Fusion materials: 2 "Advanced Crystal Beast" monsters
	c:EnableReviveLimit()
	Fusion.AddProcMixRep(c,true,true,
		aux.FilterBoolFunctionEx(Card.IsSetCard,SET_ADVANCED_CRYSTAL_BEAST),2,2)

	--Must first be either Fusion Summoned, or Special Summoned by its own procedure
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)

	--Special Summon from the Extra Deck by destroying 2 or 3
	--face-up "Advanced Crystal Beast" cards you control
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	--If Special Summoned: Add 1 "Ultimate Crystal" monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)

	--"Advanced Dark" you control is unaffected by
	--your opponent's card effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_SZONE,0)
	e4:SetTarget(s.imtg)
	e4:SetValue(s.imval)
	c:RegisterEffect(e4)

	--Place this destroyed card in the Spell & Trap Zone
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e5:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e5:SetCondition(s.repcon)
	e5:SetOperation(s.repop)
	c:RegisterEffect(e5)

	--Send this Continuous Spell to the GY and Special Summon
	--"Rainbow Dark Dragon"
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_TOGRAVE|CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCountLimit(1,id)
	e6:SetCondition(s.rdcon)
	e6:SetTarget(s.rdtg)
	e6:SetOperation(s.rdop)
	c:RegisterEffect(e6)
end

s.listed_names={CARD_ADVANCED_DARK,79407975}
s.listed_series={SET_ADVANCED_CRYSTAL_BEAST,SET_ULTIMATE_CRYSTAL}

--Alternative Special Summon procedure
function s.spfilter(c)
	return c:IsFaceup()
		and c:IsSetCard(SET_ADVANCED_CRYSTAL_BEAST)
		and c:IsDestructable()
end

function s.spcheck(sg,tp,sc)
	return Duel.GetLocationCountFromEx(tp,tp,sg,sc)>0
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD,0,nil)
	return aux.SelectUnselectGroup(g,e,tp,2,3,
		function(sg) return s.spcheck(sg,tp,c) end,0)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,3,
		function(g) return s.spcheck(g,tp,c) end,
		1,tp,HINTMSG_DESTROY)

	if not sg or #sg==0 then
		return false
	end

	sg:KeepAlive()
	e:SetLabelObject(sg)
	return true
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end

	Duel.Destroy(g,REASON_COST)
	g:DeleteGroup()
end

--Search an "Ultimate Crystal" monster
function s.thfilter(c)
	return c:IsMonster()
		and c:IsSetCard(SET_ULTIMATE_CRYSTAL)
		and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	end

	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,
		LOCATION_DECK|LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(
		tp,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)

	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--Protect "Advanced Dark"
function s.imtg(e,c)
	return c:IsFaceup() and c:IsCode(CARD_ADVANCED_DARK)
end

function s.imval(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

--Place this card as a Continuous Spell
function s.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup()
		and c:IsLocation(LOCATION_MZONE)
		and c:IsReason(REASON_DESTROY)
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
	c:RegisterEffect(e1)

	Duel.RaiseEvent(c,EVENT_CUSTOM+CARD_CRYSTAL_TREE,e,0,tp,0,0)
end

--Quick Effect while treated as a Continuous Spell
function s.rdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsType(TYPE_CONTINUOUS)
end

function s.rdfilter(c,e,tp)
	return c:IsCode(79407975)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end

function s.rdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToGrave()
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(
				aux.NecroValleyFilter(s.rdfilter),
				tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,
				0,1,nil,e,tp)
	end

	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,1,tp,LOCATION_SZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,
		LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
end

function s.rdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	if Duel.SendtoGrave(c,REASON_EFFECT)==0
		or not c:IsLocation(LOCATION_GRAVE) then
		return
	end

	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(
		tp,aux.NecroValleyFilter(s.rdfilter),
		tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,
		0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end

	if Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)>0 then
		--The Summoned monster cannot be destroyed by card effects
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetOwnerPlayer(tp)
		tc:RegisterEffect(e1)
	end
end