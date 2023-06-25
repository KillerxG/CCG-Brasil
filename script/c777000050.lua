--HI3rd, Herrscher of Truth
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Material
	Fusion.AddProcFun2(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x299),s.ffilter,true)
	c:EnableReviveLimit()
	c:EnableCounterPermit(0x199)	
	--(1)Place Herrscher Counter(s)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(s.pctop)
	c:RegisterEffect(e1)
	--(2)Reduce ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetValue(s.atkvalue)
	c:RegisterEffect(e2)
	--(3)Set "HI3rd" S/T
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.setcost)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
--Fusion Material
function s.ffilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_WATER,fc,sumtype,tp)
end
--(2)Place Herrscher Counter(s)
function s.pctfilter(c,tp)
  return c:IsFaceup() --and c:IsSetCard(0x299) and c:GetSummonPlayer()==tp
end
function s.pctop(e,tp,eg,ep,ev,re,r,rp)
  local ct=eg:FilterCount(s.pctfilter,nil,tp)
  if ct>0 then
    e:GetHandler():AddCounter(0x199,ct,true)
  end
end
--(2)Reduce ATK
function s.atkcon(e)
	return e:GetHandler():GetSequence()==2
end
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x299) and c:GetAttribute()~=0
end
function s.atkvalue(e,c)
	local g=Duel.GetMatchingGroup(s.atkfilter,c:GetControler(),0,LOCATION_MZONE,nil)
	local ct=g:GetClassCount(Card.GetAttribute)
	return ct*-500
end
--(3)Set "HI3rd" S/T
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x199,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x199,1,REASON_COST)
end
function s.setfilter(c)
	return c:IsSetCard(0x299) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end