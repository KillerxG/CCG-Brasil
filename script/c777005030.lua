--Warrior Reaper - Alice
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--(1)Destroy or bounce
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(Cost.SelfDiscard)
	e1:SetTarget(s.sttg)
	e1:SetOperation(s.stop)
	c:RegisterEffect(e1)
	--(2)Special Summon itself
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_LVCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--(3)Effect Gain: Mult Attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return (r&REASON_SYNCHRO)==REASON_SYNCHRO and e:GetHandler():GetReasonCard():IsCode(777004920) end)
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)	
end
--(1)Destroy or bounce
function s.filter(c)
	return c:IsSpellTrap()
end
function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
end
function s.stop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local op=Duel.SelectEffect(tp,
			{true,aux.Stringid(id,2)},
			{tc:IsAbleToHand(),aux.Stringid(id,3)})
		if op==1 then
			Duel.Destroy(tc,REASON_EFFECT)
		else
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
--(2)Special Summon itself
function s.spfilter(c,e,tp)
	return c:IsLevel(6) and c:IsFaceup()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		--Banish it when it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end
--(3)Effect Gain: Mult Attack
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	--(3.1)Each time your opponent Special Summons a monster(s), inflict 500 damage to your opponent
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
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
	rc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))
end
function s.atkfilter(c,e,tp)
	return c:IsFaceup() and c:IsContinuousTrap()
end
function s.atkcon(e)
	return Duel.IsExistingMatchingCard(s.atkfilter,e:GetHandlerPlayer(),LOCATION_SZONE,0,1,nil)
end
function s.atkval(e)
	local g=Duel.GetMatchingGroup(s.atkfilter,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil)
	return g:GetClassCount(Card.GetCode)
end