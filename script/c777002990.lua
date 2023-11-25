--Promised Land, Storyteller
--scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
--(1)Search
function s.thfilter(c)
	return c:IsSetCard(0x278) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) 
		and Duel.IsPlayerCanDiscardDeck(tp,4) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,4)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.DiscardDeck(tp,4,REASON_EFFECT)
		if Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			local f=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_GRAVE,0,nil)
			local tc=f:GetFirst()
				for tc in aux.Next(f) do
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_ADD_SETCODE)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
					e1:SetValue(0x278)
					tc:RegisterEffect(e1)
				end
		end
	end
end
