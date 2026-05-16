-- Time to Invest
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Ativação da Magia Contínua
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- Efeito 1: Invocar 1 Nível 1 do Deck (Negar se for de Efeito)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1, {id, 1})
    e2:SetTarget(s.sptg1)
    e2:SetOperation(s.spop1)
    c:RegisterEffect(e2)

    -- Efeito 2: Invocar 1 Monstro Normal da mão se o oponente tiver o maior ATK
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1, {id, 2})
    e3:SetCondition(s.spcon2)
    e3:SetTarget(s.sptg2)
    e3:SetOperation(s.spop2)
    c:RegisterEffect(e3)
end

-- ==========================================================
-- Efeito 1: Special Summon Nível 1 do Deck
-- ==========================================================
function s.spfilter1(c, e, tp)
    return c:IsLevel(1) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.sptg1(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingMatchingCard(s.spfilter1, tp, LOCATION_DECK, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end

function s.spop1(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.spfilter1, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
    local tc = g:GetFirst()
    
    -- O uso de SpecialSummonStep e Complete garante que o monstro sofra a negação no exato momento da aterrissagem
    if tc and Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP) then
        if tc:IsType(TYPE_EFFECT) then
            local c = e:GetHandler()
            
            -- Nega os efeitos da carta em campo
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT | RESETS_STANDARD)
            tc:RegisterEffect(e1)
            
            -- Nega os efeitos que a carta tentar ativar
            local e2 = Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetReset(RESET_EVENT | RESETS_STANDARD)
            tc:RegisterEffect(e2)
        end
        Duel.SpecialSummonComplete()
    end
end

-- ==========================================================
-- Efeito 2: Checar Maior ATK e Invocar Normal da Mão
-- ==========================================================
function s.spcon2(e, tp, eg, ep, ev, re, r, rp)
    -- Coleta todos os monstros virados para cima em ambos os campos
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
    if #g == 0 then return false end
    
    -- Extrai uma matriz apenas com os monstros que estão empatados no topo do valor de ATK atual
    local maxg = g:GetMaxGroup(Card.GetAttack)
    
    -- Checa se o oponente (1 - tp) controla pelo menos 1 membro desse grupo empatado no topo
    return maxg:IsExists(Card.IsControler, 1, nil, 1 - tp)
end

function s.spfilter2(c, e, tp)
    return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.sptg2(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingMatchingCard(s.spfilter2, tp, LOCATION_HAND, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND)
end

function s.spop2(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.spfilter2, tp, LOCATION_HAND, 0, 1, 1, nil, e, tp)
    if #g > 0 then
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
    end
end