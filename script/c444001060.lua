-- The Maid of Vampire Castle
local s, id = GetID()

function s.initial_effect(c)
    -- 1. Revelar da mao se um "Vampire" sob seu controle deixar o campo e realizar Invocacao-Normal ou Set
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_LEAVE_FIELD)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.sumcon)
    e1:SetCost(s.sumcost)
    e1:SetTarget(s.sumtg)
    e1:SetOperation(s.sumop)
    c:RegisterEffect(e1)

    -- 2. Efeito Rapido: Roubar Magia/Armadilha do oponente (Sem resposta do alvo)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 2))
    e2:SetCategory(CATEGORY_CONTROL + CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0, TIMING_MAIN_END + TIMINGS_CHECK_MONSTER)
    e2:SetCountLimit(1, id + 1)
    e2:SetTarget(s.cttg)
    e2:SetOperation(s.ctop)
    c:RegisterEffect(e2)
end

s.listed_series = {0x8e}

--------------------------------------------------------------------------------
-- Efeito 1: Invocação-Normal ou Set (Apenas se um "Vampire" SEU sair do campo)
--------------------------------------------------------------------------------
function s.lvfilter(c, tp)
    return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousSetCard(0x8e)
end

function s.sumcon(e, tp, eg, ep, ev, re, r, rp)
    return not (Duel.GetCurrentPhase() == PHASE_DAMAGE) and eg:IsExists(s.lvfilter, 1, nil, tp)
end

function s.sumcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return not c:IsPublic() end
    Duel.ConfirmCards(1 - tp, c)
    Duel.ShuffleHand(tp)
end

function s.sumtg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsSummonable(true, nil) or c:IsMSetable(true, nil) end
    Duel.SetOperationInfo(0, CATEGORY_SUMMON, c, 1, 0, 0)
end

function s.sumop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local b1 = c:IsSummonable(true, nil)
    local b2 = c:IsMSetable(true, nil)
    if not (b1 or b2) then return end

    local op = 0
    if b1 and b2 then
        -- Hint 0: Normal Summon, Hint 1: Set
        op = Duel.SelectOption(tp, aux.Stringid(id, 0), aux.Stringid(id, 1))
    elseif b1 then
        op = 0
    else
        op = 1
    end

    if op == 0 then
        Duel.Summon(tp, c, true, nil)
    else
        Duel.MSet(tp, c, true, nil)
    end
end

--------------------------------------------------------------------------------
-- Efeito 2: Roubar Magia/Armadilha
--------------------------------------------------------------------------------
function s.ctfilter(c)
    return c:IsSpellTrap()
end

function s.cttg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(1 - tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.ctfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.ctfilter, tp, 0, LOCATION_ONFIELD, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g = Duel.SelectTarget(tp, s.ctfilter, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
    Duel.SetChainLimit(s.chainlm(g:GetFirst()))
end

function s.chainlm(tc)
    return function(e, rp, ep) return e:GetHandler() ~= tc end
end

function s.ctop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsControler(1 - tp) then
        local ft = Duel.GetLocationCount(tp, LOCATION_SZONE)
        local b1 = true -- Opção de adicionar à mão
        local b2 = ft > 0 -- Opção de baixar na S/T Zone (requer espaço)
        
        local op = 0
        if b1 and b2 then
            -- Hint 3: Add to hand, Hint 4: Place in S/T zone
            op = Duel.SelectOption(tp, aux.Stringid(id, 3), aux.Stringid(id, 4))
        elseif b1 then
            op = 0
        else
            op = 1
        end

        if op == 0 then
            Duel.SendtoHand(tc, tp, REASON_EFFECT)
        else
            Duel.MoveToField(tc, tp, tp, LOCATION_SZONE, tc:GetPosition(), true)
        end
    end
end