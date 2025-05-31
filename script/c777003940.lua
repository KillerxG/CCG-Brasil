--West Royal Dragon Legacy
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Ritual Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	--(2)Grant effect to "Weast Royal Dragon - Irya"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_REFLECT_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetValue(s.refcon)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
s.listed_names={777003710,id}
--(1)Ritual Summon
function s.spmfilterf(c,tp,mg,rc)
  if c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 then
    Duel.SetSelectedCard(c)
    return mg:CheckWithSumGreater(Card.GetRitualLevel,rc:GetLevel(),rc)
  else return false end
end
function s.spfilter1(c,e,tp,m,ft)
  if not (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_FIEND)) or bit.band(c:GetType(),0x81)~=0x81
  or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false) then return false end
  local mg=m:Filter(Card.IsCanBeRitualMaterial,c,c)
  if c.mat_filter then
    mg=mg:Filter(c.mat_filter,nil)
  end
  if (c:IsCode(999507071) or c:IsCode(999570191)) then return c:ritual_custom_condition(mg,ft) end
  if c.mat_filter then
    mg=mg:Filter(c.mat_filter,nil)
  end
  if ft>0 then
    return mg:CheckWithSumGreater(Card.GetRitualLevel,c:GetLevel(),c)
  else
    return mg:IsExists(s.spmfilterf,1,nil,tp,mg,c)
  end
end
function s.spmfilter1(c)
  return c:GetLevel()>0 and c:IsAbleToGrave() and (c:IsSetCard(0x288) or c:IsRitualMonster())
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then
    local mg=Duel.GetRitualMaterial(tp)
    local sg=Duel.GetMatchingGroup(s.spmfilter1,tp,LOCATION_DECK,0,nil)
    mg:Merge(sg)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    return ft>-1 and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp,mg,ft)
  end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
  local mg=Duel.GetRitualMaterial(tp)
  local sg=Duel.GetMatchingGroup(s.spmfilter1,tp,LOCATION_DECK,0,nil)
  mg:Merge(sg)
  local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local tg=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp,mg,ft)
  local tc=tg:GetFirst()
  if tc then
    mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
    if tc.mat_filter then
      mg=mg:Filter(tc.mat_filter,nil)
    end
    local mat=nil
    if ft>0 then
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
      mat=mg:SelectWithSumGreater(tp,Card.GetRitualLevel,tc:GetLevel(),tc)
    else
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
      mat=mg:FilterSelect(tp,s.spmfilterf,1,1,nil,tp,mg,tc)
      Duel.SetSelectedCard(mat)
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
      local mat2=mg:SelectWithSumGreater(tp,Card.GetRitualLevel,tc:GetLevel(),tc)
      mat:Merge(mat2)
    end
    tc:SetMaterial(mat)
    local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_DECK)
    mat:Sub(mat2)
    Duel.ReleaseRitualMaterial(mat)
    Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
    Duel.BreakEffect()
    Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)
    tc:CompleteProcedure()
  end
end
--(2)Grant effect to "Weast Royal Dragon - Irya"
function s.eftg(e,c)
	return c:IsType(TYPE_EFFECT) and c:IsCode(777003710)
end
function s.refcon(e,re,val,r,rp,rc)
	return (r&REASON_EFFECT)~=0
end