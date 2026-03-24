-- Sparkling Fighter
local s, id = GetID()

function s.initial_effect(c)
    -- Procedimento de Invocação-Sincro moderno
    c:EnableReviveLimit()
    Synchro.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsAttribute, ATTRIBUTE_LIGHT), 1, 1, Synchro.NonTunerEx(Card.IsType, TYPE_MONSTER), 1, 99)

    -- 1. Inafetado por efeitos de monstros do oponente
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetValue(s.immval)
    c:RegisterEffect(e1)

    -- 2. Ganha 400 de ATK para cada monstro LIGHT no seu GY
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)

    -- 3. Uma vez por turno, quando esta carta é atacada: Você pode negar o ataque e destruir 1 monstro do oponente
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BE_BATTLE_TARGET)
    e3:SetCountLimit(1)
    e3:SetCondition(s.negcon)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)

    -- 4. Se esta carta seria destruída, você pode banir 1 monstro LIGHT do seu GY em vez disso
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetCode(EFFECT_DESTROY_REPLACE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTarget(s.reptg)
    e4:SetOperation(s.repop)
    c:RegisterEffect(e4)
end

-- Filtros e Funções Auxiliares

-- Função do Efeito 1: Imunidade
function s.immval(e, te)
    return te:GetOwner() ~= e:GetOwner() and te:IsActiveType(TYPE_MONSTER)
end

-- Função do Efeito 2: Ganho de ATK
function s.atkfilter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_MONSTER)
end
function s.atkval(e, c)
    return Duel.GetMatchingGroupCount(s.atkfilter, c:GetControler(), LOCATION_GRAVE, 0, nil) * 400
end

-- Funções do Efeito 3: Negar Ataque e Destruir
function s.negcon(e, tp, eg, ep, ev, re, r, rp)
    -- Verifica se o atacante é controlado pelo oponente
    return Duel.GetAttacker():IsControler(1 - tp)
end
function s.negtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 1 - tp, LOCATION_MZONE)
end
function s.negop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.NegateAttack() then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
        local g = Duel.SelectMatchingCard(tp, nil, tp, 0, LOCATION_MZONE, 1, 1, nil)
        if #g > 0 then
            Duel.HintSelection(g)
            Duel.Destroy(g, REASON_EFFECT)
        end
    end
end

-- Funções do Efeito 4: Substituição de Destruição
function s.repfilter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function s.reptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    -- Verifica se a destruição ocorreu por batalha ou efeito e se já não é uma substituição
    if chk == 0 then return c:IsReason(REASON_BATTLE | REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
        and Duel.IsExistingMatchingCard(s.repfilter, tp, LOCATION_GRAVE, 0, 1, nil) end
    if Duel.SelectEffectYesNo(tp, c, 96) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
        local g = Duel.SelectMatchingCard(tp, s.repfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
        Duel.SetTargetCard(g)
        e:SetLabelObject(g:GetFirst())
        return true
    else 
        return false 
    end
end
function s.repop(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetLabelObject()
    if tc then
        -- O operador bitwise | é a maneira moderna de combinar razões sistêmicas no OCGCore
        Duel.Remove(tc, POS_FACEUP, REASON_EFFECT | REASON_REPLACE)
    end
end