-- Warbeast Gladiator
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- [Invocação Sincro]
    -- 1 Tuner (ou 1 Warbeast) + 1+ não-Tuner "Warbeast"
    Synchro.AddProcedure(c, s.tfilter, 1, 1, Synchro.NonTuner(s.ntfilter), 1, 99)
    c:EnableReviveLimit()

    -- Efeito 1: Pode atacar duas vezes
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_EXTRA_ATTACK)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- Efeito 2: Resposta ao Descarte (Oponente escolhe Descartar ou Destruir)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_HANDES+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.discon)
    e2:SetTarget(s.distg)
    e2:SetOperation(s.disop)
    c:RegisterEffect(e2)
    -- Proteção de Gatilho: Caso um "Macro Cosmos" esteja em campo, o descarte bane a carta
    local e3 = e2:Clone()
    e3:SetCode(EVENT_REMOVE)
    c:RegisterEffect(e3)

    -- Efeito 3: Special Summon do GY se controlar a Brenda
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCountLimit(1, id+1)
    e4:SetCondition(s.spcon)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end

-- ====================================================================
-- Filtros do Sincro
-- ====================================================================
function s.tfilter(c, sc, st, tp)
    -- Aceita qualquer Tuner OU qualquer monstro "Warbeast" (0x308)
    return c:IsType(TYPE_TUNER, sc, st, tp) or c:IsSetCard(0x308, sc, st, tp)
end

function s.ntfilter(c, sc, st, tp)
    -- Exige monstros não-Tuner da família "Warbeast"
    return c:IsSetCard(0x308, sc, st, tp)
end

-- ====================================================================
-- Efeito 2: Descarte/Destruição
-- ====================================================================
function s.cfilter(c)
    -- Checa se a razão de a carta ter sido movida foi por descarte
    return c:IsReason(REASON_DISCARD)
end

function s.discon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.cfilter, 1, nil)
end

function s.distg(e, tp, eg, ep, ev, re, r, rp, chk)
    -- Checa se o oponente tem pelo menos uma carta na mão ou no campo
    if chk==0 then return Duel.GetFieldGroupCount(1-tp, LOCATION_HAND, 0) > 0 
        or Duel.GetFieldGroupCount(1-tp, LOCATION_ONFIELD, 0) > 0 end
    Duel.SetPossibleOperationInfo(0, CATEGORY_HANDES, nil, 0, 1-tp, 1)
    Duel.SetPossibleOperationInfo(0, CATEGORY_DESTROY, nil, 1, 1-tp, LOCATION_ONFIELD)
end

function s.disop(e, tp, eg, ep, ev, re, r, rp)
    local hcount = Duel.GetFieldGroupCount(1-tp, LOCATION_HAND, 0)
    local fcount = Duel.GetFieldGroupCount(1-tp, LOCATION_ONFIELD, 0)
    if hcount == 0 and fcount == 0 then return end
    
    local op = 0
    -- Abre o Menu DE ESCOLHA para o oponente (1-tp)
    if hcount > 0 and fcount > 0 then
        op = Duel.SelectOption(1-tp, aux.Stringid(id, 2), aux.Stringid(id, 3))
    elseif hcount > 0 then
        op = Duel.SelectOption(1-tp, aux.Stringid(id, 2))
    else
        op = Duel.SelectOption(1-tp, aux.Stringid(id, 3)) + 1
    end
    
    -- Executa a Punição escolhida
    if op == 0 then
        Duel.DiscardHand(1-tp, nil, 1, 1, REASON_EFFECT+REASON_DISCARD)
    else
        Duel.Hint(HINT_SELECTMSG, 1-tp, HINTMSG_DESTROY)
        local g = Duel.SelectMatchingCard(1-tp, nil, 1-tp, LOCATION_ONFIELD, 0, 1, 1, nil)
        if #g > 0 then
            Duel.Destroy(g, REASON_EFFECT)
        end
    end
end

-- ====================================================================
-- Efeito 3: Reviver do GY
-- ====================================================================
function s.brfilter(c)
    -- Puxa o ID da Brenda que você passou (777001840) pelo Nome Original
    return c:IsFaceup() and c:GetOriginalCode() == 777001840
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.brfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
    end
end