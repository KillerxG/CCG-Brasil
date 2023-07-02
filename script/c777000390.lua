--SAO Alicization Arc - Kirito
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Add "Kirito" Arch
	c:AddSetcodesRule(id,true,0x282a)
	--Synchro Material
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x282),1,1,Synchro.NonTuner(nil),1,99,s.matfilter)
	c:EnableReviveLimit()
	--(1)Place SAO Counters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetTarget(s.pcttg)
	e1:SetOperation(s.pctop)
	c:RegisterEffect(e1)
	--(2)Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--(3)Indes by card effect
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	e3:SetCondition(s.indcon)
	c:RegisterEffect(e3)	
end
--Synchro Material
function s.matfilter(c,scard,sumtype,tp)
	return c:IsType(TYPE_MONSTER,scard,sumtype,tp) and c:IsSetCard(0x282a,scard,sumtype,tp)
end
--(1)Place SAO Counters
function s.pcttg(e,tp,eg,ep,ev,re,r,rp,chk)
  local tc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
  if chk==0 then return tc and tc:IsFaceup() and tc:IsSetCard(0x282) end
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))
end
function s.pctop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
  if tc and tc:IsFaceup() and tc:IsSetCard(0x282) then
    tc:AddCounter(0x1297,2)
  end
end
--(2)Destroy
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1297,1,REASON_COST) end
  Duel.RemoveCounter(tp,1,0,0x1297,1,REASON_COST)
end
function s.filter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk-1)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local atk=e:GetHandler():GetAttack()
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil,atk) end
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil,atk)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local atk=c:GetAttack()
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil,atk)
	Duel.Destroy(g,REASON_EFFECT)
end
--(3)Indes by card effect
function s.mfilter(c)
	return not c:IsSetCard(0x282)
end
function s.indcon(e)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and #mg>0 and not mg:IsExists(s.mfilter,1,nil)
end