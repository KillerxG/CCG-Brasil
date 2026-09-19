-- Mist of the Vampire Castle
local s, id = GetID()

function s.initial_effect(c)
    -- Ativar Magia Contínua
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- 1. Imune a alvo no turno em que são invocados
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_MZONE, 0)
    e2:SetTarget(s.prottg)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)

    -- 2. Roubar monstro destruído do oponente
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_DESTROYED)
    -- Adicionado EFFECT_FLAG_DAMAGE_STEP para funcionar em batalha
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1, id)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

s.listed_series = {0x8e, 0x208e}

-- ==========================================
-- EFEITO 1: PROTEÇÃO NO TURNO DA INVOCAÇÃO
-- ==========================================
function s.prottg(e, c)
    return c:IsSetCard(0x8e) and c:GetTurnID() == Duel.GetTurnCount()
end

-- ==========================================
-- EFEITO 2: ROUBAR MONSTRO DESTRUÍDO
-- ==========================================
function s.vampfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x8e)
end
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.vampfilter, tp, LOCATION_MZONE, 0, 1, nil)
end
function s.cfilter(c, e, tp)
    return c:IsPreviousControler(1 - tp) and c:IsPreviousLocation(LOCATION_MZONE)
        and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT))
        and c:IsLocation(LOCATION_GRAVE + LOCATION_REMOVED)
        and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return eg:IsContains(chkc) and s.cfilter(chkc, e, tp) end
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and eg:IsExists(s.cfilter, 1, nil, e, tp) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = eg:FilterSelect(tp, s.cfilter, 1, 1, nil, e, tp)
    Duel.SetTargetCard(g)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        local c = e:GetHandler()
        
        -- Torna DARK
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        e1:SetValue(ATTRIBUTE_DARK)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(e1)
        
        -- Torna Zombie
        local e2 = e1:Clone()
        e2:SetCode(EFFECT_CHANGE_RACE)
        e2:SetValue(RACE_ZOMBIE)
        tc:RegisterEffect(e2)
        
        -- Adiciona Setcode "Vampire" (0x8e)
        local e3 = e1:Clone()
        e3:SetCode(EFFECT_ADD_SETCODE)
        e3:SetValue(0x8e)
        tc:RegisterEffect(e3)
        
        -- Adiciona Setcode "of Vampire Castle" (0x208e)
        local e4 = e1:Clone()
        e4:SetCode(EFFECT_ADD_SETCODE)
        e4:SetValue(0x208e)
        tc:RegisterEffect(e4)

        -- Nega os efeitos do monstro
        local e5 = Effect.CreateEffect(c)
        e5:SetType(EFFECT_TYPE_SINGLE)
        e5:SetCode(EFFECT_DISABLE)
        e5:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(e5)
        local e6 = Effect.CreateEffect(c)
        e6:SetType(EFFECT_TYPE_SINGLE)
        e6:SetCode(EFFECT_DISABLE_EFFECT)
        e6:SetValue(RESET_TURN_SET)
        e6:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(e6)

        -- Enviar para o Cemitério na End Phase
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 1)
        local e7 = Effect.CreateEffect(c)
        e7:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e7:SetCode(EVENT_PHASE + PHASE_END)
        e7:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e7:SetCountLimit(1)
        e7:SetLabelObject(tc)
        e7:SetCondition(s.gycon)
        e7:SetOperation(s.gyop)
        e7:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(e7, tp)
    end
end

function s.gycon(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetLabelObject()
    return tc and tc:GetFlagEffect(id) ~= 0
end

function s.gyop(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetLabelObject()
    Duel.SendtoGrave(tc, REASON_EFFECT)
end