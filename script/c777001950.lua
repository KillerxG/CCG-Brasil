-- Warbeast Combat Tactics
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- [Ativação Básica da Magia Contínua]
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- Efeito 1: Dano Perfurante (Piercing) para monstros "Warbeast"
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_PIERCE)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard, 0x308))
    c:RegisterEffect(e1)

    -- Efeito 2: Special Summon do Deck (Se ativada neste turno)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.spcon)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    -- Efeito 3a: Retornar para a mão do Campo (Brenda)
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1, id + 1)
    e3:SetCondition(s.brendacon)
    e3:SetTarget(s.thtg1)
    e3:SetOperation(s.thop1)
    c:RegisterEffect(e3)

    -- Efeito 3b: Adicionar do GY para a mão (Brenda)
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCountLimit(1, id + 1)
    e4:SetCondition(s.brendacon)
    e4:SetCost(s.thcost2)
    e4:SetTarget(s.thtg2)
    e4:SetOperation(s.thop2)
    c:RegisterEffect(e4)
end

-- ====================================================================
-- Efeito 2: Special Summon
-- ====================================================================
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    -- Checa se o turno atual é o mesmo turno em que a carta foi ativada (colocada com a face para cima)
    return e:GetHandler():GetTurnID() == Duel.GetTurnCount()
end

function s.dcfilter(c)
    return c:IsSetCard(0x308) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end

function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.dcfilter, tp, LOCATION_HAND, 0, 1, nil) end
    Duel.DiscardHand(tp, s.dcfilter, 1, 1, REASON_COST + REASON_DISCARD)
end

function s.spfilter(c, e, tp)
    return c:IsSetCard(0x308) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_DECK, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
    local tc = g:GetFirst()
    
    if tc and Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        -- Injeta a restrição diretamente no monstro Invocado!
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetDescription(aux.Stringid(id, 3)) -- String 3: "Cannot Special Summon from Extra Deck..."
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
        e1:SetRange(LOCATION_MZONE)
        e1:SetTargetRange(1, 0)
        e1:SetTarget(s.splimit)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(e1, true)
    end
end

function s.splimit(e, c, sump, sumtype, sumpos, targetp, se)
    return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x308)
end

-- ====================================================================
-- Filtro da Brenda
-- ====================================================================
function s.brfilter(c)
    -- Checa se existe a Brenda (ID 777001840) pelo nome original no campo
    return c:IsFaceup() and c:GetOriginalCode() == 777001840
end

function s.brendacon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.brfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

-- ====================================================================
-- Efeito 3a: Retornar do Campo para a Mão
-- ====================================================================
function s.thtg1(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsAbleToHand() end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
end

function s.thop1(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoHand(c, nil, REASON_EFFECT)
    end
end

-- ====================================================================
-- Efeito 3b: Adicionar do GY para a Mão
-- ====================================================================
function s.thcost2(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, nil) end
    Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1, REASON_COST + REASON_DISCARD)
end

function s.thtg2(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsAbleToHand() end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
end

function s.thop2(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoHand(c, nil, REASON_EFFECT)
    end
end