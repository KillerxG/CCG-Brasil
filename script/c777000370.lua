--SAO Alicization Arc - Alice
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Material
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x282),1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
    --(1)Negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--(2)Destroy Replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.dreptg)
	e2:SetOperation(s.drepop)
	c:RegisterEffect(e2)
	--(3)Can attack twice
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetCondition(s.indcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
--(1)Negate
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ep==tp or c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1297,1,REASON_COST) end
  Duel.RemoveCounter(tp,1,0,0x1297,1,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
--(2)Destroy Replace
function s.dreptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return not e:GetHandler():IsReason(REASON_REPLACE+REASON_RULE)
  and Duel.IsCanRemoveCounter(tp,1,0,0x1297,1,REASON_EFFECT) end
  return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.drepop(e,tp,eg,ep,ev,re,r,rp)
  Duel.RemoveCounter(tp,1,0,0x1297,1,REASON_EFFECT)
end


function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1297,1,REASON_EFFECT) end
  Duel.RemoveCounter(tp,1,0,0x1297,1,REASON_EFFECT)
end
--(3)Can attack twice
function s.mfilter(c)
	return not c:IsSetCard(0x282)
end
function s.indcon(e)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and #mg>0 and not mg:IsExists(s.mfilter,1,nil)
end