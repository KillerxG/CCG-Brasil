--Weast Royal Dragon Λ - Irya
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),3,nil,s.matcheck)
	c:EnableReviveLimit()
	--(1)Change Name
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.tncon)
	e1:SetOperation(s.tnop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	--(2)Negate
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(s.negtg)
	e3:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e3)
	--(3)Destroy
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
	--(4)Move to another MMZ
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(s.mvtg)
	e5:SetOperation(s.mvop)
	c:RegisterEffect(e5)
end
--Link Summon
function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsRace,1,nil,RACE_DRAGON,lc,sumtype,tp) and g:IsExists(Card.IsLevelAbove,1,nil,8)
end
--(1)Change Name
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsCode,1,nil,777003710) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
function s.tncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_LINK and e:GetLabel()==1
end
function s.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetValue(777003710)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
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
--(3)Destroy
function s.desfilter1(c,tp)
  local lg=c:GetColumnGroup(1,1)
  local atk=c:GetAttack()
  return c:IsFaceup() and Duel.IsExistingMatchingCard(s.desfilter2,tp,0,LOCATION_ONFIELD,1,nil,lg,atk)
end
function s.desfilter2(c,g,atk)
  local seq=c:GetSequence() 
  return c:IsFaceup() and g:IsContains(c) and seq<5 and c:IsAttackBelow(atk)
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
  if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
    Duel.BreakEffect()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not tc1:IsRelateToEffect(e) or tc1:IsFacedown()
    or not Duel.IsPlayerCanSpecialSummonMonster(tp,777003726,0,0x288,2000,2000,9,RACE_DRAGON,ATTRIBUTE_LIGHT) then return end
    Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
    local token=Duel.CreateToken(tp,777003726)
    tc1:CreateRelation(token,RESET_EVENT+0x1fe0000)
    Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
    Duel.SpecialSummonComplete()
  end
end
--(4)Move to another MMZ
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
		and Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,aux.FaceupFilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or tc:IsControler(1-tp)
		or Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	local nseq=math.log(s,2)
	if Duel.MoveSequence(tc,nseq) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
	Duel.MoveSequence(e:GetHandler(),math.log(Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0),2))
	end
end
