--Radiant Bright Token
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Change attribute to LIGHT or gain LP
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_TOGRAVE)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetCountLimit(1)
	e6:SetTarget(s.target)
	e6:SetOperation(s.activate)
	c:RegisterEffect(e6)
end
--(1)Change attribute to LIGHT or gain LP
function s.filter(c,e,tp)
	return c:IsMonster()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler(),e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler(),e,tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if tc:IsMonster() and not tc:IsAttribute(ATTRIBUTE_LIGHT) then
		local e1=Effect.CreateEffect(e:GetHandler())		
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(ATTRIBUTE_LIGHT)
		tc:RegisterEffect(e1)
		if tc:IsOriginalAttribute(ATTRIBUTE_DARK) and tc:IsNegatableMonster() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		end
	elseif (tc:IsMonster() and tc:IsAttribute(ATTRIBUTE_LIGHT)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		Duel.Recover(tp,tc:GetAttack(),REASON_EFFECT)
		if tc:IsOriginalAttribute(ATTRIBUTE_DARK) and tc:IsNegatableMonster() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		end
	end
end
