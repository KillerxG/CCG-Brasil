--FGO Pretender, Lady Avalon
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Avoid destruction by battle once
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.indtg)
	e1:SetCountLimit(1)
	e1:SetValue(s.valcon)
	c:RegisterEffect(e1)
	--(2)Avoid destruction by effect once
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indtg)
	e2:SetCountLimit(1)
	e2:SetValue(s.val2con)
	c:RegisterEffect(e2)
	--(3)ATK Up
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.atktg)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	--(4)Add 1 "Fate Grand Order" to the hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_COUNTER)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_HAND)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	--(5)SQ Counter
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_COUNTER)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS+CATEGORY_COUNTER)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e5:SetCountLimit(1)
	e5:SetTarget(s.pcttg)
	e5:SetOperation(s.pctop)
	c:RegisterEffect(e5)
	--(5)SQ Counter
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_COUNTER)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS+CATEGORY_COUNTER)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetCountLimit(1)
	e6:SetTarget(s.pcttg)
	e6:SetOperation(s.pctop)
	c:RegisterEffect(e6)
end
s.listed_names={777002210}
--(1)Avoid destruction once
function s.indtg(e,c)
	return c:IsSetCard(0x294)
end
function s.valcon(e,re,r,rp)
	return (r&REASON_BATTLE)~=0
end
--(2)Avoid destruction by effect once
function s.val2con(e,re,r,rp)
	return (r&REASON_EFFECT)~=0
end
--(4)Add 1 "Fate Grand Order" to the hand

function s.filter(c,tp)
	return c:IsCode(777002210) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp) then
		Duel.SendtoGrave(c,REASON_EFFECT)
		s.pctop(e,tp,eg,ep,ev,re,r,rp)
	end
end
--(3)ATK Up
function s.atkfilter(c)
	return c:IsFaceup() and c:IsMonster()
end
function s.atktg(e,c)
  return c:IsSetCard(0x294) and c~=e:GetHandler()
end
function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(s.atkfilter,c:GetControler(),LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	return ct*400
end
--(5)SQ Counter
--(6)SQ Counter
function s.pcttg(e,tp,eg,ep,ev,re,r,rp,chk)
  local tc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
  if chk==0 then return tc and tc:IsFaceup() and tc:IsSetCard(0x294) end
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
end
function s.pctop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
  if tc and tc:IsFaceup() and tc:IsSetCard(0x294) then
    tc:AddCounter(0x1294,3)
  end
end