-- Ruler of Timerx - Chronos
-- Scripted by Codex
--[[ Effects: 
	E0: Cannot be Normal Summoned/Set. This card's Divine Hierarchy Rank is 1.
	E1: Once per turn (Quick Effect): You can reveal 1 monster from your hand; shuffle it into the Deck, and if you do, negate the effect of 1 face-up card your opponent controls.
	E2: Once per turn: You can send 3 Fusion Monsters from your Extra Deck to the GY; increase this card's Hierarchy Rank by 1.
	E3: Once per turn, if this card would be destroyed by battle or card effect, you can shuffle 2 other monsters from your hand or field into the Deck instead.
	E4: Once per turn: You can target 1 card in your GY; add it to your hand.
]]
local s,id=GetID()
Duel.LoadScript("proc_divine_hierarchy_mod.lua")
function s.initial_effect(c)
	--Divine Hierarchy Rank 1
	DivineHierarchyMod.Register(c,1)
	--Cannot be Normal Summoned/Set
	c:EnableReviveLimit()
	--(1)Reveal 1 monster, shuffle it into the Deck, then negate an opponent's card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK|CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--(2)Send 3 Fusion Monsters from the Extra Deck to increase Hierarchy Rank
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.hrcost)
	e2:SetOperation(s.hrop)
	c:RegisterEffect(e2)
	--(3)Shuffle 2 other monsters into the Deck instead of destroying this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.desreptg)
	e3:SetOperation(s.desrepop)
	c:RegisterEffect(e3)
	--(4)Add 1 card from your GY to your hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
--(1)Reveal 1 monster, shuffle it into the Deck, then negate an opponent's card
function s.revealfilter(c)
	return c:IsMonster() and not c:IsPublic() and c:IsAbleToDeck()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.revealfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tc=Duel.SelectMatchingCard(tp,s.revealfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	e:SetLabelObject(tc)
end
function s.negfilter(c,e)
	return c:IsFaceup() and c:IsCanBeDisabledByEffect(e)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.negfilter,tp,0,LOCATION_ONFIELD,1,nil,e) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetLabelObject(),1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc or not tc:IsLocation(LOCATION_HAND) or not tc:IsControler(tp)
		or Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=1 then return end
	local g=Duel.GetMatchingGroup(s.negfilter,tp,0,LOCATION_ONFIELD,nil,e)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local nc=g:Select(tp,1,1,nil):GetFirst()
	if nc then
		nc:NegateEffects(e:GetHandler(),RESET_EVENT|RESETS_STANDARD)
	end
end
--(2)Send 3 Fusion Monsters from the Extra Deck to increase Hierarchy Rank
function s.fusionfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsAbleToGraveAsCost()
end
function s.hrcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.fusionfilter,tp,LOCATION_EXTRA,0,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.fusionfilter,tp,LOCATION_EXTRA,0,3,3,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.hrop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		DivineHierarchyMod.IncreaseRank(c,1,RESET_EVENT|RESETS_STANDARD)
	end
end
--(3)Shuffle 2 other monsters into the Deck instead of destroying this card
function s.repfilter(c)
	return c:IsMonster() and not c:IsStatus(STATUS_DESTROY_CONFIRMED) and c:IsAbleToDeck()
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE|REASON_EFFECT)
		and not c:IsReason(REASON_REPLACE)
		and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,2,c) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,2,2,c)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT|REASON_REPLACE)
end
--(4)Add 1 card from your GY to your hand
function s.thfilter(c)
	return c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,tc)
	end
end
