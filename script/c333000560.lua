--Digital Adventurer World
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--(1)Activate, place Counter
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	--(2)ATK Up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x298))
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--(3)DEF Up
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--(4)If dice is rolled, place counter
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_TOSS_DICE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetOperation(s.ctop2)
	c:RegisterEffect(e4)
	--(5)Change to Level 6
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_LVCHANGE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1,id)
	e5:SetCost(s.lv6cost)
	e5:SetTarget(s.lv6tg)
	e5:SetOperation(s.lv6op)
	c:RegisterEffect(e5)
	--(6)Change to Level 8
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,3))
	e6:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_LVCHANGE)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCountLimit(1,id+1)
	e6:SetCost(s.lv8cost)
	e6:SetTarget(s.lv8tg)
	e6:SetOperation(s.lv8op)
	c:RegisterEffect(e6)
	--(7)Change to Link 4
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,4))
	e7:SetCategory(CATEGORY_ATKCHANGE)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_FZONE)
	e7:SetCountLimit(1,id+2)
	e7:SetCost(s.lk4cost)
	e7:SetTarget(s.lk4tg)
	e7:SetOperation(s.lk4op)
	c:RegisterEffect(e7)
end
--(1)Activate, place Counter
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()	
	c:AddCounter(0x1298,2)
end
--(2)ATK Up
function s.atkval(e,c)
	return e:GetHandler():GetCounter(0x1298)*400
end
--(4)If dice is rolled, place counter
function s.ctop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()	
	c:AddCounter(0x1298,1)
end
--(5)Change to Level 6
function s.lv6cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1298,1,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,0x1298,1,REASON_COST)
end
function s.lv6filter(c)
	return c:IsFaceup() and c:GetLevel()==4 and c:IsSetCard(0x298)
end
function s.lv6tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.lv6filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.lv6filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.lv6filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.lv6op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(2)
		tc:RegisterEffect(e1)
		--ATK Up
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(600)
		tc:RegisterEffect(e2)
		--DEF Up
		local e3=e2:Clone()
		e3:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e3)	
	end
end
--(6)Change to Level 8
function s.lv8cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1298,2,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,0x1298,2,REASON_COST)
end
function s.lv8filter(c)
	return c:IsFaceup() and c:GetLevel()==6 and c:IsSetCard(0x298)
end
function s.lv8tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.lv8filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.lv8filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.lv8filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.lv8op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(2)
		tc:RegisterEffect(e1)
		--ATK Up
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(600)
		tc:RegisterEffect(e2)
		--DEF Up
		local e3=e2:Clone()
		e3:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e3)	
	end
end
--(7)Change to Link 4
function s.lk4cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1298,3,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,0x1298,3,REASON_COST)
end
function s.lk4filter(c)
	return c:IsFaceup() and c:GetLink()==2 and c:IsSetCard(0x298)
end
function s.lk4tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.lk4filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.lk4filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.lk4filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.lk4op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LINK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(2)
		tc:RegisterEffect(e1)
		--ATK Up
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1200)
		tc:RegisterEffect(e1)
		--Top Link Marker
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_ADD_LINKMARKER)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		e3:SetValue(LINK_MARKER_TOP)
		tc:RegisterEffect(e3)
		--Bottom Link Marker
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_ADD_LINKMARKER)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		e4:SetValue(LINK_MARKER_BOTTOM)
		tc:RegisterEffect(e4)
	end
end