-- Draconic Lancer
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Dano Perfurante para monstros "Draconic" (Condição: Blaze no campo)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_PIERCE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetCondition(s.pcon)
    e1:SetTarget(s.ptg)
    c:RegisterEffect(e1)

    -- Efeito 2: On Summon -> Embaralhar Dragão ou Buscar Spell/Trap
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TODECK + CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
    local e3 = e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    -- Efeito 3: Ignition -> Banir Dragão do ED, Negar Efeito e Zerar ATK/DEF
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_DISABLE + CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1, id + 1)
    e4:SetCost(s.negcost)
    e4:SetTarget(s.negtg)
    e4:SetOperation(s.negop)
    c:RegisterEffect(e4)
end

-- ====================================================================
-- Efeito 1: Dano Perfurante Global
-- ====================================================================
function s.blazefilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777000680
end

function s.pcon(e)
    return Duel.IsExistingMatchingCard(s.blazefilter, e:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, nil)
end

function s.ptg(e, c)
    return c:IsSetCard(0x300)
end

-- ====================================================================
-- Efeito 2: Opção de Reciclar Dragão ou Buscar Magia/Armadilha
-- ====================================================================
function s.tdfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAbleToDeck()
end

function s.thfilter(c)
    return c:IsSetCard(0x300) and c:IsType(TYPE_SPELL + TYPE_TRAP) and c:IsAbleToHand()
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    local b1 = Duel.IsExistingMatchingCard(s.tdfilter, tp, LOCATION_REMOVED, 0, 1, nil)
    local b2 = Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil)
    
    if chk == 0 then return b1 or b2 end
    
    local op = 0
    if b1 and b2 then
        op = Duel.SelectOption(tp, aux.Stringid(id, 2), aux.Stringid(id, 3))
    elseif b1 then
        op = Duel.SelectOption(tp, aux.Stringid(id, 2))
    else
        op = Duel.SelectOption(tp, aux.Stringid(id, 3)) + 1
    end
    e:SetLabel(op)
    
    if op == 0 then
        Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_REMOVED)
    else
        Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    end
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local op = e:GetLabel()
    if op == 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
        local g = Duel.SelectMatchingCard(tp, s.tdfilter, tp, LOCATION_REMOVED, 0, 1, 1, nil)
        if #g > 0 then
            Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
        end
    else
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
        if #g > 0 then
            Duel.SendtoHand(g, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, g)
        end
    end
end

-- ====================================================================
-- Efeito 3: Negar Alvo e Zerar Status (Ignition)
-- ====================================================================
function s.costfilter(c)
    return c:IsRace(RACE_DRAGON) and c:IsAbleToRemoveAsCost()
end

function s.negcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.costfilter, tp, LOCATION_EXTRA, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, s.costfilter, tp, LOCATION_EXTRA, 0, 1, 1, nil)
    Duel.Remove(g, POS_FACEUP, REASON_COST)
end

function s.negfilter(c)
    return c:IsFaceup()
end

function s.negtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(1 - tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.negfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.negfilter, tp, 0, LOCATION_ONFIELD, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_NEGATE)
    local g = Duel.SelectTarget(tp, s.negfilter, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_DISABLE, g, 1, 0, 0)
end

function s.negop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    
    if tc and tc:IsFaceup() and not tc:IsDisabled() and tc:IsRelateToEffect(e) then
        Duel.NegateRelatedChain(tc, RESET_TURN_SET)
        
        -- Negar os Efeitos
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(e1)
        local e2 = Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e2:SetValue(RESET_TURN_SET)
        e2:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(e2)
        
        -- "and if you do, its ATK/DEF become 0 if it is a monster"
        if tc:IsType(TYPE_MONSTER) and not tc:IsImmuneToEffect(e1) then
            local e3 = Effect.CreateEffect(c)
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_SET_ATTACK_FINAL)
            e3:SetValue(0)
            e3:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(e3)
            local e4 = Effect.CreateEffect(c)
            e4:SetType(EFFECT_TYPE_SINGLE)
            e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
            e4:SetValue(0)
            e4:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(e4)
        end
    end
end