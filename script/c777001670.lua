-- Thunder Force Berzerker - Bratriz
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Procedimento de Special Summon da Mão (Reduzindo Nível de 1 Thunder Force por 2)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Efeito 2: Monstro do oponente enviado ao GY -> Moeda para subir o Nível (+1, max. 10)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_COIN)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.lvcon)
    e2:SetTarget(s.lvtg)
    e2:SetOperation(s.lvop)
    c:RegisterEffect(e2)

    -- Efeito 3: Substituir destruição reduzindo o Nível em 1 (Com prompt e Once Per Turn)
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_DESTROY_REPLACE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.reptg)
    e3:SetOperation(s.repop)
    c:RegisterEffect(e3)

    -- Efeito 4A: Enquanto Nível 8 ou superior -> Ataca todos os monstros do oponente
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_ATTACK_ALL)
    e4:SetValue(1)
    e4:SetCondition(s.atkcon)
    c:RegisterEffect(e4)

    -- Efeito 4B: Enquanto Nível 8 ou superior -> Oponente não pode ativar cartas/efeitos na batalha (Armades)
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e5:SetCode(EFFECT_CANNOT_ACTIVATE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetTargetRange(0, 1)
    e5:SetValue(s.aclimit)
    e5:SetCondition(s.actcon)
    c:RegisterEffect(e5)

    -- Efeito 5: Proteção de Batalha baseada no Nível contra monstros menores (Com Zeus)
    local e6 = Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e6:SetCondition(s.indcon)
    e6:SetValue(s.indval)
    c:RegisterEffect(e6)
end

-- Identificador nativo para mostrar o ícone de moeda
s.toss_coin = true

-- ====================================================================
-- Efeito 1: Procedimento de Special Summon
-- ====================================================================
function s.spfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_THUNDER) and c:HasLevel() and c:GetLevel() >= 3
end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    -- Garante a restrição "once per turn this way"
    if Duel.GetFlagEffect(tp, id) > 0 then return false end
    return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
    local tc = g:GetFirst()
    if tc then
        -- Registra a flag limitando a invocação por este método a 1 vez por turno
        Duel.RegisterFlagEffect(tp, id, RESET_PHASE + PHASE_END, 0, 1)
        
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_LEVEL)
        e1:SetValue(-2)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end
end

-- ====================================================================
-- Efeito 2: Enviar monstro do oponente ao GY -> Moeda para subir Nível (+1)
-- ====================================================================
function s.cfilter(c, tp)
    return c:IsControler(1 - tp) and c:IsType(TYPE_MONSTER)
end

function s.lvcon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.cfilter, 1, nil, tp)
end

function s.lvtg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsFaceup() and c:HasLevel() and c:GetLevel() < 10 end
    Duel.SetOperationInfo(0, CATEGORY_COIN, nil, 0, tp, 1)
end

function s.lvop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFaceup() and c:IsRelateToEffect(e) and c:HasLevel() and c:GetLevel() < 10 then
        local call = Duel.AnnounceCoin(tp)
        local res = Duel.TossCoin(tp, 1)
        
        if call == res then
            local max_inc = math.min(1, 10 - c:GetLevel())
            if max_inc > 0 then
                local e1 = Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_LEVEL)
                e1:SetValue(max_inc)
                e1:SetReset(RESET_EVENT + RESETS_STANDARD)
                c:RegisterEffect(e1)
            end
        end
    end
end

-- ====================================================================
-- Efeito 3: Substituir Destruição reduzindo Nível em 1
-- ====================================================================
function s.reptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsReason(REASON_BATTLE + REASON_EFFECT) and not c:IsReason(REASON_REPLACE) 
        and c:HasLevel() and c:GetLevel() > 1 end
    return Duel.SelectYesNo(tp, aux.Stringid(id, 1))
end

function s.repop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_LEVEL)
    e1:SetValue(-1)
    e1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(e1)
end

-- ====================================================================
-- Efeito 4: Nível 8 ou superior (Atacar todos + Armades)
-- ====================================================================
function s.atkcon(e)
    return e:GetHandler():IsFaceup() and e:GetHandler():GetLevel() > 0 and e:GetHandler():GetLevel() >= 8
end

function s.actcon(e)
    local c = e:GetHandler()
    return c:IsFaceup() and c:HasLevel() and c:GetLevel() >= 8 and (Duel.GetAttacker() == c or Duel.GetAttackTarget() == c)
end

function s.aclimit(e, re, tp)
    return true
end

-- ====================================================================
-- Efeito 5: Proteção contra monstros menores com o Zeus em campo
-- ====================================================================
function s.bossfilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777001370
end

function s.indcon(e)
    return Duel.IsExistingMatchingCard(s.bossfilter, e:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, nil)
end

function s.indval(e, c)
    local tc = c
    if not tc or not tc:IsFaceup() then return false end
    
    local rating = 0
    if tc:IsType(TYPE_XYZ) then
        rating = tc:GetRank()
    elseif tc:IsType(TYPE_LINK) then
        rating = tc:GetLink()
    elseif tc:HasLevel() then
        rating = tc:GetLevel()
    else
        return false
    end
    
    return rating > 0 and rating < e:GetHandler():GetLevel()
end