-- Timerx Anthropo-Scientist - Daisy
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Requisitos da Invocação-Fusão: 1 "Timerx" + 1 Psíquico ou Fusão
    c:EnableReviveLimit()
    Fusion.AddProcMix(c, true, true, aux.FilterBoolFunctionEx(Card.IsSetCard, 0x305), s.matfilter)

    -- Efeito 1: Se for Invocada por Fusão -> Enviar 1 Fusão do Extra Deck para o GY
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.excon)
    e1:SetTarget(s.extg)
    e1:SetOperation(s.exop)
    c:RegisterEffect(e1)

    -- Efeito 2: Embaralhar 1 "Timerx" da mão/GY pro déqui -> Setar Magia/Armadilha
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id + 1)
    e2:SetCost(s.setcost)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)

    -- Efeito 3: No GY, quando o oponente invoca por Special Summon -> Reviver e Remover
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TODECK)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, id + 2)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

-- ====================================================================
-- Requisitos de Materiais de Fusão (Psíquico ou Fusão)
-- ====================================================================
function s.matfilter(c, fc, sumtype, tp)
    return c:IsRace(RACE_PSYCHIC, fc, sumtype, tp) or c:IsType(TYPE_FUSION, fc, sumtype, tp)
end

-- ====================================================================
-- Efeito 1: Enviar Fusão para o Cemitério
-- ====================================================================
function s.excon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function s.exfilter(c)
    return c:IsType(TYPE_FUSION) and c:IsAbleToGrave()
end

function s.extg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.exfilter, tp, LOCATION_EXTRA, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_EXTRA)
end

function s.exop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.exfilter, tp, LOCATION_EXTRA, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoGrave(g, REASON_EFFECT)
    end
end

-- ====================================================================
-- Efeito 2: Setar Magia/Armadilha do Déqui (Custo de Embaralhar)
-- ====================================================================
function s.costfilter(c)
    return c:IsSetCard(0x305) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckAsCost()
end

function s.setcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.costfilter, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectMatchingCard(tp, s.costfilter, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, 1, nil)
    Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST)
end

function s.setfilter(c)
    return c:IsSetCard(0x305) and c:IsType(TYPE_SPELL + TYPE_TRAP) and c:IsSSetable()
end

function s.settg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.setfilter, tp, LOCATION_DECK, 0, 1, nil) end
end

function s.setop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
    local g = Duel.SelectMatchingCard(tp, s.setfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SSet(tp, g)
    end
end

-- ====================================================================
-- Efeito 3: Gatilho no Cemitério (Oponente Invoca) -> Reviver e Remover
-- ====================================================================
function s.chronosfilter(c)
    return c:IsFaceup() and c:GetOriginalCodeRule() == 777000640
end

function s.sumfilter(c, tp)
    return c:IsSummonPlayer(1 - tp)
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    -- Impede de ativar no Damage Step e checa a presença do Chronos e se oponente invocou
    return not (Duel.GetCurrentPhase() == PHASE_DAMAGE or Duel.GetCurrentPhase() == PHASE_DAMAGE_CALC)
        and eg:IsExists(s.sumfilter, 1, nil, tp)
        and Duel.IsExistingMatchingCard(s.chronosfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.tdfilter1(c, e_c)
    -- Aceita seu próprio monstro no campo ou no GY (evitando pegar a própria Daisy)
    return c:IsSetCard(0x305) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck() and c ~= e_c
        and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    -- Ignora a validação chkc dupla e lida manualmente abaixo
    if chkc then return false end 
    
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
            and Duel.IsExistingTarget(s.tdfilter1, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, 1, c, c)
            and Duel.IsExistingTarget(Card.IsAbleToDeck, tp, 0, LOCATION_MZONE, 1, nil)
    end
    
    -- Seleciona o alvo do seu lado
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g1 = Duel.SelectTarget(tp, s.tdfilter1, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, 1, 1, c, c)
    
    -- Seleciona o alvo do oponente
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g2 = Duel.SelectTarget(tp, Card.IsAbleToDeck, tp, 0, LOCATION_MZONE, 1, 1, nil)
    
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
    g1:Merge(g2)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, g1, 2, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    
    -- Exige que Daisy reviva com sucesso primeiro
    if not (c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0) then return end
    
    local g = Duel.GetTargetCards(e)
    if not g or #g == 0 then return end
    
    -- Separa os alvos usando os controladores lógicos
    local tc1 = g:Filter(Card.IsControler, nil, tp):GetFirst()
    local tc2 = g:Filter(Card.IsControler, nil, 1 - tp):GetFirst()
    
    -- "and if you do, shuffle the first target... then place the second target on the bottom"
    if tc1 and Duel.SendtoDeck(tc1, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) > 0 and tc1:IsLocation(LOCATION_DECK + LOCATION_EXTRA) then
        if tc2 then
            Duel.SendtoDeck(tc2, nil, SEQ_DECKBOTTOM, REASON_EFFECT)
        end
    end
end