--Oceanic Storm Blood Command
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetLabelObject(e1)
	e2:SetCondition(aux.PersistentTgCon)
	e2:SetOperation(aux.PersistentTgOp(false))
	c:RegisterEffect(e2)
	--(1)Change name to "Blood Plague"
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CHANGE_CODE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(aux.PersistentTargetFilter)
	e3:SetValue(777003301)
	c:RegisterEffect(e3)
	--(2)Remove Attributes
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_REMOVE_ATTRIBUTE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetTarget(aux.PersistentTargetFilter)
	e4:SetValue(ATTRIBUTE_ALL)
	c:RegisterEffect(e4)
	--(3)Remove Types
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_REMOVE_RACE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetTarget(aux.PersistentTargetFilter)
	e5:SetValue(RACE_ALL)
	c:RegisterEffect(e5)
	--(4)Activate cost
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_ACTIVATE_COST)
	e6:SetRange(LOCATION_SZONE)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetTargetRange(0,1)
	e6:SetCondition(s.costcon)
	e6:SetCost(s.costchk)
	e6:SetOperation(s.costop)
	c:RegisterEffect(e6)
	--(4.1)Accumulate
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(id)
	e7:SetRange(LOCATION_SZONE)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e7:SetTargetRange(0,1)
	e7:SetCondition(s.costcon)
	c:RegisterEffect(e7)
	--(5)Set this card
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,0))
	e8:SetType(EFFECT_TYPE_QUICK_O)
	e8:SetCode(EVENT_FREE_CHAIN)
	e8:SetRange(LOCATION_GRAVE)
	e8:SetCountLimit(1,id)
	e8:SetHintTiming(TIMING_END_PHASE,TIMING_BATTLE_END|TIMINGS_CHECK_MONSTER_E)
	e8:SetCondition(s.setcon)
	e8:SetTarget(s.settg)
	e8:SetOperation(s.setop)
	c:RegisterEffect(e8)
end
--Activate
function s.filter(c)
	return c:IsFaceup() and c:GetCode()~=777003301
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.filter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,e:GetHandler())
end
--(4)Activate cost
function s.spconfilter(c)
	return c:IsFaceup() and c:IsCode(777003301)
end
function s.costcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.spconfilter,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
function s.costchk(e,te_or_c,tp)
	local ct=#{Duel.GetPlayerEffect(tp,id)}
	return Duel.CheckLPCost(tp,ct*600)
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp,600)
end
--(5)Set this card
function s.setconfilter(c)
	return c:IsFaceup() and c:IsOriginalCode(777003320)
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.setconfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() and Duel.SSet(tp,c)>0 then
	end
end