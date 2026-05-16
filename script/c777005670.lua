-- Azure-Eyes Magician Girl
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Habilita as regras de Invocação-Fusão
    c:EnableReviveLimit()
    Fusion.AddProcMix(c, true, true, 38033121, 89631139)

    -- Efeito 1: Não pode ser alvo de efeitos de cartas do oponente
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)

    -- Efeito 2: Não pode ser destruída por efeitos de cartas do oponente
    local e2 = e1:Clone()
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetValue(aux.indoval)
    c:RegisterEffect(e2)

    -- Efeito 3: Ganha 300 ATK por cada Dragon e Spellcaster em ambos os GYs
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(s.atkval)
    c:RegisterEffect(e3)

    -- Efeito 4: Special Summon 1 Dragon ou Spellcaster do seu GY
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1, {id, 1})
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)

    -- Efeito 5: (Efeito Rápido) Negar a ativação e destruir
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 1))
    e5:SetCategory(CATEGORY_NEGATE | CATEGORY_DESTROY | CATEGORY_TODECK)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_CHAINING)
    e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP | EFFECT_FLAG_DAMAGE_CAL)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1, {id, 2})
    e5:SetCondition(s.negcon)
    e5:SetCost(s.negcost)
    e5:SetTarget(s.negtg)
    e5:SetOperation(s.negop)
    c:RegisterEffect(e5)
end

-- Indexação oficial para o motor de buscas
s.listed_names = {38033121, 89631139, id}

-- ==========================================================
-- Efeito 3: Ganho de ATK (Ambos os Cemitérios)
-- ==========================================================
function s.atkfilter(c)
    return c:IsRace(RACE_DRAGON | RACE_SPELLCASTER)
end

function s.atkval(e, c)
    -- Os dois parâmetros LOCATION_GRAVE dizem ao sistema para contar os monstros no seu GY e no do oponente
    return Duel.GetMatchingGroupCount(s.atkfilter, c:GetControler(), LOCATION_GRAVE, LOCATION_GRAVE, nil) * 300
end

-- ==========================================================
-- Efeito 4: Special Summon do GY
-- ==========================================================
function s.spfilter(c, e, tp)
    return c:IsRace(RACE_DRAGON | RACE_SPELLCASTER) and not c:IsCode(id)
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc, e, tp) end
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingTarget(s.spfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.spfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
    end
end

-- ==========================================================
-- Efeito 5: Efeito Rápido (Negar Ativação e Destruir)
-- ==========================================================
function s.negcon(e, tp, eg, ep, ev, re, r, rp)
    -- Garante que o efeito só pode atuar sobre correntes do oponente e ignora monstros destruídos em batalha
    return rp == 1 - tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end

function s.costfilter(c)
    -- Impede embaralhar cartas banidas viradas para baixo (já que a raça estaria oculta)
    return c:IsRace(RACE_DRAGON | RACE_SPELLCASTER) and c:IsAbleToDeckAsCost()
        and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end

function s.negcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.costfilter, tp, LOCATION_GRAVE | LOCATION_REMOVED, 0, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectMatchingCard(tp, s.costfilter, tp, LOCATION_GRAVE | LOCATION_REMOVED, 0, 1, 1, nil)
    Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST)
end

function s.negtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    -- Constantes obrigatórias para declarar à engine que uma carta alvo será negada de imediato 
    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0)
    end
end

function s.negop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg, REASON_EFFECT)
    end
end