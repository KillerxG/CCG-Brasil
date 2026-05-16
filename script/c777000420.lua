--SAO The Battle Approaches
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Can only control 1
	c:SetUniqueOnField(1,0,id)
    --(1)Activate + Place SAO Counter
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.pcttg)
	c:RegisterEffect(e1)
	--(2)Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
 --(1)Activate + Place SAO Counter
 function s.pcttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return true end
  local tc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
  if tc and tc:IsFaceup() and tc:IsSetCard(0x282)
  and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
    Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))
    e:SetCategory(CATEGORY_COUNTER)
    e:SetOperation(s.pctop)
  else
    e:SetCategory(0)
    e:SetProperty(0)
    e:SetOperation(nil)
  end
end
function s.pctop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  local tc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
  if tc and tc:IsFaceup() and tc:IsSetCard(0x282) then
    tc:AddCounter(0x1297,1)
  end
end
--(2)Special Summon
function s.thcostfilter(c)
  return c:IsSetCard(0x282) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
  local b1=Duel.IsCanRemoveCounter(tp,1,0,0x1297,2,REASON_COST)
  local b2=Duel.IsExistingMatchingCard(s.thcostfilter,tp,LOCATION_HAND,0,1,nil)
  if chk==0 then return b1 or b2 end
  if b1 and ((not b2) or Duel.SelectYesNo(tp,aux.Stringid(id,2))) then
    Duel.RemoveCounter(tp,1,0,0x1297,2,REASON_COST)
  else
    Duel.DiscardHand(tp,s.thcostfilter,1,1,REASON_COST,nil)
  end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x282) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end