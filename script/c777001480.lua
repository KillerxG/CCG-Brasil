-- Rockslash Rogue
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Special Summon do Deck na Normal/Special Summon
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    local e2 = e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)

    -- Efeito 2: Dano de Efeito -> Destruir Spell/Trap e (possivelmente) causar Dano
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_DESTROY + CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_DAMAGE)
    e3:SetRange(LOCATION_MZONE)
    -- Inclui a flag DAMAGE_STEP para permitir ativação na Etapa de Dano, conforme o texto
    e3:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DAMAGE_STEP)
    e3:SetCountLimit(1, id + 1)
    e3:SetCondition(s.descon)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)
end

-- ====================================================================
-- Filtro Global da Haruna
-- ====================================================================
function s.harunafilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777002010
end

-- ====================================================================
-- Efeito 1: Invocação-Especial do Deck + Risco de Dano
-- ====================================================================
function s.spfilter(c, e, tp)
    -- Filtra um "Rockslash", com nome diferente desta carta, que possa ser Invocado
    return c:IsSetCard(0x309) and c:IsLevel(4) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_DECK, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
    -- Dano possível a si mesmo dependendo do campo na resolução
    Duel.SetPossibleOperationInfo(0, CATEGORY_DAMAGE, nil, 0, tp, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
    local tc = g:GetFirst()
    
    if tc and Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        -- Se não controlar a Haruna, sofre o dano baseado no ATK do monstro invocado
        if not Duel.IsExistingMatchingCard(s.harunafilter, tp, LOCATION_MZONE, 0, 1, nil) then
            Duel.BreakEffect()
            local atk = tc:GetAttack()
            if atk < 0 then atk = 0 end
            Duel.Damage(tp, atk, REASON_EFFECT)
        end
    end
end

-- ====================================================================
-- Efeito 2: Gatilho de Dano (Destruir S/T + Dano Opcional)
-- ====================================================================
function s.descon(e, tp, eg, ep, ev, re, r, rp)
    -- Verifica se o dano recebido (por qualquer jogador) foi de Efeito
    return (r & REASON_EFFECT) ~= 0
end

function s.desfilter(c)
    return c:IsType(TYPE_SPELL + TYPE_TRAP)
end

function s.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1 - tp) and s.desfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.desfilter, tp, 0, LOCATION_ONFIELD, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, s.desfilter, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
    Duel.SetPossibleOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, 400)
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    
    if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc, REASON_EFFECT) > 0 then
        -- Se destruir com sucesso, verifica se a Haruna está no campo para aplicar o dano extra
        if Duel.IsExistingMatchingCard(s.harunafilter, tp, LOCATION_MZONE, 0, 1, nil) then
            Duel.BreakEffect()
            Duel.Damage(1 - tp, 400, REASON_EFFECT)
        end
    end
end