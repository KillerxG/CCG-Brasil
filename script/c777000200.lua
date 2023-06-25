--Azur Lane - Kawakaze
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)	
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	--(1.2)Check field spell to enable summon from gy
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.tdcon2)
	c:RegisterEffect(e2)
	--(2)Search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCountLimit(1,id+1)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
 end
--(1)Special Summon
function s.hspfilter(c)
  return c:IsFaceup() and c:IsSetCard(0x283) and c:IsType(TYPE_XYZ)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then
    local g=Group.CreateGroup()
    local mg=Duel.GetMatchingGroup(s.hspfilter,tp,LOCATION_MZONE,0,nil)
    for tc in aux.Next(mg) do
      g:Merge(tc:GetOverlayGroup())
    end
    if g:GetCount()==0 then return false end
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
  end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
  local g=Group.CreateGroup()
  local mg=Duel.GetMatchingGroup(s.hspfilter,tp,LOCATION_MZONE,0,nil)
  for tc in aux.Next(mg) do
    g:Merge(tc:GetOverlayGroup())
  end
  if g:GetCount()==0 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  local sg=g:Select(tp,1,1,nil)
  Duel.SendtoHand(sg,nil,REASON_EFFECT)
  local c=e:GetHandler()
  if not c:IsRelateToEffect(e) then return end
  Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
--(1.2)Check field spell to enable summon from gy
function s.tdcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPlayerAffectedByEffect(tp,777000160)
end
--(2)Search
function s.thfilter(c)
  return c:IsSetCard(0x283) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
  if g:GetCount()>0 then
    Duel.SendtoHand(g,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,g)
  end
end