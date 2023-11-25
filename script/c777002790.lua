--Promised Land, Lumino
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),2,2,s.lcheck)
	--(1)Send 1 monster to the GY and set 1 "Promised Land" Spell/Trap
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
--Link Summon
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0x278)
end
--(1)Send 1 monster to the GY and set 1 "Promised Land" Spell/Trap
function s.tgfilter(c,tp)
	return c:IsSetCard(0x278) and c:IsMonster() and c:IsAbleToGrave()
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,c)
end
function s.setfilter(c)
	return c:IsSetCard(0x278) and c:IsSpellTrap() and c:IsSSetable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #g==0 then return end
	Duel.SendtoGrave(g,REASON_EFFECT)
	local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #og>0 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if tc then
			Duel.BreakEffect()
			if Duel.SSet(tp,tc) and Duel.IsPlayerCanDiscardDeck(tp,2) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
				Duel.DiscardDeck(tp,2,REASON_EFFECT)
			end
		end
	end
end
