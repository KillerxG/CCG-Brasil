-- Celestial Guardian's Sword
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Ativação da Magia de Equipamento
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetTarget(s.eqtg)
    e1:SetOperation(s.eqop)
    c:RegisterEffect(e1)

    -- Limite de Equipamento (Apenas "Celestial Guardian")
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EQUIP_LIMIT)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetValue(s.eqlimit)
    c:RegisterEffect(e2)

    -- Ganho de ATK
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_EQUIP)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetValue(500)
    c:RegisterEffect(e3)

    -- Efeito 1: Negar efeitos se enviada do campo para o GY
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_DISABLE)
    e4:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY | EFFECT_FLAG_CARD_TARGET)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetCountLimit(1, {id, 1})
    e4:SetCondition(s.negcon)
    e4:SetTarget(s.negtg)
    e4:SetOperation(s.negop)
    c:RegisterEffect(e4)

    -- Efeito 2: Retornar à mão do GY com 2 opções de custo
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 1))
    e5:SetCategory(CATEGORY_TOHAND)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_GRAVE)
    e5:SetCountLimit(1, {id, 2})
    e5:SetCost(s.thcost)
    e5:SetTarget(s.thtg)
    e5:SetOperation(s.thop)
    c:RegisterEffect(e5)
end

s.listed_series = {0x252}
s.listed_names = {id}

-- ==========================================================
-- Funções de Equipamento e Ganho
-- ==========================================================
function s.eqlimit(e, c)
    return c:IsSetCard(0x252)
end

function s.eqfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x252)
end

function s.eqtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.eqfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.eqfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
    Duel.SelectTarget(tp, s.eqfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_EQUIP, e:GetHandler(), 1, 0, 0)
end

function s.eqop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.Equip(tp, c, tc)
    end
end

-- ==========================================================
-- Efeito 1: Negar Cartas do Oponente
-- ==========================================================
function s.negcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end

function s.negtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(1 - tp) and chkc:IsOnField() and chkc:IsFaceup() end
    if chk == 0 then return Duel.IsExistingTarget(Card.IsFaceup, tp, 0, LOCATION_ONFIELD, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_NEGATE)
    local g = Duel.SelectTarget(tp, Card.IsFaceup, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_DISABLE, g, 1, 0, 0)
end

function s.negop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsDisabled() then
        Duel.NegateRelatedChain(tc, RESET_TURN_SET)
        
        -- Nega os efeitos bases
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT | RESETS_STANDARD | RESET_PHASE | PHASE_END)
        tc:RegisterEffect(e1)
        
        -- Nega as tentativas de ativação da carta em campo
        local e2 = Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetValue(RESET_TURN_SET)
        e2:SetReset(RESET_EVENT | RESETS_STANDARD | RESET_PHASE | PHASE_END)
        tc:RegisterEffect(e2)
        
        -- Cobertura necessária para resetar Trap Monsters [2]
        if tc:IsType(TYPE_TRAPMONSTER) then
            local e3 = Effect.CreateEffect(c)
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
            e3:SetReset(RESET_EVENT | RESETS_STANDARD | RESET_PHASE | PHASE_END)
            tc:RegisterEffect(e3)
        end
    end
end

-- ==========================================================
-- Efeito 2: Recuperar do GY para a Mão
-- ==========================================================
function s.rmfilter(c)
    return c:IsMonster() and c:IsAbleToRemoveAsCost()
end

function s.tdfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x252) and c:IsAbleToDeckAsCost()
end

function s.thcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local b1 = Duel.IsExistingMatchingCard(s.rmfilter, tp, LOCATION_GRAVE, 0, 2, nil)
    local b2 = Duel.IsExistingMatchingCard(s.tdfilter, tp, LOCATION_REMOVED, 0, 1, nil)
    if chk == 0 then return b1 or b2 end
    
    local op = 0
    if b1 and b2 then
        op = Duel.SelectOption(tp, aux.Stringid(id, 2), aux.Stringid(id, 3))
    elseif b1 then
        op = Duel.SelectOption(tp, aux.Stringid(id, 2))
    else
        op = Duel.SelectOption(tp, aux.Stringid(id, 3)) + 1
    end
    
    if op == 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
        local g = Duel.SelectMatchingCard(tp, s.rmfilter, tp, LOCATION_GRAVE, 0, 2, 2, nil)
        Duel.Remove(g, POS_FACEUP, REASON_COST)
    else
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
        local g = Duel.SelectMatchingCard(tp, s.tdfilter, tp, LOCATION_REMOVED, 0, 1, 1, nil)
        Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST)
    end
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToHand() end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, c, 1, 0, 0)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoHand(c, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, c)
    end
end