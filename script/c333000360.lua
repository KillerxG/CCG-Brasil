--Data Paladin Oath
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Search Level 4 "Data Paladin"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.srtg)
	e1:SetOperation(s.srop)
	c:RegisterEffect(e1)
end
--(1)Search Level 4 "Data Paladin"
function s.filter(c)
	return c:IsLevel(4) and c:IsSetCard(0x265) and c:IsAbleToHand()
end
function s.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.srop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local f=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #f>0 then
		Duel.SendtoHand(f,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,f)
	end
	if #g>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	s.announce_filter={TYPE_EXTRA,OPCODE_ISTYPE,OPCODE_NOT}
	local ac=Duel.AnnounceCard(tp,s.announce_filter)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
		Duel.ConfirmCards(tp,g)
		local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		local dg=g:Filter(Card.IsCode,nil,ac)		
		if g:IsExists(Card.IsCode,1,nil,ac) and #dg>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) then	--check if the declared card is in your opponent's hand		
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local j=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
				if #j>0 then
					Duel.SendtoHand(j,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-tp,j)
				end		
			if Duel.IsPlayerCanDraw(1-tp) and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND,1,e:GetHandler()) --allow opponent to redraw its hand
				and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then
				Duel.SetTargetPlayer(tp)
				Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
				Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
				--local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
				local j=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
					if #j==0 then return end
						Duel.SendtoDeck(j,1-tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
						Duel.ShuffleDeck(1-tp)
						Duel.BreakEffect()
						Duel.Draw(1-tp,#j,REASON_EFFECT)
			end
		end
		Duel.ShuffleHand(1-tp)
	end
end