--Gemini Revelation
--Scripted by Copilot AI
local s,id=GetID()
function s.initial_effect(c)
    --(1)Search, then you can Normal Summon
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
--(1)Search, then you can Normal Summon
function s.costfilter(c)
    return c:IsType(TYPE_GEMINI) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function s.filter(c)
    return c:IsType(TYPE_GEMINI) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.fil2ter(c)
	return c:IsType(TYPE_GEMINI) and c:IsSummonable(true,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        Duel.ShuffleHand(tp)
        Duel.BreakEffect()
        if Duel.IsExistingMatchingCard(s.fil2ter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
			local f=Duel.SelectMatchingCard(tp,s.fil2ter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
				if #f>0 then
					Duel.Summon(tp,f:GetFirst(),true,nil)
				end		
		end
    end
end
