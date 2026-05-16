-- Dangerous Monster
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Ativação padrão da Armadilha Normal
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- ==========================================================
-- Condição: Durante o seu turno, se o oponente tiver o maior ATK
-- ==========================================================
function s.condition(e, tp, eg, ep, ev, re, r, rp)
    -- Garante que o efeito só pode ser ativado durante o seu turno
    if Duel.GetTurnPlayer() ~= tp then return false end
    
    -- Coleta todos os monstros virados para cima em ambos os campos
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
    if #g == 0 then return false end
    
    -- Extrai uma matriz apenas com os monstros que estão empatados no topo do valor de ATK atual
    local maxg = g:GetMaxGroup(Card.GetAttack)
    
    -- Checa se o oponente (1 - tp) controla pelo menos 1 membro desse grupo empatado no topo
    return maxg:IsExists(Card.IsControler, 1, nil, 1 - tp)
end

-- ==========================================================
-- Operação: Encerrar o turno (Pular todas as Fases)
-- ==========================================================
function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    
    -- 1. Pula imediatamente a fase atual em que você ativou a carta
    Duel.SkipPhase(tp, Duel.GetCurrentPhase(), RESET_PHASE | PHASE_END, 1)
    
    -- 2. Trava e força o pulo de todas as outras Fases posteriores para cair direto na End Phase
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_SKIP_DP)
    e1:SetTargetRange(1, 0)
    e1:SetReset(RESET_PHASE | PHASE_END)
    Duel.RegisterEffect(e1, tp)
    
    local e2 = e1:Clone()
    e2:SetCode(EFFECT_SKIP_SP)
    Duel.RegisterEffect(e2, tp)
    
    local e3 = e1:Clone()
    e3:SetCode(EFFECT_SKIP_M1)
    Duel.RegisterEffect(e3, tp)
    
    local e4 = e1:Clone()
    e4:SetCode(EFFECT_SKIP_BP)
    Duel.RegisterEffect(e4, tp)
    
    local e5 = e1:Clone()
    e5:SetCode(EFFECT_SKIP_M2)
    Duel.RegisterEffect(e5, tp)
end