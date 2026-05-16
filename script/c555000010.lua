-- Cute Shinob Beast - Tiger
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Habilita Invocação-Fusão
    c:EnableReviveLimit()
    -- Sintaxe moderna do EDOPro para estipular 2 matérias baseadas estritamente em uma mesma condição (Filtro)
    Fusion.AddProcMixN(c, true, true, s.matfilter, 2)

    -- Efeito 1: Se Invocado por Fusão: Invocar 1 "Cute Shinob" do Deck
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Efeito 2: (Efeito Rápido) Destruir monstro com ATK menor e causar dano
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DESTROY | CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E | TIMING_MAIN_END)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end

s.listed_series = {0x267}

-- ==========================================================
-- Procedimento e Filtro de Fusão
-- ==========================================================
function s.matfilter(c, fc, sumtype, tp)
    return c:IsSetCard(0x267, fc, sumtype, tp)
end

-- ==========================================================
-- Efeito 1: Invocar do Deck (Defense Position)
-- ==========================================================
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function s.spfilter(c, e, tp)
    return c:IsSetCard(0x267) and c:IsMonster() and c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP_DEFENSE)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then 
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_DECK, 0, 1, nil, e, tp) 
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
    if #g > 0 then
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
    end
end

-- ==========================================================
-- Efeito 2: Destruição Condicional e Dano Punitivo
-- ==========================================================
function s.descon(e, tp, eg, ep, ev, re, r, rp)
    -- A API moderna do EDOPro já embute o atalho Duel.IsMainPhase() para facilitar essa verificação
    return Duel.IsMainPhase()
end

function s.desfilter(c, atk)
    return c:IsFaceup() and c:GetAttack() < atk
end

function s.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1 - tp) and s.desfilter(chkc, c:GetAttack()) end
    -- A carta precisa estar com face para cima para podermos confirmar seu ATK atual
    if chk == 0 then return c:IsFaceup() and Duel.IsExistingTarget(s.desfilter, tp, 0, LOCATION_MZONE, 1, nil, c:GetAttack()) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, s.desfilter, tp, 0, LOCATION_MZONE, 1, 1, nil, c:GetAttack())
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, 0)
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        -- O script deve verificar dinamicamente a tipologia da carta alvo antes da destruição
        local rating = 0
        if tc:IsType(TYPE_XYZ) then
            rating = tc:GetRank()
        elseif tc:IsType(TYPE_LINK) then
            rating = tc:GetLink()
        else
            rating = tc:GetLevel()
        end
        
        -- O "then" denota que o dano é condicionado à destruição bem sucedida
        if Duel.Destroy(tc, REASON_EFFECT) > 0 then
            Duel.Damage(1 - tp, rating * 400, REASON_EFFECT)
        end
    end
end