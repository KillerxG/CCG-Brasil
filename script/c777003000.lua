-- Guardian of the Desert Core
-- Scripted by Gemini
local s, id = GetID()

-- Nova constante para o Marcador de Maldição
local COUNTER_CURSE = 0x1296

function s.initial_effect(c)
    -- Habilita Invocação-Link (2+ Monstros Rock)
    c:EnableReviveLimit()
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_ROCK),2)
    -- Autoriza a carta a receber Marcadores de Maldição
    c:EnableCounterPermit(COUNTER_CURSE)

    -- =======================================================================
    -- Checagem de Material e Registro da Flag (Client Hint)
    -- =======================================================================
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_SPSUMMON_SUCCESS)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetCondition(s.regcon)
    e0:SetOperation(s.regop)
    c:RegisterEffect(e0)

    local e0b = Effect.CreateEffect(c)
    e0b:SetType(EFFECT_TYPE_SINGLE)
    e0b:SetCode(EFFECT_MATERIAL_CHECK)
    e0b:SetValue(s.matcheck)
    e0b:SetLabelObject(e0)
    c:RegisterEffect(e0b)

    -- =======================================================================
    -- Proteções Baseadas na Flag
    -- =======================================================================
    -- Efeito 1: Não pode ser alvo de efeitos de cartas
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.protcon)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)

    -- Efeito 2: Não pode ser destruída por efeitos de cartas
    local e2 = e1:Clone()
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- =======================================================================
    -- Efeitos Ativados (Compartilham o limite "1 efeito por turno e 1 vez por turno")
    -- =======================================================================
    -- Efeito 3: Negar ativação, causar dano e remover marcador (Efeito Rápido)
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_NEGATE | CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP | EFFECT_FLAG_DAMAGE_CAL)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id) -- Limite HOPT Estrito base
    e3:SetCondition(s.negcon)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)

    -- Efeito 4: Colocar Curse Counters durante a End Phase
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_COUNTER)
    e4:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_TRIGGER_F) -- Obrigatório
    e4:SetCode(EVENT_PHASE | PHASE_END)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1, id) -- Compartilha a exata mesma contagem do efeito 3
    e4:SetCondition(s.ctcon)
    e4:SetOperation(s.ctop)
    c:RegisterEffect(e4)
end

-- ==========================================================
-- Lógica da Checagem de Material e Flag Visual
-- ==========================================================
function s.matcheck(e, c)
    local mg = c:GetMaterial()
    -- Confirma se a invocação usou apenas monstros EARTH
    if #mg > 0 and mg:FilterCount(Card.IsAttribute, nil, ATTRIBUTE_EARTH) == #mg then
        -- Repassa um sinal positivo ("1") para o efeito de registro logo abaixo
        e:GetLabelObject():SetLabel(1)
    else
        e:GetLabelObject():SetLabel(0)
    end
end

function s.regcon(e, tp, eg, ep, ev, re, r, rp)
    -- Garante que foi Invocado por Link e recebeu o sinal de material puramente EARTH
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetLabel() == 1
end

function s.regop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    -- Aplica a bandeira e adiciona o Client Hint (aviso) na tela informando a proteção permanentemente
    c:RegisterFlagEffect(id, RESET_EVENT | RESETS_STANDARD, EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 0))
end

function s.protcon(e)
    return e:GetHandler():GetFlagEffect(id) > 0
end

-- ==========================================================
-- Efeito Rápido (Negar, Dano e Remover Marcador)
-- ==========================================================
function s.negcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
        and c:GetCounter(COUNTER_CURSE) > 0
end

function s.negtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
    
    local ct = e:GetHandler():GetCounter(COUNTER_CURSE)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, ct * 400)
end

function s.negop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.NegateActivation(ev) and c:IsRelateToEffect(e) and c:IsFaceup() then
        -- Calcula os marcadores ANTES de remover 1, para infligir o dano correto baseado neles
        local ct = c:GetCounter(COUNTER_CURSE)
        
        if ct > 0 and Duel.Damage(1 - tp, ct * 400, REASON_EFFECT) > 0 then
            c:RemoveCounter(tp, COUNTER_CURSE, 1, REASON_EFFECT)
        end
    end
end

-- ==========================================================
-- Efeito: Gerar Curse Counters na End Phase
-- ==========================================================
function s.ctcon(e, tp, eg, ep, ev, re, r, rp)
    return math.abs(Duel.GetLP(tp) - Duel.GetLP(1 - tp)) >= 1000
end

function s.ctop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        local diff = math.abs(Duel.GetLP(tp) - Duel.GetLP(1 - tp))
        -- math.floor arredonda para baixo (ex: 2900 de diferença gera apenas 2 marcadores)
        local ct = math.floor(diff / 1000)
        if ct > 0 then
            c:AddCounter(COUNTER_CURSE, ct)
        end
    end
end