-- Lord of Shinigamis - Darkness
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Limite de Ressurreição e HOPT Global de Invocação Especial
    c:EnableReviveLimit()
    c:SetSPSummonOnce(id)

    -- Condição: Não pode ser Normal Summon/Set. Somente Special Summon por sua própria condição.
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetValue(aux.FALSE)
    c:RegisterEffect(e1)

    -- Procedimento de Invocação Especial (Da mão)
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_SPSUMMON_PROC)
    e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e2:SetRange(LOCATION_HAND)
    e2:SetCondition(s.spcon)
    c:RegisterEffect(e2)

    -- Efeito de Proteção (Indestrutível em Batalha e Efeitos se houver S/T baixada)
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    e3:SetCondition(s.protcon)
    e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard, 0x304))
    e3:SetValue(1)
    c:RegisterEffect(e3)
    local e4 = e3:Clone()
    e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    c:RegisterEffect(e4)

    -- Efeito Gatilho: Retorno de Spirit ou Tributo -> Pegar "Shinigami" do GY
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 0))
    e5:SetCategory(CATEGORY_TOHAND)
    e5:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
    e5:SetCode(EVENT_TO_HAND)
    e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(2)
    e5:SetCondition(s.thcon1)
    e5:SetTarget(s.thtg)
    e5:SetOperation(s.thop)
    c:RegisterEffect(e5)
    
    local e6 = e5:Clone()
    e6:SetCode(EVENT_RELEASE)
    e6:SetCondition(s.thcon2)
    c:RegisterEffect(e6)

    -- Efeito Rápido: Tributar 1 monstro
    local e7 = Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id, 1))
    e7:SetCategory(CATEGORY_RELEASE)
    e7:SetType(EFFECT_TYPE_QUICK_O)
    e7:SetCode(EVENT_FREE_CHAIN)
    e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e7:SetRange(LOCATION_MZONE)
    e7:SetCountLimit(1, id + 1)
    e7:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E)
    e7:SetTarget(s.reltg)
    e7:SetOperation(s.relop)
    c:RegisterEffect(e7)
end

-- ====================================================================
-- Condição de Special Summon da Mão
-- ====================================================================
function s.spfilter(c)
    return c:IsSetCard(0x304) and c:IsType(TYPE_MONSTER)
end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    -- Confere monstros Shinigami no Campo e Cemitério
    local g = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, nil)
    -- Verifica se existem pelo menos 3 nomes únicos e se há espaço no campo
    return g:GetClassCount(Card.GetCode) >= 3 and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
end

-- ====================================================================
-- Efeito Contínuo: Proteção (Blindagem Condicional)
-- ====================================================================
function s.setfilter(c)
    return c:IsFacedown() and c:IsType(TYPE_SPELL + TYPE_TRAP)
end

function s.protcon(e)
    -- Verifica se há qualquer Magia ou Armadilha Baixada no campo inteiro
    return Duel.IsExistingMatchingCard(s.setfilter, e:GetHandlerPlayer(), LOCATION_SZONE, LOCATION_SZONE, 1, nil)
end

-- ====================================================================
-- Gatilho de Recuperação do GY
-- ====================================================================
function s.thcfilter1(c)
    -- Spirit retornando para a mão
    return c:IsType(TYPE_SPIRIT)
end

function s.thcon1(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.thcfilter1, 1, nil)
end

function s.thcfilter2(c)
    -- Qualquer monstro sendo tributado
    return c:IsType(TYPE_MONSTER)
end

function s.thcon2(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.thcfilter2, 1, nil)
end

function s.thtgfilter(c)
    return c:IsSetCard(0x304) and c:IsAbleToHand()
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thtgfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.thtgfilter, tp, LOCATION_GRAVE, 0, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectTarget(tp, s.thtgfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, 0)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc, nil, REASON_EFFECT)
    end
end

-- ====================================================================
-- Efeito Rápido: Alvejar e Tributar
-- ====================================================================
function s.reltg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc ~= c and chkc:IsReleasableByEffect() end
    if chk == 0 then return Duel.IsExistingTarget(Card.IsReleasableByEffect, tp, LOCATION_MZONE, LOCATION_MZONE, 1, c) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
    -- Seleciona qualquer outro monstro no campo
    local g = Duel.SelectTarget(tp, Card.IsReleasableByEffect, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, c)
    Duel.SetOperationInfo(0, CATEGORY_RELEASE, g, 1, 0, 0)
end

function s.relop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Release(tc, REASON_EFFECT)
    end
end