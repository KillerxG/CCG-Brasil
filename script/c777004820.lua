-- East Wings Champion
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Habilita o limite de invocação oficial para Monstros de Ritual
    c:EnableReviveLimit()

    -- Efeito 1: Se Invocado por Ritual, colocar até 2 monstros do oponente na S&T Zone dele
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET | EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.plcon)
    e1:SetTarget(s.pltg)
    e1:SetOperation(s.plop)
    c:RegisterEffect(e1)

    -- Efeito 2: (Efeito Rápido) Enviar 1 S&T tratado como monstro para o GY para negar 1 carta no campo
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    -- HintTiming moderno essencial para Efeitos Rápidos no EDOPro [1]
    e2:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E | TIMING_MAIN_END)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCost(s.negcost)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)
end

s.listed_series = {0x314}
s.listed_names = {777004880} -- East Wings Awakening

-- ==========================================================
-- Efeito 1: Capturar até 2 Monstros Inimigos
-- ==========================================================
function s.plcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end

function s.plfilter(c)
    return c:IsFaceup() and c:IsMonster()
end

function s.pltg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(1 - tp) and chkc:IsLocation(LOCATION_MZONE) and s.plfilter(chkc) end
    if chk == 0 then
        return Duel.GetLocationCount(1 - tp, LOCATION_SZONE) > 0
            and Duel.IsExistingTarget(s.plfilter, tp, 0, LOCATION_MZONE, 1, nil)
    end
    
    -- Calcula o limite de espaço disponível para determinar quantos monstros podem ser alvos
    local ft = Duel.GetLocationCount(1 - tp, LOCATION_SZONE)
    if ft > 2 then ft = 2 end 
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g = Duel.SelectTarget(tp, s.plfilter, tp, 0, LOCATION_MZONE, 1, ft, nil)
end

function s.plop(e, tp, eg, ep, ev, re, r, rp)
    local ft = Duel.GetLocationCount(1 - tp, LOCATION_SZONE)
    if ft <= 0 then return end
    
    local g = Duel.GetTargetCards(e)
    if #g == 0 then return end
    
    -- Caso o oponente tenha ocupado as Zonas em resposta e o espaço seja menor que o número de alvos
    if #g > ft then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOFIELD)
        g = g:Select(tp, ft, ft, nil)
    end
    
    for tc in aux.Next(g) do
        if Duel.MoveToField(tc, tp, 1 - tp, LOCATION_SZONE, POS_FACEUP, true) then
            local e1 = Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CHANGE_TYPE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetValue(TYPE_SPELL | TYPE_CONTINUOUS)
            e1:SetReset(RESET_EVENT | RESETS_STANDARD - RESET_TURN_SET)
            tc:RegisterEffect(e1)
        end
    end
end

-- ==========================================================
-- Efeito 2: Efeito Rápido de Negar (Qualquer face-up no campo)
-- ==========================================================
function s.cfilter(c)
    return c:IsFaceup() and c:IsOriginalType(TYPE_MONSTER) and c:IsContinuousSpell() and c:IsAbleToGraveAsCost()
end

function s.negcost(e, tp, eg, ep, ev, re, r, rp, chk)
    -- As constantes de localização LOCATION_SZONE duplas vasculham as retaguardas de AMBOS os jogadores
    if chk == 0 then return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_SZONE, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_SZONE, 0, 1, 1, nil)
    Duel.SendtoGrave(g, REASON_COST)
end

function s.negtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
    if chk == 0 then return Duel.IsExistingTarget(Card.IsFaceup, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_NEGATE)
    local g = Duel.SelectTarget(tp, Card.IsFaceup, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_DISABLE, g, 1, 0, 0)
end

function s.negop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    
    -- Confirma as propriedades físicas do alvo (face-up, atrelado à chain, e que ainda não esteja negado)
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsDisabled() then
        Duel.NegateRelatedChain(tc, RESET_TURN_SET)
        
        -- Nega os efeitos bases
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT | RESETS_STANDARD | RESET_PHASE | PHASE_END)
        tc:RegisterEffect(e1)
        
        local e2 = Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetValue(RESET_TURN_SET)
        e2:SetReset(RESET_EVENT | RESETS_STANDARD | RESET_PHASE | PHASE_END)
        tc:RegisterEffect(e2)
        
        -- Cobertura oficial do motor para neutralizar cartas "Trap Monster" 
        if tc:IsType(TYPE_TRAPMONSTER) then
            local e3 = Effect.CreateEffect(c)
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
            e3:SetReset(RESET_EVENT | RESETS_STANDARD | RESET_PHASE | PHASE_END)
            tc:RegisterEffect(e3)
        end
    end
end