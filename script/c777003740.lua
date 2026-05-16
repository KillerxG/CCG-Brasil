--West Royal Dragon Instructions
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --(1)Search
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE+CATEGORY_DECKDES)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
	--(2)Grant effect to "Weast Royal Dragon - Irya"
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE | PHASE_END)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.eptg)
    e2:SetOperation(s.epop)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetTargetRange(LOCATION_MZONE, 0)
    e3:SetTarget(s.eftg)
    e3:SetLabelObject(e2)
    c:RegisterEffect(e3)
end
--(1)Search
function s.thfilter(c)
    return c:IsSetCard(0x288) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.tgfilter(c)
    return c:IsSetCard(0x288) and not c:IsCode(id) and c:IsAbleToGrave()
end
function s.atkfilter(c)
    return c:IsFaceup() and c:GetAttack()>=2000
end
function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    Duel.SetPossibleOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
end
function s.operation(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 and Duel.SendtoHand(g, nil, REASON_EFFECT) > 0 then
        Duel.ConfirmCards(1-tp, g)
        local opp_monsters = Duel.IsExistingMatchingCard(s.atkfilter, tp, 0, LOCATION_MZONE, 1, nil)
        local can_tg = Duel.IsExistingMatchingCard(s.tgfilter, tp, LOCATION_DECK, 0, 1, nil)
        if opp_monsters and can_tg and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
            Duel.BreakEffect() 
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
            local tg = Duel.SelectMatchingCard(tp, s.tgfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
            if #tg > 0 then
                Duel.SendtoGrave(tg, REASON_EFFECT)
            end
        end
    end
end
--(2)Grant effect to "Weast Royal Dragon - Irya"
function s.eftg(e, c)
    return c:IsFaceup() and c:IsCode(777003710) and c:IsType(TYPE_EFFECT)
end
function s.gyfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x288) and c:IsAbleToGrave()
end
function s.eptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.gyfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.gyfilter, tp, LOCATION_REMOVED, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectTarget(tp, s.gyfilter, tp, LOCATION_REMOVED, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g, 1, 0, 0)
end
function s.epop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc, REASON_EFFECT | REASON_RETURN) > 0 and tc:IsLocation(LOCATION_GRAVE) then
        if c:IsRelateToEffect(e) and c:IsFaceup() then
            Duel.BreakEffect()
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(500)
            e1:SetReset(RESET_EVENT | RESETS_STANDARD_DISABLE)
            c:RegisterEffect(e1)
        end
    end
end
