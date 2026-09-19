-- The Angler of Vampire Castle
local s, id = GetID()

function s.initial_effect(c)
    -- Invocacao-Synchro
    Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTuner(nil), 1, 99, nil, nil, function(g) return g:IsExists(Card.IsSetCard, 1, nil, 0x208e) end)
    c:EnableReviveLimit()

    -- 1. Pagar 1000 LP para Invocacao-Especial de nao-Vampiro
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_COST)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(1, 1) -- Corrigido para ambos os jogadores
    e1:SetTarget(s.sumtg)
    e1:SetCost(s.ccost)
    e1:SetOperation(s.acop)
    c:RegisterEffect(e1)

    -- Torna monstros Invocados por Invocacao-Especial em Zombie (exceto Vampiros)
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CHANGE_RACE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    e2:SetTarget(s.zomtg)
    e2:SetValue(RACE_ZOMBIE)
    c:RegisterEffect(e2)

    -- 2. Enviar topo do Deck ao GY para descartar 1 card aleatorio da mao do oponente
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_HANDES + CATEGORY_DECKDES)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id)
    e3:SetCost(s.discost)
    e3:SetTarget(s.distg)
    e3:SetOperation(s.disop)
    c:RegisterEffect(e3)

    -- 3. Substituir saida de campo por banimento e Retornar ao Campo na Standby Phase
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EFFECT_SEND_REPLACE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTarget(s.reptg)
    e4:SetOperation(s.repop)
    c:RegisterEffect(e4)
end

s.listed_series = {0x8e}

--------------------------------------------------------------------------------
-- Efeito 1: Custo de LP e Mudança de Tipo
--------------------------------------------------------------------------------
function s.sumtg(e, c)
    if c:IsSetCard(0x8e) then return false end
    local tp = e:GetHandlerPlayer()
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil):Filter(Card.IsCode, nil, id)
    return #g > 0 and g:GetFirst() == e:GetHandler()
end

function s.ccost(e, c, tp)
    return Duel.CheckLPCost(tp, 1000)
end

function s.acop(e, tp, eg, ep, ev, re, r, rp)
    Duel.PayLPCost(tp, 1000)
end

function s.zomtg(e, c)
    return c:IsSummonType(SUMMON_TYPE_SPECIAL) and not c:IsSetCard(0x8e)
end

--------------------------------------------------------------------------------
-- Efeito 2: Descarte Aleatório
--------------------------------------------------------------------------------
function s.discost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp, 1) end
    Duel.DiscardDeck(tp, 1, REASON_COST)
end

function s.distg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetFieldGroupCount(tp, 0, LOCATION_HAND) > 0 end
    Duel.SetOperationInfo(0, CATEGORY_HANDES, nil, 0, 1 - tp, 1)
end

function s.disop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetFieldGroup(tp, 0, LOCATION_HAND) -- Pega a mão do oponente
    if #g > 0 then
        local sg = g:RandomSelect(tp, 1) -- Escolhe 1 carta aleatória
        Duel.SendtoGrave(sg, REASON_EFFECT + REASON_DISCARD) -- Envia para o GY como descarte
    end
end

--------------------------------------------------------------------------------
-- Efeito 3: Substituição por Banimento (Retornar ao Campo)
--------------------------------------------------------------------------------
function s.reptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsFaceup() and c:IsAbleToRemove()
        and re and rp == 1 - tp and not c:IsReason(REASON_REPLACE)
        and Duel.CheckLPCost(tp, 1000) end
    -- Uso da mensagem genérica 96 oficial do motor
    return Duel.SelectEffectYesNo(tp, c, 96)
end

function s.repop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.PayLPCost(tp, 1000)
    if Duel.Remove(c, POS_FACEUP, REASON_EFFECT + REASON_REPLACE + REASON_TEMPORARY) > 0 then
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE + PHASE_STANDBY)
        e1:SetLabelObject(c)
        if Duel.IsPhase(PHASE_STANDBY) then
            e1:SetLabel(Duel.GetTurnCount())
            e1:SetCondition(s.retcon)
            e1:SetReset(RESET_PHASE + PHASE_STANDBY, 2)
        else
            e1:SetReset(RESET_PHASE + PHASE_STANDBY)
        end
        e1:SetCountLimit(1)
        e1:SetOperation(s.retop)
        Duel.RegisterEffect(e1, tp)
    end
end

function s.retcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnCount() ~= e:GetLabel()
end

function s.retop(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetLabelObject()
    if tc and tc:IsLocation(LOCATION_REMOVED) then
        Duel.ReturnToField(tc) -- Retorna ao campo mantendo a posição original sem contar como Invocação
    end
end