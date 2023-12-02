--Avatar of the End
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Link Material
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)
	--(1)Add 1 "Idrakian" card from the Deck to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--(2)Cannot be Link Material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
--Link Material
function s.matfilter(c,scard,sumtype,tp)
	return c:IsType(TYPE_MONSTER)
end
--(1)Add 1 "Idrakian" card from the Deck to the hand
local key=TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP
function s.cfilter(c,tp)
	return c:IsSetCard(0x313) and not c:IsPublic()
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetType())
end
function s.thfilter(c,ctype)
	return c:IsSetCard(0x313) and c:IsAbleToHand() and not c:IsType(ctype&key)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,tp) 
		and e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	local rc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	Duel.ConfirmCards(1-tp,rc)
	Duel.ShuffleHand(tp)
	e:SetLabelObject(rc)
	Duel.SetTargetCard(rc)
	
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetLabelObject()
	if not rc:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,rc:GetType())
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
	end
end