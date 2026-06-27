-- Phantom Gunners Strike
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Ativação Padrão
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E + TIMING_MAIN_END)
    c:RegisterEffect(e1)

    -- Efeito 2: Mill Contínuo ao oponente invocar do déqui/Extra Deck
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.millcon)
    e2:SetOperation(s.millop)
    c:RegisterEffect(e2)

    -- Efeito 3: Destruir "até" o número de Phantom Gunners (Quick Effect)
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_SZONE)
    e3:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E + TIMING_MAIN_END)
    e3:SetCountLimit(1, id)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)

    -- Efeito 4: Setar do GY
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetHintTiming(0, TIMING_END_PHASE)
    e4:SetCountLimit(1, id + 1)
    e4:SetCondition(s.setcon)
    e4:SetTarget(s.settg)
    e4:SetOperation(s.setop)
    c:RegisterEffect(e4)
end

-- ====================================================================
-- Efeito 2: Punir a invocação do déqui / Extra Deck
-- ====================================================================
function s.cfilter(c, tp)
    -- Verifica se foi o oponente (1 - tp) que invocou E se veio do déqui ou Extra Deck
    return c:IsSummonPlayer(1 - tp) and c:IsPreviousLocation(LOCATION_DECK + LOCATION_EXTRA)
end

function s.millcon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.cfilter, 1, nil, tp)
end

function s.millop(e, tp, eg, ep, ev, re, r, rp)
    -- Dá um "pisco" visual na carta para o oponente saber de onde veio o mill
    Duel.Hint(HINT_CARD, 0, id)
    Duel.DiscardDeck(1 - tp, 2, REASON_EFFECT)
end

-- ====================================================================
-- Efeito 3: Destruir Outras Cartas (Flexível: 1 até count)
-- ====================================================================
function s.pgfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x302)
end

function s.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsOnField() end
    if chk == 0 then
        local count = Duel.GetMatchingGroupCount(s.pgfilter, tp, LOCATION_ONFIELD, 0, nil)
        return count > 0 and Duel.IsExistingTarget(nil, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil)
    end
    
    local count = Duel.GetMatchingGroupCount(s.pgfilter, tp, LOCATION_ONFIELD, 0, nil)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    -- Agora permite selecionar de 1 ATÉ o máximo de Phantom Gunners contados
    local g = Duel.SelectTarget(tp, nil, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, count, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local tg = Duel.GetTargetCards(e)
    if #tg > 0 then
        Duel.Destroy(tg, REASON_EFFECT)
    end
end

-- ====================================================================
-- Efeito 4: Setar do Cemitério
-- ====================================================================
function s.killerfilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777000960
end

function s.setcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.killerfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.settg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsSSetable() end
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, e:GetHandler(), 1, 0, 0)
end

function s.setop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsSSetable() then
        Duel.SSet(tp, c)
        local e1 = Effect.CreateEffect(c)
        e1:SetDescription(3300)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
        e1:SetReset(RESET_EVENT + RESETS_REDIRECT)
        e1:SetValue(LOCATION_REMOVED)
        c:RegisterEffect(e1)
    end
end