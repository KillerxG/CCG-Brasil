-- Chaos Dark Magician Girl
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Habilita as regras de Invocação-Ritual
    c:EnableReviveLimit()

    -- Efeito 1: O nome desta carta se torna "Dark Magician Girl" no campo e no GY
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetRange(LOCATION_MZONE | LOCATION_GRAVE)
    e1:SetValue(38033121) -- Passcode oficial da Dark Magician Girl
    c:RegisterEffect(e1)

    -- Efeito 2: Não pode ser alvo de efeitos de cartas do oponente
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)

    -- Efeito 3: Não pode ser destruída por efeitos de cartas do oponente
    local e3 = e2:Clone()
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetValue(aux.indoval)
    c:RegisterEffect(e3)

    -- Efeito 4: Ganha 300 de ATK para cada Spellcaster no seu GY
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetCode(EFFECT_UPDATE_ATTACK)
    e4:SetRange(LOCATION_MZONE)
    e4:SetValue(s.atkval)
    c:RegisterEffect(e4)

    -- Efeito 5: Se for Invocada por Invocação-Ritual: Banir 1 carta do oponente
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 0))
    e5:SetCategory(CATEGORY_REMOVE)
    e5:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET | EFFECT_FLAG_DELAY)
    e5:SetCode(EVENT_SPSUMMON_SUCCESS)
    e5:SetCountLimit(1, {id, 1})
    e5:SetCondition(s.rmcon)
    e5:SetTarget(s.rmtg)
    e5:SetOperation(s.rmop)
    c:RegisterEffect(e5)

    -- Efeito 6: (Efeito Rápido) Negar a ativação e destruir
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 1))
    e6:SetCategory(CATEGORY_NEGATE | CATEGORY_DESTROY)
    e6:SetType(EFFECT_TYPE_QUICK_O)
    e6:SetCode(EVENT_CHAINING)
    e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP | EFFECT_FLAG_DAMAGE_CAL)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCountLimit(1, {id, 2})
    e6:SetCondition(s.negcon)
    e6:SetCost(s.negcost)
    e6:SetTarget(s.negtg)
    e6:SetOperation(s.negop)
    c:RegisterEffect(e6)
end

-- Indexação oficial para o motor de buscas
s.listed_names = {38033121, 21082832} -- Dark Magician Girl & Chaos Form

-- ==========================================================
-- Ganho de ATK (Spellcasters)
-- ==========================================================
function s.atkfilter(c)
    return c:IsRace(RACE_SPELLCASTER)
end

function s.atkval(e, c)
    return Duel.GetMatchingGroupCount(s.atkfilter, c:GetControler(), LOCATION_GRAVE, 0, nil) * 300
end

-- ==========================================================
-- Efeito 5: Banir do Oponente no Ritual Summon
-- ==========================================================
function s.rmcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end

function s.rmtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(1 - tp) and chkc:IsOnField() end
    if chk == 0 then return Duel.IsExistingTarget(Card.IsAbleToRemove, tp, 0, LOCATION_ONFIELD, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectTarget(tp, Card.IsAbleToRemove, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, 1, 0, 0)
end

function s.rmop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Remove(tc, POS_FACEUP, REASON_EFFECT)
    end
end

-- ==========================================================
-- Efeito 6: Efeito Rápido (Negar Ativação e Destruir)
-- ==========================================================
function s.negcon(e, tp, eg, ep, ev, re, r, rp)
    -- Garante que o oponente seja quem ativou e verifica se o efeito é passível de ser negado legalmente
    return rp == 1 - tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end

function s.cfilter(c)
    -- Une os Atributos LIGHT e DARK para a checagem no custo 
    return c:IsAttribute(ATTRIBUTE_LIGHT | ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end

function s.negcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_GRAVE, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    Duel.Remove(g, POS_FACEUP, REASON_COST)
end

function s.negtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
    -- Se o objeto no tabuleiro for passível de destruição, ele é registrado na fase passiva
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0)
    end
end

function s.negop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg, REASON_EFFECT)
    end
end