--Theationist Demonstration
local s,id=GetID()
function s.initial_effect(c)
	--(1)Search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DICE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
--(1)Search
s.roll_dice=true
function s.filter(c)
	return c:IsSetCard(0x264) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.fil2ter(c)
	return (c.toss_coin or c.roll_dice or c:IsSetCard(0x264)) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp,1) or Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) or Duel.IsExistingMatchingCard(s.fil2ter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.TossDice(tp,1)
	if Duel.IsPlayerCanDraw(1-tp,1) and (d==1 or d==2) then
		Duel.Draw(1-tp,1,REASON_EFFECT)
	elseif Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) and (d==3 or d==4) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
			if #g>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
	elseif Duel.IsExistingMatchingCard(s.fil2ter,tp,LOCATION_DECK,0,1,nil) and (d==5 or d==6) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.fil2ter,tp,LOCATION_DECK,0,1,1,nil)
			if #g>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
	end
end
