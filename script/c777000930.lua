--Tribal Warrior of the Savage Star
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Search Feast of the Wild LV5
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--(2)Add bottom card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.th2con)
	e2:SetTarget(s.th2tg)
	e2:SetOperation(s.th2op)
	c:RegisterEffect(e2)
end
--(1)Search Feast of the Wild LV5
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.thfilter1(c)
	return c:IsCode(55416843) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=Duel.GetFirstMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,nil)
	if tg then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg)
	end
end
--(2)Add bottom card
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and (c:IsType(TYPE_FUSION) or c:IsType(TYPE_LINK))
end
function s.th2con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.th2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local sc=Duel.GetMatchingGroup(Card.IsSequence,tp,LOCATION_DECK,0,nil,0):GetFirst()
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=2 and sc and sc:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.th2op(e,tp,eg,ep,ev,re,r,rp)
	local sc=Duel.GetMatchingGroup(Card.IsSequence,tp,LOCATION_DECK,0,nil,0):GetFirst()
	if sc:IsAbleToHand() and Duel.SendtoHand(sc,nil,REASON_EFFECT)>0 then
		local dg=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
		if #dg<=1 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local bg=dg:Select(tp,1,1,nil)
		Duel.ShuffleDeck(tp)
		Duel.BreakEffect()
		Duel.MoveToDeckBottom(bg)
	else
		Duel.SendtoGrave(sc,REASON_RULE)
	end
end