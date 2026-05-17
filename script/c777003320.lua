-- Captain of Oceanic Storm - Caroline
-- Programado por Gemini
local s,id=GetID()
function s.initial_effect(c)
	-- Nomi Summoning Restriction: Cannot be Normal Summoned/Set.
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)

	-- Restrict baseline Special Summons globally
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)

	-- Must be Special Summoned by having 3 or more "Oceanic Storm" monsters with different names
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	c:RegisterEffect(e2)

	-- Cannot be targeted by opponent's card effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)

	-- While LP is lower: Cannot be destroyed by opponent's card effects
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetValue(aux.indoval)
	c:RegisterEffect(e4)

	-- Opponent must pay 600 LP to activate cards or effects
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_ACTIVATE_COST)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(0,1)
	e5:SetCost(s.taxchk)
	e5:SetOperation(s.taxop)
	c:RegisterEffect(e5)

	-- (Quick Effect): Pay 500 LP, target 1 monster; take control, becomes WATER Zombie
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_CONTROL)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,id)
	e6:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e6:SetCost(s.qecost)
	e6:SetTarget(s.qetg)
	e6:SetOperation(s.qeop)
	c:RegisterEffect(e6)

	-- During the End Phase: Pay 500 LP, target 1 Trap; add to hand or Set
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,1))
	e7:SetCategory(CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_PHASE+PHASE_END)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1,id+1)
	e7:SetCost(s.qecost) -- Uses the same cost function as the Quick Effect
	e7:SetTarget(s.eptg)
	e7:SetOperation(s.epop)
	c:RegisterEffect(e7)
end

-- Inherent Special Summon Validator
function s.spfilter(c)
	return c:IsSetCard(0x312) and c:IsType(TYPE_MONSTER) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	return g:GetClassCount(Card.GetCode)>=3
end

-- Taxation Interception Logic
function s.taxchk(e,te,tp)
	return Duel.CheckLPCost(tp,600)
end
function s.taxop(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp,600)
end

-- Standard LP Cost Execution Function
function s.qecost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,600) end
	Duel.PayLPCost(tp,600)
end

-- Control Manipulation Validators and Operators
function s.ctlfilter(c)
	return c:IsControlerCanBeChanged()
end
function s.qetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.ctlfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.ctlfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.ctlfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.qeop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp) then
		local c=e:GetHandler()
		-- Mutation: Attribute
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(ATTRIBUTE_WATER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- Mutation: Race
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RACE)
		e2:SetValue(RACE_ZOMBIE)
		tc:RegisterEffect(e2)
	end
end

-- Recursion Validators and Operators
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x312) and c:IsSpellTrap() and (c:IsAbleToHand() or c:IsSSetable())
end
function s.eptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
function s.epop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if tc:IsAbleToHand() and (not tc:IsSSetable() or Duel.SelectOption(tp,aux.Stringid(id,2),1153)==0) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		else
			Duel.SSet(tp,tc)
		end
	end
end