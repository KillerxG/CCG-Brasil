--Obscure Raid Warrior
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x281),aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK))
	--(1)Double damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e1)
	--(2)Piercing damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	--(3)Banish and ATK Up
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1,id)
	e3:SetRange(LOCATION_MZONE)
	--e3:SetCondition(s.condition1)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER_E)
	e4:SetCondition(s.condition2)
	c:RegisterEffect(e4)
end
--(3)Banish and ATK Up
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:GetFlagEffect(777004220)==0
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffect(777004220)~=0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,REASON_EFFECT,POS_FACEUP)>0 and tc:IsPreviousLocation(LOCATION_MZONE) 
		and (tc:GetOriginalLevel()>0 or tc:GetOriginalRank()>0 or tc:GetLink()>0) 
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) 
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local lv=math.max(tc:GetOriginalLevel(),tc:GetOriginalRank(),tc:GetLink())
		local c=e:GetHandler()
		Duel.HintSelection(c)
		local sc=c
		--Increase ATK
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(lv*300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		sc:RegisterEffect(e1)
	end
end