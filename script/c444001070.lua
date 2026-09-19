-- The Researcher of Vampire Castle (ID: 444001070)
-- Token ID: 444001071
local s, id = GetID()

function s.initial_effect(c)
    -- 1. Invocacao-Normal da mao ao revelar (Se controlar "Vampire")
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.normcon)
    e1:SetCost(s.normcost)
    e1:SetTarget(s.normtg)
    e1:SetOperation(s.normop)
    c:RegisterEffect(e1)

    -- 2. Invoca o Token quando deixa o campo
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOKEN)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.tkcon)
    e2:SetTarget(s.tktg)
    e2:SetOperation(s.tkop)
    c:RegisterEffect(e2)

    -- 3. Dano de Burn obrigatorio ao Invocar "Vampire" (Apenas 1 copia ativa por evento)
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.burncon)
    e3:SetTarget(s.burntg)
    e3:SetOperation(s.burnop)
    c:RegisterEffect(e3)

    local e3b = e3:Clone()
    e3b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3b)
end

s.listed_series = {0x8e}
s.listed_names = {id + 1} -- 444001071 (Token)

--------------------------------------------------------------------------------
-- Efeito 1: Revelar e Invocação-Normal
--------------------------------------------------------------------------------
function s.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x8e)
end

function s.normcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.normcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return not c:IsPublic() end
    Duel.ConfirmCards(1 - tp, c)
    Duel.ShuffleHand(tp)
end

function s.normtg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsSummonable(true, nil) end
    Duel.SetOperationInfo(0, CATEGORY_SUMMON, c, 1, 0, 0)
end

function s.normop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsSummonable(true, nil) then
        Duel.Summon(tp, c, true, nil)
    end
end

--------------------------------------------------------------------------------
-- Efeito 2: Invocação de Token (ID 444001071)
--------------------------------------------------------------------------------
function s.tkcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.tktg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsPlayerCanSpecialSummonMonster(tp, id + 1, 0, TYPES_TOKEN + TYPE_TUNER, 0, 0, 1, RACE_BEAST, ATTRIBUTE_DARK) end
    Duel.SetOperationInfo(0, CATEGORY_TOKEN, nil, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, 0)
end

function s.tkop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    if Duel.IsPlayerCanSpecialSummonMonster(tp, id + 1, 0, TYPES_TOKEN + TYPE_TUNER, 0, 0, 1, RACE_BEAST, ATTRIBUTE_DARK) then
        local token = Duel.CreateToken(tp, id + 1)
        if Duel.SpecialSummonStep(token, 0, tp, tp, false, false, POS_FACEUP) then
            -- Efeito do Token: Alterar Nível até 3x por turno
            local e1 = Effect.CreateEffect(e:GetHandler())
            e1:SetDescription(aux.Stringid(id, 3))
            e1:SetCategory(CATEGORY_LVCHANGE)
            e1:SetType(EFFECT_TYPE_IGNITION)
            e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
            e1:SetRange(LOCATION_MZONE)
            e1:SetCountLimit(3)
            e1:SetTarget(s.lvtg)
            e1:SetOperation(s.lvop)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD)
            token:RegisterEffect(e1, true)
        end
        Duel.SpecialSummonComplete()
    end
end

function s.lvfilter(c)
    return c:IsFaceup() and c:HasLevel()
end

function s.lvtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.lvfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, s.lvfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil)
end

function s.lvop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:HasLevel() then
        local op = 0
        if tc:GetLevel() == 1 then
            op = Duel.SelectOption(tp, aux.Stringid(id, 4))
        else
            op = Duel.SelectOption(tp, aux.Stringid(id, 4), aux.Stringid(id, 5))
        end
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_LEVEL)
        e1:SetValue(op == 0 and 1 or -1)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end
end

--------------------------------------------------------------------------------
-- Efeito 3: Dano de Burn Único por Invocação (Apenas Invocado por VOCÊ)
--------------------------------------------------------------------------------
function s.vfilter(c, tp)
    return c:IsFaceup() and c:IsControler(tp) and c:IsSummonPlayer(tp) and c:IsSetCard(0x8e)
end

function s.burncon(e, tp, eg, ep, ev, re, r, rp)
    -- Valida se o monstro Vampire foi Invocado no SEU campo e por VOCÊ
    if not eg:IsExists(s.vfilter, 1, nil, tp) then return false end
    
    -- Trava de Cópia Única: Garante que apenas a primeira Researcher do seu campo dispara o efeito
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil):Filter(Card.IsCode, nil, id)
    return #g > 0 and g:GetFirst() == e:GetHandler()
end

function s.burntg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(500)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, 500)
end

function s.burnop(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    Duel.Damage(p, d, REASON_EFFECT)
end