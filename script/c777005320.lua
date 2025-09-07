--Witch of the Enchanted Forest
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--Link Summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.filter,2,nil,s.spcheck)
	--(1)Add 1 "Harmonic Synchro/Xyz/Fusion" Spell from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsLinkSummoned() end)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--(2)Set "Black and White Wave", then can attach
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetCondition(aux.zptcon(aux.FilterBoolFunction(Card.IsType,TYPE_XYZ)))
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
s.listed_names={7473735,777005270,777004070,31677606}
--Link Summon
function s.filter(c,lc,sumtype,tp)
	return not c:IsType(TYPE_TOKEN,lc,sumtype,tp)
end
function s.spcheck(g,lc,tp)
	return g:CheckSameProperty(Card.GetAttribute,lc,SUMMON_TYPE_LINK,tp)
end
--(1)Add 1 "Harmonic Synchro/Xyz/Fusion" Spell from your Deck to your hand
function s.thfilter(c)
	return (c:IsCode(7473735) or c:IsCode(777005270) or c:IsCode(777004070)) and c:IsAbleToHand()
end
function s.deckthfilter(c)
	return c:IsCode(7473735,777005270,777004070) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.deckthfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.deckthfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--(2)Set "Black and White Wave", then can attach
function s.attachfilter(c,tp)
	return c:IsType(TYPE_SYNCHRO) and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,c,tp)
end
function s.xyzfilter(c,mc,tp)
	return c:IsType(TYPE_XYZ) and c:IsFaceup() and mc:IsCanBeXyzMaterial(c,tp,REASON_EFFECT)
end
function s.setfilter(c)
	return c:IsCode(31677606) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		if Duel.SSet(tp,g) and Duel.IsExistingMatchingCard(s.attachfilter,tp,LOCATION_EXTRA,0,1,nil,tp) 
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
			local mc=Duel.SelectMatchingCard(tp,s.attachfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp):GetFirst()
		if not mc then return end
		Duel.HintSelection(mc)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local xyzc=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,mc,tp):GetFirst()
		if not xyzc:IsImmuneToEffect(e) then
			Duel.BreakEffect()
			Duel.Overlay(xyzc,mc)
		end
		end
	end
end