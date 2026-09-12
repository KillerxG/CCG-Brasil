-- Leader of Phantom Gunners - Killer
-- Scripted by Codex
--[[ Effects:
	E0: Cannot be Normal Summoned/Set. This card's Divine Hierarchy Rank is 1.
	E1: Once per turn, if this card would be destroyed by battle or card effect, you can send the top 5 cards of your Deck to the GY instead.
	E2: Once per turn, if your opponent activated a monster effect: You can send the top 5 cards of your opponent's Deck to the GY.
	E3: Once per turn: You can send 6 other cards you control to the GY, and if you do, increase this card's Hierarchy Rank by 1.
	E4: Once per turn (Quick Effect): You can target 1 card your opponent controls; send it to the GY, then you can send the top 5 cards of your opponent's Deck to the GY.
]]
local s,id=GetID()
Duel.LoadScript("proc_divine_hierarchy_mod.lua")
function s.initial_effect(c)
	DivineHierarchyMod.Register(c,1)
	c:EnableReviveLimit()
	--(1)Send the top 5 cards of your Deck instead of destroying this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.desreptg)
	e1:SetOperation(s.desrepop)
	c:RegisterEffect(e1)
	--(2)Send the top 5 cards of the opponent's Deck after they activate a monster effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.millcon)
	e2:SetTarget(s.milltg)
	e2:SetOperation(s.millop)
	c:RegisterEffect(e2)
	--(3)Send 6 other cards you control to increase this card's Hierarchy Rank
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.hrtg)
	e3:SetOperation(s.hrop)
	c:RegisterEffect(e3)
	--(4)Send 1 opponent's card to the GY, then optionally mill 5 cards
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_TOGRAVE|CATEGORY_DECKDES)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e4:SetTarget(s.tgtg)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)
end
--(1)Send the top 5 cards of your Deck instead of destroying this card
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE|REASON_EFFECT)
		and not c:IsReason(REASON_REPLACE) and Duel.IsPlayerCanDiscardDeck(tp,5) end
	return Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,0))
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(tp,5,REASON_EFFECT|REASON_REPLACE)
end
--(2)Send the top 5 cards of the opponent's Deck after they activate a monster effect
function s.millcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsMonsterEffect()
end
function s.milltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(1-tp,5) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,5)
end
function s.millop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerCanDiscardDeck(1-tp,5) then
		Duel.DiscardDeck(1-tp,5,REASON_EFFECT)
	end
end
--(3)Send 6 other cards you control to increase this card's Hierarchy Rank
function s.hrfilter(c)
	return c:IsAbleToGrave()
end
function s.hrtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.hrfilter,tp,LOCATION_ONFIELD,0,6,c) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,6,tp,LOCATION_ONFIELD)
end
function s.hrop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.hrfilter,tp,LOCATION_ONFIELD,0,c)
	if #g<6 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:Select(tp,6,6,nil)
	if Duel.SendtoGrave(sg,REASON_EFFECT)==6
		and sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)==6
		and c:IsRelateToEffect(e) and c:IsFaceup() then
		DivineHierarchyMod.IncreaseRank(c,1,RESET_EVENT|RESETS_STANDARD)
	end
end
--(4)Send 1 opponent's card to the GY, then optionally mill 5 cards
function s.tgfilter(c)
	return c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,5)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e)
		or Duel.SendtoGrave(tc,REASON_EFFECT)==0 or not tc:IsLocation(LOCATION_GRAVE) then return end
	if Duel.IsPlayerCanDiscardDeck(1-tp,5)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		Duel.DiscardDeck(1-tp,5,REASON_EFFECT)
	end
end
