--HI3rd Herrscher of Sentience
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Material
	Fusion.AddProcFun2(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x299),s.ffilter,true)
	c:EnableReviveLimit()
	c:EnableCounterPermit(0x199)
	--(1)Herrscher Counter
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--(2)DEF Down
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.defcon)
	e2:SetTarget(s.deftg)
	e2:SetOperation(s.defop)
	c:RegisterEffect(e2)	
	--(3)Reduce DEF
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetValue(s.atkvalue)
	c:RegisterEffect(e3)
end
--Fusion Material
function s.ffilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH,fc,sumtype,tp)
end
--(1)Herrscher Counter
function s.cfilter(c)
	return c:IsSetCard(0x299) and not c:IsPublic()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local cg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,99,nil)
	Duel.ConfirmCards(1-tp,cg)
	Duel.ShuffleHand(tp)
	local ct=#cg
	for i=1,ct do
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
		local tc=g:Select(tp,1,1,nil):GetFirst()
		tc:AddCounter(0x199,1)
	end
end
--(2)DEF Down
function s.defcon(e)
	return e:GetHandler():GetCounter(0x199)>0
end
function s.defilter(c)
	return c:IsFaceup() and c:IsDefenseAbove(0)
end
function s.deftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(s.defilter,tp,0,LOCATION_MZONE,1,nil) end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.defilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.defop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e):Filter(Card.IsFaceup,nil)
	if #g==0 then return end
	local dg=Group.CreateGroup()
	local c=e:GetHandler()
	for tc in aux.Next(g) do
		local preatk=tc:GetAttack()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(s.atkval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if preatk~=0 and tc:GetDefense()==0 then dg:AddCard(tc) end
	end
	if #dg==0 then return end
	Duel.BreakEffect()
	Duel.Destroy(dg,REASON_EFFECT)
end
function s.atkval(e,c)
	return Duel.GetCounter(0,1,1,0x199)*-700
end
--(3)Reduce DEF
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