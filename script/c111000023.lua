-- Dangerous Monster
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    -- Só permite ativação se for o seu próprio turno
    if Duel.GetTurnPlayer()~=tp then return false end
    
    -- Coleta todos os monstros virados para cima de ambos os lados do campo
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    if #g==0 then return false end
    
    -- Identifica o grupo de monstros que possui o maior ATK
    local _,tg=g:GetMaxGroup(Card.GetAttack)
    
    -- A condição é atendida se pelo menos 1 desses monstros pertencer ao oponente (1-tp)
    return tg:IsExists(Card.IsControler,1,nil,1-tp)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local turnp=Duel.GetTurnPlayer()
    
    -- Pula todas as fases restantes para forçar o fim do turno
    Duel.SkipPhase(turnp,PHASE_DRAW,RESET_PHASE+PHASE_END,1)
    Duel.SkipPhase(turnp,PHASE_STANDBY,RESET_PHASE+PHASE_END,1)
    Duel.SkipPhase(turnp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
    Duel.SkipPhase(turnp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
    Duel.SkipPhase(turnp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
    
    -- Bloqueia a declaração de ataques para garantir a segurança da Fase de Batalha
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_BP)
    e1:SetTargetRange(1,0)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,turnp)
end