-- Empress of Silver Fangs - Kyara
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Nomi: Deve ser invocada primeiro pelo próprio efeito
    c:EnableReviveLimit()
    -- Restrição global de Special Summon: Só pode ser invocada 1x por turno
    c:SetSPSummonOnce(id)
    
    local e0 = Effect.CreateEffect(c)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(aux.FALSE)
    c:RegisterEffect(e0)

    -- Invocação Especial da Mão
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    -- Efeito Contínuo: Inverter Dano (Ganhar LP no lugar de perder)
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_REVERSE_DAMAGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetTargetRange(1, 0)
    e2:SetValue(s.revval)
    c:RegisterEffect(e2)

    -- Efeito Contínuo: Proteção (Não pode ser alvo do oponente)
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_ONFIELD, 0)
    e3:SetCondition(s.protcon)
    e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard, 0x307))
    e3:SetValue(aux.tgoval)
    c:RegisterEffect(e3)

    -- Efeito Contínuo: Proteção (Não pode ser destruído pelo oponente)
    local e4 = e3:Clone()
    e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e4:SetValue(aux.indoval)
    c:RegisterEffect(e4)

    -- Quick Effect: Destruir cartas baseado na diferença de LP
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 0))
    e5:SetCategory(CATEGORY_DESTROY + CATEGORY_RECOVER)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1, id)
    e5:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E) -- CORRIGIDO: Janela livre no turno do oponente
    e5:SetTarget(s.destg)
    e5:SetOperation(s.desop)
    c:RegisterEffect(e5)
end

-- ====================================================================
-- Invocação da Mão
-- ====================================================================
function s.spfilter(c)
    return c:IsSetCard(0x307) and c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    local g = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, nil)
    return g:GetClassCount(Card.GetCode) >= 3 and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
end

-- ====================================================================
-- Reversão de Dano
-- ====================================================================
function s.revval(e, re, r, rp, rc)
    return (r & (REASON_BATTLE + REASON_EFFECT)) ~= 0
end

-- ====================================================================
-- Condição de Proteção
-- ====================================================================
function s.protcon(e)
    local tp = e:GetHandlerPlayer()
    return Duel.GetLP(tp) > Duel.GetLP(1 - tp)
end

-- ====================================================================
-- Quick Effect (Destruir e Curar)
-- ====================================================================
function s.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(1 - tp) and chkc:IsOnField() end
    
    -- Matemática blindada contra bugs da engine
    local p_lp = Duel.GetLP(tp)
    local o_lp = Duel.GetLP(1 - tp)
    local diff = p_lp > o_lp and (p_lp - o_lp) or (o_lp - p_lp)
    local ct = math.floor(diff / 1000)
    
    -- Exige apenas que o oponente tenha pelo menos 1 carta (e a diferença seja >= 1000)
    if chk == 0 then return ct > 0 and Duel.IsExistingTarget(aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    -- O SEGREDO: Mudei de "ct, ct" para "1, ct". Agora você escolhe ATÉ o limite, sem travar o jogo!
    local g = Duel.SelectTarget(tp, aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, ct, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local tg = Duel.GetTargetCards(e)
    if #tg > 0 then
        local des = Duel.Destroy(tg, REASON_EFFECT)
        -- Checa se a sua vida é MENOR que a do oponente após a destruição
        if des > 0 and Duel.GetLP(tp) < Duel.GetLP(1 - tp) then
            Duel.BreakEffect()
            Duel.Recover(tp, des * 500, REASON_EFFECT)
        end
    end
end