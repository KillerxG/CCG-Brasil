--Weast Royal Dragon Λ - Irya
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),3,nil,s.matcheck)
	c:EnableReviveLimit()
	--(1)Change Name
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(777003710)
	c:RegisterEffect(e1)
	--(2)Negate
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(s.negtg)
	e3:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e3)
	--(3)Return to hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
	--(4)Banish all, then Special Summon all
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id+1)
	e5:SetTarget(s.rmsptg)
	e5:SetOperation(s.rmspop)
	c:RegisterEffect(e5)
end
s.listed_names={777003710}
--Link Summon
function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsRace,1,nil,RACE_DRAGON,lc,sumtype,tp) and g:IsExists(Card.IsLevelAbove,1,nil,8)
end
--(2)Negate
function s.ainzfiler(c,seq,p)
  return c:IsFaceup() and c:IsSetCard(0x288) and c:IsColumn(seq,p,LOCATION_MZONE)
end
function s.negtg(e,c)
  local tp=e:GetHandlerPlayer()
  local atk=e:GetHandler():GetAttack()
  local g=e:GetHandler():GetColumnGroup() 
  return (c:IsType(TYPE_EFFECT) or bit.band(c:GetOriginalType(),TYPE_EFFECT)==TYPE_EFFECT)
  and c:GetAttack()<atk and c:IsSummonType(SUMMON_TYPE_SPECIAL) and (g:IsContains(c)  
  or Duel.IsExistingMatchingCard(s.ainzfiler,tp,LOCATION_MZONE,0,1,nil,c:GetSequence(),1-tp))
end
--(3)Return to hand
function s.desfilter1(c,tp)
  local lg=c:GetColumnGroup(1,1)
  local atk=c:GetAttack()
  return c:IsFaceup() and Duel.IsExistingMatchingCard(s.desfilter2,tp,0,LOCATION_ONFIELD,1,nil,lg,atk)
end
function s.desfilter2(c,g,atk)
  local seq=c:GetSequence() 
  return c:IsFaceup() and g:IsContains(c) and seq<5 and c:IsAttackBelow(atk) and c:IsAbleToHand()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.desfilter1,tp,LOCATION_MZONE,0,1,nil,tp) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  Duel.SelectTarget(tp,s.desfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local tc1=Duel.GetFirstTarget()
  local lg=tc1:GetColumnGroup(1,1)
  local atk=tc1:GetAttack()
  local g=Duel.GetMatchingGroup(s.desfilter2,tp,0,LOCATION_MZONE,nil,lg,atk)
  if g:GetCount()==0 then return end
  Duel.SendtoHand(g,nil,REASON_EFFECT)
  if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
    Duel.BreakEffect()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not tc1:IsRelateToEffect(e) or tc1:IsFacedown()
    or not Duel.IsPlayerCanSpecialSummonMonster(tp,777003726,0,0x288,2000,2000,9,RACE_DRAGON,ATTRIBUTE_DARK) then return end
    Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
    local token=Duel.CreateToken(tp,777003726)
    tc1:CreateRelation(token,RESET_EVENT+0x1fe0000)
    Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
    Duel.SpecialSummonComplete()
  end
end
--(4)Banish all, then Special Summon all
function s.rmsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_EITHER,LOCATION_REMOVED)
end
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_REMOVED) and not c:IsReason(REASON_REDIRECT)
		and (c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,c:GetOwner())
		or c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,c:GetOwner()))
end
function s.rmspop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup()
		local sg=og:Filter(s.spfilter,nil,e,tp)
		if #sg==0 then return end
		for sc in sg:Iter() do
			local sump=0
			if sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,sc:GetOwner()) then sump=sump|POS_FACEUP end
			if sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,sc:GetOwner()) then sump=sump|POS_FACEDOWN_DEFENSE end
			Duel.SpecialSummonStep(sc,0,tp,sc:GetOwner(),false,false,sump)
		end
		local fdg=sg:Filter(Card.IsFacedown,nil)
		if #fdg>0 then
			Duel.ConfirmCards(1-tp,fdg)
		end
		Duel.BreakEffect()
		Duel.SpecialSummonComplete()
	end
end