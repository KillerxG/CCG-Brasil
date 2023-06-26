--Arknight - Skadi
--Scripted by 
local s,id=GetID()
local RACES=RACE_ALL
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:EnableCounterPermit(0x1296)
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,nil,s.matcheck)
	--(1)Counter
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.ctcon)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	--(2)Negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCountLimit(1,id)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	--(3)Immune
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.econ)
	e3:SetValue(s.efilter1)
	c:RegisterEffect(e3)
end
--Link Summon
function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0x289,lc,sumtype,tp)
end
--(1)Counter
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.ctfilter(c)
	return c:IsRace(RACE_ALL) and c:IsSetCard(0x289)
end
local function getcount(tp)
	local totrace=0
	Duel.GetMatchingGroup(s.ctfilter,tp,LOCATION_GRAVE,0,nil):ForEach(function(c) totrace=totrace|c:GetRace() end)
	totrace=totrace&(RACES)
	local ct=0
	while totrace~=0 do
		if totrace&0x1~=0 then ct=ct+1 end
		totrace=totrace>>1
	end
	return ct
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=getcount(tp)
	if chk==0 then return ct>0 and e:GetHandler():IsCanAddCounter(0x1296,ct) end
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	c:AddCounter(0x1296,getcount(tp))
end
--(2)Negate
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ep==tp or c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) and e:GetHandler():IsCanRemoveCounter(tp,0x1296,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1296,1,REASON_COST)
	Duel.PayLPCost(tp,1000)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and Duel.Destroy(rc,REASON_EFFECT)~=0 and c:IsFaceup() then
		local dmg=c:GetCounter(0x1296)*500
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(dmg)
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,dmg)
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Recover(p,d,REASON_EFFECT)
	end
end
--(3)Immune
function s.econ(e)
	return e:GetHandler():GetCounter(0x1296)>0
end
function s.efilter1(e,te)
	return te:GetOwner()~=e:GetOwner()
end