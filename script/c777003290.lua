--Oceanic Storm Blood Experience
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Control or destroy
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.ctcon)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
end
--(1)Control or destroy
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x312) 
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.ctfilter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.ctfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.ctfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local atk=tc:GetAttack()
	if tc and tc:IsRelateToEffect(e) then
		if tc:IsDestructable() and Duel.CheckLPCost(1-tp,atk) and Duel.SelectYesNo(1-tp,aux.Stringid(id,0)) then
			Duel.PayLPCost(1-tp,atk)
			Duel.Destroy(tc,REASON_EFFECT)
		end
		Duel.GetControl(tc,tp)
	end
end