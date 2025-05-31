--West Royal Dragon - Deeper
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Send 1 "Weat Royal Dragon" from your Deck to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfDiscard)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--(2)Move monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.seqtg)
	e2:SetOperation(s.seqop)
	c:RegisterEffect(e2)
	--(3)Ritual Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
--(1)Send 1 "Weast Royal Dragon" from your Deck to the GY, then Draw 1 card
function s.tgfilter(c)
	return c:IsSetCard(0x288) and c:IsAbleToGrave() and not c:IsCode(id)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) 
		and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_EFFECT)
end
--(2)Move monster
function s.seqfilter(c)
	local tp=c:GetControler()
	return c:IsFaceup() and c:GetSequence()<5 and Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)>0
end
function s.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.seqfilter(chkc) and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(s.seqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	Duel.SelectTarget(tp,s.seqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.seqop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local ttp=tc:GetControler()
	if not tc or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or Duel.GetLocationCount(ttp,LOCATION_MZONE,ttp,LOCATION_REASON_CONTROL)<=0 then return end
	local p1,p2,i
	if tc:IsControler(tp) then
		i=0
		p1=LOCATION_MZONE
		p2=0
	else
		i=16
		p2=LOCATION_MZONE
		p1=0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	Duel.MoveSequence(tc,math.log(Duel.SelectDisableField(tp,1,p1,p2,0),2)-i)
end
--(3)Ritual Summon
function s.spmfilterf(c,tp,mg,rc)
  if c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 then
    Duel.SetSelectedCard(c)
    return mg:CheckWithSumGreater(Card.GetRitualLevel,rc:GetLevel(),rc)
  else return false end
end
function s.filter2(c,e,tp,m1,m2)
  if not (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_FIEND)) or bit.band(c:GetType(),0x81)~=0x81
  or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
  local mg=m1:Filter(Card.IsCanBeRitualMaterial,c,c)
  mg:Merge(m2)
  if (c:IsCode(999500701) or c:IsCode(999501901)) then return c:ritual_custom_condition(mg,ft) end
  if c.mat_filter then
    mg=mg:Filter(c.mat_filter,nil)
  end
  return mg:CheckWithSumGreater(Card.GetRitualLevel,c:GetLevel(),c)
end
function s.mfilter2(c)
  return c:GetLevel()>0 and c:IsAbleToRemove() 
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then
    local mg1=Duel.GetRitualMaterial(tp)
    mg1:Remove(Card.IsLocation,nil,LOCATION_HAND+LOCATION_MZONE)
    local mg2=Duel.GetMatchingGroup(s.mfilter2,tp,0,LOCATION_GRAVE,nil)
    return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,mg1,mg2) 
    and e:GetHandler():IsAbleToRemove() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
  end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
  if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_REMOVED) then
    local mg1=Duel.GetRitualMaterial(tp)
    mg1:Remove(Card.IsLocation,nil,LOCATION_HAND+LOCATION_MZONE)
    local mg2=Duel.GetMatchingGroup(s.mfilter2,tp,0,LOCATION_GRAVE,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,mg1,mg2)
    local tc=g:GetFirst()
    if tc then
      local mg=mg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
      mg:Merge(mg2)
      local mat=nil   
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
      mat=mg:FilterSelect(tp,s.spmfilterf,1,1,nil,tp,mg,tc)
      Duel.SetSelectedCard(mat)
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
      local mat2=mg:SelectWithSumGreater(tp,Card.GetRitualLevel,tc:GetLevel(),tc)
      mat:Merge(mat2)
      tc:SetMaterial(mat)
      local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_GRAVE)     
      mat:Sub(mat2)
      Duel.Remove(mat2,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
      Duel.BreakEffect()
      Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
      tc:CompleteProcedure()
    end
  end
end