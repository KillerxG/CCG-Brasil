--HN Hard Drive Divinity
--Scripted by Raivost
local s,id=GetID()
function s.initial_effect(c)
	--(1)Xyz Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.xyztg)
	e1:SetOperation(s.xyzop)
	c:RegisterEffect(e1)
	--(2)Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.exctg)
	e2:SetOperation(s.excop)
	c:RegisterEffect(e2)
end
--(1)Xyz Summon
function s.matfilter(c,e)
  return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x998) and c:IsCanBeEffectTarget(e)
end
function s.xyzfilter(c,e,tp)
  return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x998) and c:IsRankBelow(4) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.rescon(sg,e,tp,mg)
  return sg:GetClassCount(Card.GetCode)==#sg
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return false end
  local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.matfilter),tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,e)
  if chk==0 then return Duel.GetLocationCountFromEx(tp)>0 and aux.SelectUnselectGroup(tg,e,tp,1,2,s.rescon,0)
  and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
  local g=aux.SelectUnselectGroup(tg,e,tp,1,2,s.rescon,1,tp,HINTMSG_TARGET)
  Duel.SetTargetCard(g)
  e:SetLabel(#g)
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetLocationCountFromEx(tp)<=0 then return end
  local mat=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
  local ct=e:GetLabel()
  if mat:GetCount()~=ct then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
  local tc=g:GetFirst()
  if tc and Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
    Duel.Overlay(tc,mat)
    tc:CompleteProcedure()
  end
end
--(2)Special Summon
function s.cfilter(c)
	return c:IsMonster() and c:IsSetCard(0x998) and not c:IsCode(id)  and c:IsAbleToRemoveAsCost()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0)
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.spfilter(c,e,tp)
  return c:IsSetCard(0x998) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
  and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,tp,LOCATION_DECK)
end
function s.excop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  Duel.ConfirmDecktop(tp,3)
  local g=Duel.GetDecktopGroup(tp,3)
  local sg=g:Filter(s.spfilter,nil,e,tp)
  local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
  if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
  if g:GetCount()>0 then
    Duel.DisableShuffleCheck()
    if sg:GetCount()>0 and ft>0 then
      if sg:GetCount()>ft then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        sg=sg:Select(tp,ft,ft,nil)
      end
      g:Sub(sg)
      local tc=sg:GetFirst()
      while tc do
        Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
        tc=sg:GetNext()
      end
      Duel.SpecialSummonComplete()
    end
    Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)   
  end
  --HN monsters
  --(2.1)Lock Summon
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,2),nil)
		--(2.2)Lizard check
		aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)
end
--HN monsters
--(2.1)Lock Summon
function s.splimit(e,c)
	return not c:IsSetCard(0x998) and c:IsLocation(LOCATION_EXTRA)
end
--(2.2)Lizard check
function s.lizfilter(e,c)
	return not c:IsSetCard(0x998)
end