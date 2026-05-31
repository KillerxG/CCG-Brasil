-- Rockslash Fighter - Jones
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Special Summon da Mão (ou GY se controlar Haruna) ao ocorrer Dano de Efeito
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_DAMAGE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Efeito 2: Causar Dano baseado no número de monstros (Ignition Effect)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.damcon)
    e2:SetTarget(s.damtg)
    e2:SetOperation(s.damop)
    c:RegisterEffect(e2)
end

-- ====================================================================
-- Filtro Global da Haruna
-- ====================================================================
function s.harunafilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777002010
end

-- ====================================================================
-- Efeito 1: Special Summon (Mão ou GY) no Dano de Efeito (Main Phase)
-- ====================================================================
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    -- Verifica se estamos na Main Phase 1 ou Main Phase 2
    local ph = Duel.GetCurrentPhase()
    if ph ~= PHASE_MAIN1 and ph ~= PHASE_MAIN2 then return false end
    
    -- Verifica se o dano foi causado por um efeito
    return (r & REASON_EFFECT) ~= 0
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local in_gy = c:IsLocation(LOCATION_GRAVE)
    local has_haruna = Duel.IsExistingMatchingCard(s.harunafilter, tp, LOCATION_MZONE, 0, 1, nil)
    
    if chk == 0 then
        -- Se estiver no GY, é obrigatório ter a Haruna no campo
        if in_gy and not has_haruna then return false end
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
    end
end

-- ====================================================================
-- Efeito 2: Queimar a Vida baseado na quantidade de monstros no campo
-- ====================================================================
function s.damcon(e, tp, eg, ep, ev, re, r, rp)
    -- Só pode ativar se controlar a Haruna
    return Duel.IsExistingMatchingCard(s.harunafilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.damtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetFieldGroupCount(tp, LOCATION_MZONE, LOCATION_MZONE) > 0 end
    
    -- Conta todos os monstros de ambos os lados do campo
    local ct = Duel.GetFieldGroupCount(tp, LOCATION_MZONE, LOCATION_MZONE)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, ct * 200)
end

function s.damop(e, tp, eg, ep, ev, re, r, rp)
    -- Faz a contagem novamente na resolução para garantir precisão caso monstros tenham saído do campo
    local ct = Duel.GetFieldGroupCount(tp, LOCATION_MZONE, LOCATION_MZONE)
    if ct > 0 then
        Duel.Damage(1 - tp, ct * 200, REASON_EFFECT)
    end
end