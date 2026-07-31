-- Timerx Combat Researcher
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Requisitos da Invocação-Fusão: 2 monstros "Timerx"
    c:EnableReviveLimit()
    Fusion.AddProcMixN(c, true, true, aux.FilterBoolFunctionEx(Card.IsSetCard, 0x305), 2)

    -- Proteção 1: Não pode ser alvo de efeitos do oponente
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)

    -- Proteção 2: Não pode ser destruído por efeitos do oponente
    local e2 = e1:Clone()
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetValue(aux.indoval)
    c:RegisterEffect(e2)

    -- Efeito 3: Gatilho se monstro for Sp. Summoned do Déqui -> Remover pro fundo do déqui
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_TODECK)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id)
    e3:SetCondition(s.tdcon)
    e3:SetTarget(s.tdtg)
    e3:SetOperation(s.tdop)
    c:RegisterEffect(e3)

    -- Efeito 4: No Cemitério + Controlar Chronos -> Embaralhar 2 "Timerx" do GY -> Special Summon
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCountLimit(1, id + 1)
    e4:SetCondition(s.spcon)
    e4:SetCost(s.spcost)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end

-- ====================================================================
-- Efeito 3: Gatilho - Sp. Summon do Déqui
-- ====================================================================
function s.spfilter(c)
    -- Verifica se a invocação de alguma carta ocorreu saindo do déqui
    return c:IsPreviousLocation(LOCATION_DECK)
end

function s.tdcon(e, tp, eg, ep, ev, re, r, rp)
    -- Não pode ativar no Damage Step
    return not (Duel.GetCurrentPhase() == PHASE_DAMAGE or Duel.GetCurrentPhase() == PHASE_DAMAGE_CALC)
        and eg:IsExists(s.spfilter, 1, nil)
end

function s.tdtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(1 - tp) and chkc:IsOnField() and chkc:IsAbleToDeck() end
    if chk == 0 then return Duel.IsExistingTarget(Card.IsAbleToDeck, tp, 0, LOCATION_ONFIELD, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectTarget(tp, Card.IsAbleToDeck, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, 1, 0, 0)
end

function s.tdop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoDeck(tc, nil, SEQ_DECKBOTTOM, REASON_EFFECT)
    end
end

-- ====================================================================
-- Efeito 4: Reviver do GY (Custo de embaralhar 2)
-- ====================================================================
function s.chronosfilter(c)
    return c:IsFaceup() and c:GetOriginalCodeRule() == 777000640
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.chronosfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.costfilter(c)
    -- Pode ser monstro, magia ou armadilha ("Timerx" cards)
    return c:IsSetCard(0x305) and c:IsAbleToDeckAsCost()
end

function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingMatchingCard(s.costfilter, tp, LOCATION_GRAVE, 0, 2, c) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectMatchingCard(tp, s.costfilter, tp, LOCATION_GRAVE, 0, 2, 2, c)
    Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
    end
end