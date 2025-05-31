--West Royal Dragon Travel
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Excavate and add to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--(2)Grant effect to "Weast Royal Dragon - Irya"
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
--(1)Excavate and add to hand
function s.thcostfilter(c)
	return c:IsRitualMonster() and not c:IsPublic()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.thcostfilter,tp,LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.thcostfilter,tp,LOCATION_HAND,0,1,1,c)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function s.tgfilter(c)
	return c:IsSetCard(0x288) and c:IsAbleToGrave() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,6) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c)
	return c:IsAbleToHand() and (c:IsRitualMonster() or c:IsRitualSpell())
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerCanDiscardDeck(tp,6) then return end
	Duel.ConfirmDecktop(tp,6)
	local g=Duel.GetDecktopGroup(tp,6)
	if #g>0 then
		Duel.DisableShuffleCheck()
		if g:IsExists(s.thfilter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:FilterSelect(tp,s.thfilter,1,1,nil)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
			Duel.ShuffleHand(tp)
			g:Sub(sg)
		end
		if Duel.SendtoGrave(g,REASON_EFFECT|REASON_EXCAVATE) and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g1=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		Duel.SendtoGrave(g1,REASON_EFFECT)
		end		
	end
end
--(2)Grant effect to "Weast Royal Dragon - Irya"
function s.eftg(e,c)
	return c:IsType(TYPE_EFFECT) and c:IsCode(777003710)
end