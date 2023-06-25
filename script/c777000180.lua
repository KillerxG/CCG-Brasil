--Azur Lane - Helena
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--XYZ Materials
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,s.xyzfilter,nil,2,nil,nil,nil,nil,false,s.xyzcheck)
	--(1)Set 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)	
	--(2)Shuffle into the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
--XYZ Materials
function s.xyzfilter(c,xyz,sumtype,tp)
    return c:HasLevel() and c:IsSetCard(0x283)
end
function s.xyzcheck(g,tp,xyz)
    local mg=g:Filter(function(c) return not c:IsHasEffect(511001175) end,nil)
    return #mg==2 and math.abs(mg:GetFirst():GetLevel()-mg:GetNext():GetLevel())==2
end
--(1)Set
function s.setfilter(c)
	return c:IsSetCard(0x283) and (c:IsSpell() or c:IsTrap()) and c:IsSSetable()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		Duel.SSet(tp,tc)
	end
end
--(2)Shuffle into the Deck
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsLocation(LOCATION_GRAVE) 
end
function s.tdfilter(c)
    return c:IsSetCard(0x283) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and c:IsAbleToDeck()
end
function s.spfilter(c,e,tp)
  return c:IsSetCard(0x283) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
  local b2=Duel.IsPlayerCanDraw(tp,1)
  if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) and (b1 or b2) end
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
  local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0 then
    local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
    local b2=Duel.IsPlayerCanDraw(tp,1)
    if b1 and b2 then
      op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
    elseif b1 then
      op=Duel.SelectOption(tp,aux.Stringid(id,2))
    else
      op=Duel.SelectOption(tp,aux.Stringid(id,3))+1
    end
    if op==0 then
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
      local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
      if g:GetCount()>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
      end
    else
      Duel.Draw(tp,1,REASON_EFFECT)
    end
  end
end