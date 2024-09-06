--Super Star Vesperbell Combination
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Act in Hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e1:SetCondition(s.actcon)
	c:RegisterEffect(e1)
	--(2)Return Ritual or Super Star to destroy opp cards
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	--(3)Increase Scale
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+1)
	e3:SetCost(s.lvcost)
	e3:SetTarget(s.lvtg)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)
end
--(1)Act in Hand
function s.actfilter(c)
	return c:IsFaceup() and (c:IsCode(777003070) or c:IsCode(777003080))
end
function s.actcon(e)
	return Duel.IsExistingMatchingCard(s.actfilter,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,nil)
end
--(2)Return Ritual or Super Star to destroy opp cards
function s.filter1(c,tp)
	return c:IsLocation(LOCATION_ONFIELD) and (c:IsRitualMonster() or (c:IsSetCard(0x315) and c:IsFaceup())) and c:IsAbleToHand()
end
function s.disfilter3(c,tp)
	return c:IsDestructable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=Duel.GetMatchingGroupCount(s.disfilter3,tp,0,LOCATION_ONFIELD,nil)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and s.filter1(chkc) end
	if chk==0 then return ct>0 and Duel.IsExistingTarget(s.filter1,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_ONFIELD,0,1,ct,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e)
	if #tg>0 and Duel.SendtoHand(tg,nil,REASON_EFFECT)>0 then
		local ct=#(Duel.GetOperatedGroup())
		local cg=Duel.GetMatchingGroup(Card.IsDestructable,tp,0,LOCATION_ONFIELD,nil)
		if ct>0 and #cg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=cg:Select(tp,1,ct,nil)
			Duel.BreakEffect()
			for tc in aux.Next(sg) do
				Duel.Destroy(tc,REASON_EFFECT)
			end
		end
	end
end
--(3)Increase Scale
function s.cfilter(c,tp)
	return c:IsLevelBelow(7) and c:IsAbleToGraveAsCost() and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_PZONE,0,1,c)
end
function s.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local f=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	Duel.Remove(f,POS_FACEUP,REASON_COST)
	Duel.SendtoGrave(g,REASON_EFFECT,REASON_COST)
	e:SetLabel(g:GetFirst():GetLevel())
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc:HasLevel() end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_PZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,0,g,1,0,0)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		--Increase Level
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_RSCALE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end