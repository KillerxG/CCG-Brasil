--Shinigami Grimoire
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--(1)Swap Curses
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--(2)Tribute
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_RELEASE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.reltg)
	e3:SetOperation(s.relop)
	c:RegisterEffect(e3)
	--(3)Cannot attack
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCondition(s.atcon)
	c:RegisterEffect(e4)
	--(4)Cannot be targeted by the opponent's card effects
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(s.tgcond)
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
	--(5)Cannot be destroyed by the opponent's card effects
	local e6=e5:Clone()
	e6:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e6:SetValue(aux.indoval)
	c:RegisterEffect(e6)
end
--(1)Swap Curses
function s.thfilter(c,tp,e)
	return c:IsAbleToHand() and c:IsFacedown()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.thfilter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,0,LOCATION_SZONE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,0,LOCATION_SZONE,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.tffilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSetCard(0x304b) and not c:IsForbidden()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
		local g=Duel.SelectMatchingCard(tp,s.tffilter,tp,LOCATION_DECK,0,tp,tp,e,tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tf=Duel.SelectMatchingCard(tp,s.tffilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tf and Duel.MoveToField(tf,tp,1-tp,LOCATION_SZONE,POS_FACEUP,true) then
		end
	end
end
--(2)Tribute
function s.filter2(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsReleasableByEffect()
end
function s.reltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil) end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
function s.relop(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE+LOCATION_HAND,0,nil)
		if #mg>0 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			local sg=mg:Select(tp,1,1,nil)
			Duel.Release(sg,REASON_EFFECT)			
		end
end
--(3)Cannot attack
function s.atcon(e)
	return Duel.IsExistingMatchingCard(Card.IsFacedown,e:GetHandlerPlayer(),0,LOCATION_ONFIELD,1,nil)
end
--(4)Cannot be targeted by the opponent's card effects
--(5)Cannot be destroyed by the opponent's card effects
function s.tgcond(e)
	return Duel.IsExistingMatchingCard(Card.IsFacedown,e:GetHandlerPlayer(),0,LOCATION_ONFIELD,1,nil)
end