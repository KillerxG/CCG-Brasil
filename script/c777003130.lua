--Singtress of Elementale - Zel
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	c:EnableReviveLimit()
	--(1)Special Summon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.FALSE)
	c:RegisterEffect(e0)
	--(2)Special Summon itself from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--(3)Change any number of face-down monsters on the field to face-up Defense Position
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
	--(4)DEF Up
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.efilter)
	e3:SetValue(s.val)
	c:RegisterEffect(e3)
	--(5)Pos Change
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SET_POSITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)	
	e4:SetTarget(s.target)
	e4:SetValue(POS_FACEUP_DEFENSE)
	c:RegisterEffect(e4)
end
--(2)Special Summon itself from the hand
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsMonster,Card.IsSetCard),tp,LOCATION_GRAVE+LOCATION_MZONE,0,nil,0x310)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>=3 and g:GetClassCount(Card.GetCode)>=3
end
--(3)Change any number of face-down monsters on the field to face-up Defense Position
function s.posfilter(c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE) and c:IsCanChangePosition()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,PLAYER_EITHER,LOCATION_MZONE)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp,chk)
	local facedown_ct=Duel.GetMatchingGroupCount(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if facedown_ct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,facedown_ct,nil)
	if #g==0 then return end
	Duel.HintSelection(g)
	if Duel.ChangePosition(g,POS_FACEUP_DEFENSE)==0 then return end
	local og=Duel.GetOperatedGroup()
	local flip_count=og:FilterCount(Card.IsSetCard,nil,0x310)
	if flip_count>0 and Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,og)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local pos_g=Duel.SelectMatchingCard(tp,Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,flip_count,og)
		if #pos_g>0 then
			Duel.HintSelection(pos_g)
			Duel.BreakEffect()
			Duel.ChangePosition(pos_g,POS_FACEDOWN_DEFENSE)
		end
	end
end
--(4)DEF Up
function s.efilter(e,c)
	return c:IsSetCard(0x310) and c~=e:GetHandler()
end
function s.val(e,c)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)*300
end
--(5)Pos Change
function s.target(e,c)
	return c~=e:GetHandler() and c:IsFaceup() and c:IsSetCard(0x310)
end