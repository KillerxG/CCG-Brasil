--West Royal Dragon - Irya
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--(1)Direct Attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(s.dircon)
	c:RegisterEffect(e1)
	--(2)Cannot be battle Target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetValue(s.tgval)
	c:RegisterEffect(e2)
	--(3)Move
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_BATTLE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.seqcost)
	e3:SetTarget(s.seqtg)
	e3:SetOperation(s.seqop)
	c:RegisterEffect(e3)
end
s.listed_names={777003720,id}
--(1)Direct Attack
function s.dircon(e)
	return e:GetHandler():GetColumnGroup():FilterCount(Card.IsMonster,nil)==0
end
--(2)Cannot be battle Target
function s.tgval(e,c)
	return not e:GetHandler():GetColumnGroup():IsContains(c)
end
--(3)Move
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
function s.tkcostfilter(c)
	return c:IsSetCard(0x288) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.seqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.tkcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.tkcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
end
function s.seqop(e,tp,eg,ep,ev,re,r,rp)
	Duel.MoveSequence(e:GetHandler(),math.log(Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0),2))
end