-- East Wings Enchantress
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Habilita as regras de Invocação-Ritual
    c:EnableReviveLimit()

    -- Efeito 1: (Efeito Rápido) Invocar por Invocação-Especial 1 Carta de Monstro da Zona S&T de qualquer jogador
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_MZONE)
    -- HintTiming moderno essencial para Efeitos Rápidos que interagem com o tabuleiro principal
    e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E | TIMING_MAIN_END)
    e1:SetCountLimit(1, {id, 1})
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Efeito 2: Destruir 1 carta do oponente se um monstro for invocado da Zona S&T
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET | EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end

s.listed_series = {0x314}
s.listed_names = {777004880} -- East Wings Awakening

-- ==========================================================
-- Efeito 1: Invocar Especialmente de Qualquer Zona S&T
-- ==========================================================
function s.spfilter(c, e, tp)
    -- Identifica de forma segura que a carta selecionada na S&T é originalmente um monstro
    return c:IsFaceup() and c:IsOriginalType(TYPE_MONSTER) 
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_SZONE) and s.spfilter(chkc, e, tp) end
    if chk == 0 then 
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            -- O 3º e 4º parâmetros definem que a busca varrerá a LOCATION_SZONE aliada e inimiga simultaneamente
            and Duel.IsExistingTarget(s.spfilter, tp, LOCATION_SZONE, LOCATION_SZONE, 1, nil, e, tp) 
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.spfilter, tp, LOCATION_SZONE, LOCATION_SZONE, 1, 1, nil, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
    end
end

-- ==========================================================
-- Efeito 2: Destruir Carta do Oponente
-- ==========================================================
function s.cfilter(c, tp)
    -- A flag IsPreviousLocation identifica perfeitamente o local de origem durante cadeias de transição
    return c:IsPreviousLocation(LOCATION_SZONE) and c:IsControler(tp)
end

function s.descon(e, tp, eg, ep, ev, re, r, rp)
    return not Duel.IsDamageStep() and eg:IsExists(s.cfilter, 1, nil, tp)
end

function s.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(1 - tp) and chkc:IsOnField() end
    if chk == 0 then return Duel.IsExistingTarget(nil, tp, 0, LOCATION_ONFIELD, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    -- nil funciona como filtro absoluto "qualquer carta"
    local g = Duel.SelectTarget(tp, nil, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc, REASON_EFFECT)
    end
end