--Zwei, Resonant Ex Puppeteer
--Scripted by Misaki
local s,id=GetID()
function s.initial_effect(c)
	c:AddSetcodesRule(id,true,0x314c)--Loli Arch
    --Link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,3,s.lcheck)
	--(1)Add Counter (self)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	--(2)Banish a Card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.retcon)
	e2:SetCost(s.retcost)
	e2:SetTarget(s.rettg)
	e2:SetOperation(s.retop)
	c:RegisterEffect(e2)
end
s.counter_list={0x1320}
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0x320,lc,sumtype,tp)
end
--(1)Add Counter (self)
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and rp==tp then
        c:AddCounter(0x1320,1)
	end
end
--(2)Banish a Card
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER)
end
function s.accostfilter(c)
  return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK) and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA)) and c:IsAbleToRemoveAsCost()
end
function s.retcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsCanRemoveCounter(tp,1,0,0x1320,3,REASON_COST)
    local b2=Duel.IsExistingMatchingCard(s.accostfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil)
    if chk==0 then return b1 or b2 end
    if b1 and ((not b2) or Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
	Duel.RemoveCounter(tp,1,0,0x1320,3,REASON_COST)
    else
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.accostfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
  end
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,LOCATION_ONFIELD,LOCATION_ONFIELD)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end