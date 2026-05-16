--Data Paladin Mission
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Each player can add	
	local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
--(1)Each player can add
function s.filter(c)
    return c:IsType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.yourfilter(c)
    return c:IsSetCard(0x265) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.yourfilter,tp,LOCATION_DECK,0,3,nil) and Duel.IsExistingMatchingCard(s.filter,1-tp,LOCATION_DECK,0,3,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,0,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsExistingMatchingCard(s.yourfilter,tp,LOCATION_DECK,0,3,nil) or not Duel.IsExistingMatchingCard(s.filter,1-tp,LOCATION_DECK,0,3,nil) then return end
    local g1=Duel.GetMatchingGroup(s.yourfilter,tp,LOCATION_DECK,0,nil)
    local g2=Duel.GetMatchingGroup(s.filter,1-tp,LOCATION_DECK,0,nil)
    if g1:GetCount()<3 or g2:GetCount()<3 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg1=g1:Select(tp,3,3,nil)
    Duel.ConfirmCards(1-tp,sg1)
    Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
    local sg2=g2:Select(1-tp,3,3,nil)
    Duel.ConfirmCards(tp,sg2)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local tc1=sg2:Select(tp,1,1,nil):GetFirst()
    Duel.SendtoHand(tc1,1-tp,REASON_EFFECT)
    Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
    local tc2=sg1:Select(1-tp,1,1,nil):GetFirst()
    Duel.SendtoHand(tc2,tp,REASON_EFFECT)
    Duel.ShuffleDeck(tp)
    Duel.ShuffleDeck(1-tp)
end
