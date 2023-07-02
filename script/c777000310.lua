--SAO The World Tree
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --(1)Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--(2)Normal Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.nscon)
	e2:SetCost(s.nscost)
	e2:SetTarget(s.nstg)
	e2:SetOperation(s.nsop)
	c:RegisterEffect(e2)
	--(3)Place SAO Counter(s)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(s.pctop)
	c:RegisterEffect(e3)
	--(4)Destroy replace
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.dreptg)
	e4:SetOperation(s.drepop)
	c:RegisterEffect(e4)
	--(5)ATK Up
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x282))
	e5:SetValue(s.atkval)
	c:RegisterEffect(e5)
end
--(2)Normal Summon
function s.nscon(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,0x282),tp,LOCATION_MZONE,0,nil)
	return ct==Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
end
function s.nscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1297,1,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,0x1297,1,REASON_COST)
end
function s.nsfilter(c)
	return c:IsSetCard(0x282) and c:IsSummonable(true,nil)
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		Duel.Summon(tp,g:GetFirst(),true,nil)
	end
end
--(3)Place SAO Counter(s)
function s.pctfilter(c,tp)
  return c:IsFaceup() and c:IsSetCard(0x282) and c:GetSummonPlayer()==tp
end
function s.pctop(e,tp,eg,ep,ev,re,r,rp)
  local ct=eg:FilterCount(s.pctfilter,nil,tp)
  if ct>0 then
    e:GetHandler():AddCounter(0x1297,ct,true)
  end
end
--(4)Destroy replace
function s.dreptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return not e:GetHandler():IsReason(REASON_REPLACE+REASON_RULE)
  and e:GetHandler():IsCanRemoveCounter(tp,0x1297,1,REASON_EFFECT) end
  return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.drepop(e,tp,eg,ep,ev,re,r,rp)
  e:GetHandler():RemoveCounter(tp,0x1297,1,REASON_EFFECT)
end
--(5)ATK Up
function s.atkval(e,c)
	return e:GetHandler():GetCounter(0x1297)*100
end