--Silver Fangs Attack
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --(1)Atk down/Negate/Recover
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--(2)Set itself from GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.neg2con)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
--(1)Atk down/Negate/Recover
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x307) and (c:IsLinkMonster() or c:IsCode(777001320))
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.negfilter(c)
  return c:IsFaceup() and not c:IsDisabled()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingMatchingCard(s.negfilter,tp,0,LOCATION_MZONE,1,e:GetHandler()) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
  local g=Duel.SelectMatchingCard(tp,s.negfilter,tp,0,LOCATION_MZONE,1,1,c)
  local tc=g:GetFirst()
  if tc then
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_ATTACK_FINAL)
    e1:SetValue(0)
    tc:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
    tc:RegisterEffect(e2)
    Duel.NegateRelatedChain(tc,RESET_TURN_SET)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_DISABLE)
    tc:RegisterEffect(e3)
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_DISABLE_EFFECT)
    e4:SetValue(RESET_TURN_SET)
    tc:RegisterEffect(e4)
    if tc:IsType(TYPE_TRAPMONSTER) then
      local e5=Effect.CreateEffect(c)
      e5:SetType(EFFECT_TYPE_SINGLE)
      e5:SetCode(EFFECT_DISABLE_TRAPMONSTER)
      tc:RegisterEffect(e5)
    end
	if tc:IsLevelAbove(1) then
      local e6=Effect.CreateEffect(c)
      e6:SetType(EFFECT_TYPE_SINGLE)
      e6:SetCode(EFFECT_CHANGE_LEVEL)
	  e6:SetValue(1)
      tc:RegisterEffect(e6)
    end
    if not tc:IsImmuneToEffect(e) then
      Duel.Recover(tp,tc:GetBaseAttack(),REASON_EFFECT)
    end
  end
end
--(2)Set itself from GY
function s.neg2con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsTurnPlayer(tp) and Duel.IsMainPhase()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return e:GetHandler():IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
		if Duel.GetLP(tp)>Duel.GetLP(1-tp) then --if your lp is higher then your opponent, card leave redirect to hand
		local e1=Effect.CreateEffect(c) 
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_HAND)
		c:RegisterEffect(e1)
		end
		if Duel.GetLP(tp)<Duel.GetLP(1-tp) or Duel.GetLP(tp)==Duel.GetLP(1-tp) then  --if your lp are not higher then your opponent, card leave redirect to removed
		local e2=Effect.CreateEffect(c) 
		e2:SetDescription(3300)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e2)
	end
	end
end

