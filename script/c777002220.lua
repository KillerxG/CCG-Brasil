--Northern Guild Preparation
--Scripted by KillerxG
local s, id = GetID()
function s.initial_effect(c)
    --(1)Activate: Foolish, ATK Up, Draw
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end
--(1)Activate: Foolish, ATK Up, Draw
function s.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return false end
    local b1 = Duel.GetFlagEffect(tp, id) == 0 and s.tg1(e, tp, eg, ep, ev, re, r, rp, 0)
    local b2 = Duel.GetFlagEffect(tp, id + 1) == 0 and s.tg2(e, tp, eg, ep, ev, re, r, rp, 0)
    local b3 = Duel.GetFlagEffect(tp, id + 2) == 0 and s.tg3(e, tp, eg, ep, ev, re, r, rp, 0)
    if chk == 0 then return b1 or b2 or b3 end
    local ops = {}
    local opval = {}
    if b1 then table.insert(ops, aux.Stringid(id, 0)); table.insert(opval, 1) end
    if b2 then table.insert(ops, aux.Stringid(id, 1)); table.insert(opval, 2) end
    if b3 then table.insert(ops, aux.Stringid(id, 2)); table.insert(opval, 3) end
    local select = Duel.SelectOption(tp, table.unpack(ops))
    local op = opval[select + 1]
    e:SetLabel(op)
    Duel.RegisterFlagEffect(tp, id + (op - 1), RESET_PHASE | PHASE_END, 0, 1)
    if op == 1 then
        e:SetCategory(CATEGORY_TOGRAVE)
        e:SetProperty(0)
        s.tg1(e, tp, eg, ep, ev, re, r, rp, 1)
    elseif op == 2 then
        e:SetCategory(CATEGORY_ATKCHANGE)
        e:SetProperty(0)
        s.tg2(e, tp, eg, ep, ev, re, r, rp, 1)
    elseif op == 3 then
        e:SetCategory(CATEGORY_TODECK | CATEGORY_DRAW)
        e:SetProperty(0)
        s.tg3(e, tp, eg, ep, ev, re, r, rp, 1)
    end
end
function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local op = e:GetLabel()
    if op == 1 then
        s.op1(e, tp, eg, ep, ev, re, r, rp)
    elseif op == 2 then
        s.op2(e, tp, eg, ep, ev, re, r, rp)
    elseif op == 3 then
        s.op3(e, tp, eg, ep, ev, re, r, rp)
    end
end
--Foolish
function s.tgfilter(c)
    return c:IsSetCard(0x280) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end

function s.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.tgfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
end
function s.op1(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.tgfilter, tp, LOCATION_DECK, 0, 1, 1, nil)    
    if #g > 0 and Duel.SendtoGrave(g, REASON_EFFECT) > 0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
        local has_field = Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, 777002610), tp, LOCATION_ONFIELD, 0, 1, nil)        
        if has_field and Duel.IsExistingMatchingCard(s.tgfilter, tp, LOCATION_DECK, 0, 1, nil) then
            if Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
                local sg = Duel.SelectMatchingCard(tp, s.tgfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
                if #sg > 0 then
                    Duel.SendtoGrave(sg, REASON_EFFECT)
                end
            end
        end
    end
end
--ATK Up
function s.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard, 0x280), tp, LOCATION_MZONE, 0, 1, nil) end
end
function s.op2(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard, 0x280), tp, LOCATION_MZONE, 0, nil)
    for tc in aux.Next(g) do
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(1000)
        e1:SetReset(RESET_EVENT | RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end
end
--Draw 1
function s.revfilter(c)
    return c:IsSetCard(0x280) and c:IsType(TYPE_MONSTER) and not c:IsPublic() and c:IsAbleToDeck()
end
function s.tg3(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.revfilter, tp, LOCATION_HAND, 0, 1, nil)
        and Duel.IsPlayerCanDraw(tp, 1) end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_HAND)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end
function s.op3(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local g = Duel.SelectMatchingCard(tp, s.revfilter, tp, LOCATION_HAND, 0, 1, 1, nil)    
    if #g > 0 then
        Duel.ConfirmCards(1 - tp, g)
        if Duel.SendtoDeck(g, nil, SEQ_DECKBOTTOM, REASON_EFFECT) > 0 and g:GetFirst():IsLocation(LOCATION_DECK) then
            Duel.BreakEffect()
            Duel.Draw(tp, 1, REASON_EFFECT)
        end
    end
end