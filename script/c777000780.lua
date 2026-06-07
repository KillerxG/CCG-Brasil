--Draconic Preassure
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Add 1 "Draconic" monster from your Deck to your hand, then if you banished a card to the GY at activation, you can Set 1 "Draconic" Spell/Trap from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--(2)Banish 1 Dragon or FIRE
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,3))
    e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.gycon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.gytg)
    e2:SetOperation(s.gyop)
    c:RegisterEffect(e2)
end
--(1)Add 1 "Draconic" monster from your Deck to your hand, then if you banished a card to the GY at activation, you can Set 1 "Draconic" Spell/Trap from your Deck
function s.costfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToRemoveAsCost()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local with_cost=Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_EXTRA,0,1,c)
	if with_cost and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_EXTRA,0,1,1,c)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.thfilter(c)
	return c:IsSetCard(0x300) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetTargetParam(e:GetLabel())
	e:SetLabel(0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.setfilter(c)
	return c:IsSetCard(0x300) and c:IsSpellTrap() and c:IsSSetable() and not c:IsCode(id)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		if Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)==1 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local sg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #sg>0 then
				Duel.BreakEffect()
				Duel.SSet(tp,sg)
			end
		end
	end
end
--(2)Banish 1 Dragon or FIRE
function s.draconicfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x300)
end
function s.blazefilter(c)
    return c:IsFaceup() and c:GetOriginalCode()==777000680
end
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.draconicfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.rmfilter(c)
    return (c:IsRace(RACE_DRAGON) or c:IsAttribute(ATTRIBUTE_FIRE)) and c:IsAbleToRemove()
end
function s.thfilter(c)
    return c:IsSetCard(0x300) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end    
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)    
    if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
        if Duel.IsExistingMatchingCard(s.blazefilter,tp,LOCATION_MZONE,0,1,nil) then
            local thg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,nil)
            if #thg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
                local sg=thg:Select(tp,1,1,nil)
                if #sg>0 then
                    Duel.SendtoHand(sg,nil,REASON_EFFECT)
                    Duel.ConfirmCards(1-tp,sg)
                end
            end
        end
    end
end