--Everlasting Soul, Blader Erick
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Special Summon itself
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--(2)LV Change
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
	--(3)Effect Gain: Change the DEF of 1 face-up monster to 0	
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return (r&REASON_SYNCHRO)==REASON_SYNCHRO and e:GetHandler():GetReasonCard():IsCode(777004920) end)
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)	
end
--(1)Special Summon itself
function s.spcostfilter(c)
	return c:IsContinuousTrap() and not c:IsPublic()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_HAND+LOCATION_SZONE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rc=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_HAND+LOCATION_SZONE,0,1,1,c):GetFirst()
	Duel.SetTargetCard(rc)
	Duel.ConfirmCards(1-tp,rc)
	Duel.ShuffleHand(tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,tp)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local rc=Duel.GetFirstTarget()
	if rc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and rc:IsSetCard(0x258) and rc:IsLocation(LOCATION_HAND)
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.BreakEffect()
		Duel.MoveToField(rc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
--(2)LV Change
function s.lvfilter(c)
	return c:IsFaceup() and c:HasLevel() and c:GetLevel()~=6
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.lvfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(6)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end
--(3)Effect Gain: Change the DEF of 1 face-up monster to 0	
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	--(3.1)Change the DEF of 1 face-up monster to 0	
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	--(3.2)Add type effect
	if not rc:IsType(TYPE_EFFECT) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
	rc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
end
--(1.2)Change the DEF of 1 face-up monster to 0	
function s.posfilter(c)
	return c:IsAttackPos() and c:IsCanChangePosition() and not c:IsDefense(0)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.posfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
	if c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(0)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_PIERCE)
		c:RegisterEffect(e2)		
	end
end