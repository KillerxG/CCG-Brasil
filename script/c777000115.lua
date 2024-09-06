--HI3rd Elf - Blood Embrace Token
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --(1)Equip 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))	
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)	
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)	
	c:RegisterEffect(e1)
	 --(2)Gain ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(600)
	c:RegisterEffect(e2)
	--(3)Unaffected to S/T
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	--e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	--(4)Destroy replace
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetTarget(s.dreptg)
	e4:SetOperation(s.drepop)
	c:RegisterEffect(e4)
end
s.listed_names={777000010}
--(1)Equip
function s.eqfilter(c)
  return c:IsFaceup() and c:IsSetCard(0x299) 
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
  and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
  Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if not c:IsRelateToEffect(e) then return end
  if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
  local tc=Duel.GetFirstTarget()
  if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:GetControler()~=tp or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
    Duel.SendtoGrave(c,REASON_EFFECT)
    return
  end
  Duel.Equip(tp,c,tc,true)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_EQUIP_LIMIT)
  e1:SetReset(RESET_EVENT+0x1fe0000)
  e1:SetValue(s.eqlimit)
  e1:SetLabelObject(tc)
  c:RegisterEffect(e1)
end
function s.eqlimit(e,c)
  return c==e:GetLabelObject()
end
--(3)Unaffected to S/T
function s.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
--(4)Destroy replace
function s.dreptg(e,tp,eg,ep,ev,re,r,rp,chk)
  local c=e:GetHandler()
  local tc=c:GetEquipTarget()
  if chk==0 then return not tc:IsReason(REASON_REPLACE) and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
  return Duel.SelectEffectYesNo(tp,c,96)
end
function s.drepop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end