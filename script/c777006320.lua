--Earthbound Servant Geo Hound
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--Synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_DARK_TUNER),1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--(1)Unaffected by your opponent's activated Spell/Trap effects and by activated effects from opponent's monsters whose original Level/Rank is lower than this card's current Level
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.immval)
	c:RegisterEffect(e1)
	--(2)Search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--(3)Banish
	local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_REMOVE + CATEGORY_RECOVER)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id+1)
    e3:SetCondition(s.rmcon)
    e3:SetTarget(s.rmtg)
    e3:SetOperation(s.rmop)
    c:RegisterEffect(e3)
end
--(1)Unaffected by your opponent's activated Spell/Trap effects and by activated effects from opponent's monsters whose original Level/Rank is lower than this card's current Level
function s.immval(e,te)
	if not (te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActivated()) then return false end
	if te:IsSpellTrapEffect() then return true end
	local tc=te:GetHandler()
	local lv=e:GetHandler():GetLevel()
	if tc:HasLevel() then
		return tc:GetOriginalLevel()<lv
	elseif tc:HasRank() then
		return tc:GetOriginalRank()<lv
	elseif tc:IsLinkMonster() then
		return tc:IsLinkBelow(lv-1)
	end
	return false
end
--(2)Search
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ( c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and rp==1-tp) ) 
end
function s.thfilter1(c)
    return c:IsSetCard(SET_EARTHBOUND_IMMORTAL) and c:IsLevel(10) and c:IsMonster() and c:IsAbleToHand()
end
function s.thfilter2(c)
    return c:IsCode(45836982,67987302,777005890) and c:IsAbleToHand()
end
function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)    
    if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter1, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end
function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)    
    local g1 = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.thfilter1), tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)    
    if #g1 > 0 and Duel.SendtoHand(g1, nil, REASON_EFFECT) > 0 and g1:GetFirst():IsLocation(LOCATION_HAND) then
        Duel.ConfirmCards(1 - tp, g1)
        local g2 = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter2), tp, LOCATION_DECK + LOCATION_GRAVE, 0, nil)
        if #g2 > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)            
            local sg = g2:Select(tp, 1, 1, nil)
            if #sg > 0 then
                Duel.SendtoHand(sg, nil, REASON_EFFECT)
                Duel.ConfirmCards(1 - tp, sg)
            end
        end
    end
end
--(3)Banish
function s.cfilter(c, tp)
    return c:IsControler(1 - tp)
end
function s.rmcon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.cfilter, 1, nil, tp)
end
function s.rmtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1 - tp) and chkc:IsAbleToRemove() end
    if chk == 0 then return Duel.IsExistingTarget(Card.IsAbleToRemove, tp, 0, LOCATION_GRAVE, 1, nil) end    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectTarget(tp, Card.IsAbleToRemove, tp, 0, LOCATION_GRAVE, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, 1, 0, 0)
end
function s.rmop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()    
    if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc, POS_FACEUP, REASON_EFFECT) > 0 then
        if tc:IsLocation(LOCATION_REMOVED) and tc:IsType(TYPE_MONSTER) then
            local atk = tc:GetBaseAttack()
            if atk > 0 then
                Duel.BreakEffect()
                Duel.Recover(tp, atk, REASON_EFFECT)
            end
        end
    end
end