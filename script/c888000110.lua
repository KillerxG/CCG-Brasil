--Zwei, Murderous Ex Puppeteer
--Scripted by Misaki
local s,id=GetID()
function s.initial_effect(c)
	c:AddSetcodesRule(id,true,0x314c)--Loli Arch
    --Link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)
	--(1)Add Counter (self)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	--(2)Place Pendulum Monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.pcost)
	e2:SetTarget(s.pctg)
	e2:SetOperation(s.pcop)
	c:RegisterEffect(e2)
end
s.listed_series={0x320}
s.counter_list={0x1320}
function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(0x320,lc,sumtype,tp) and not c:IsType(TYPE_LINK,lc,sumtype,tp)
end
--(1)Add Counter (self)
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and rp==tp then
        c:AddCounter(0x1320,1)
	end
end
--(2)Place Pendulum Monster
function s.pcfilter(c)
	return c:IsSetCard(0x320) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.accostfilter(c)
  return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK) and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA)) and c:IsAbleToRemoveAsCost()
end
function s.pcost(e,tp,eg,ep,ev,re,r,rp,chk)
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
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.pcfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
