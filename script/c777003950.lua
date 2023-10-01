--Weast Royal Dragon Γ - Irya
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,9,2)
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
	--(2)Attach
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.postg)
	e3:SetOperation(s.posop)
	c:RegisterEffect(e3)
	--(3)Attach Plus
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1,id)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(aux.dxmcostgen(1,1,nil))
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)	
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
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_XYZ and e:GetLabel()==1
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
--(2)Attach
function s.ainzfiler(c,seq,p)
  return c:IsFaceup() and c:IsSetCard(0x288) and c:IsColumn(seq,p,LOCATION_MZONE)
end
function s.posfilter(c,tp,g)
  return c:GetSummonPlayer()~=tp and (g:IsContains(c) 
  or Duel.IsExistingMatchingCard(s.ainzfiler,tp,LOCATION_MZONE,0,1,nil,c:GetSequence(),1-tp))
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return eg:IsExists(s.posfilter,1,nil,tp,e:GetHandler():GetColumnGroup()) end
  local g=eg:Filter(s.posfilter,nil,tp,e:GetHandler():GetColumnGroup())
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetTargetCard(g)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
  local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.posfilter,nil,tp,e:GetHandler():GetColumnGroup())
  if g:GetCount()>0 then
    Duel.Overlay(c,g)
  end
end
--(3)Attach Plus
function s.desfilter1(c,tp)
  local lg=c:GetColumnGroup()
  return Duel.IsExistingMatchingCard(s.desfilter2,tp,0,LOCATION_ONFIELD,1,nil,lg)
end
function s.desfilter2(c,g)
  return g:IsContains(c)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.desfilter1,tp,0,LOCATION_ONFIELD,1,nil,tp) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  Duel.SelectTarget(tp,s.desfilter1,tp,0,LOCATION_ONFIELD,1,1,nil,tp)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local tc=Duel.GetFirstTarget()
  local lg=tc:GetColumnGroup()
  local g=Duel.GetMatchingGroup(s.desfilter2,tp,0,LOCATION_ONFIELD,nil,lg)
  if g:GetCount()==0 then return end
  if tc:IsRelateToEffect(e) and g:GetCount()>0
  and Duel.Overlay(c,g)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
    if Duel.MoveSequence(c,math.log(Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0),2)) then
		Duel.Overlay(c,tc)
	end
  end
end