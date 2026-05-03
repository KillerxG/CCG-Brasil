-- Distraction
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
    -- Checa se é o turno de quem ativou a carta
    if Duel.GetTurnPlayer()~=tp then return false end
    
    local ph=Duel.GetCurrentPhase()
    -- Permite a ativação apenas na Main Phase 1, Battle Phase ou Main Phase 2
    return ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    
    local ph=Duel.GetCurrentPhase()
    local op=0
    
    -- Salva no Label qual fase era na hora da ativação para aplicar o efeito correto
    if ph==PHASE_MAIN1 then 
        op=1
    elseif ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE then 
        op=2
    elseif ph==PHASE_MAIN2 then 
        op=3 
    end
    e:SetLabel(op)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local op=e:GetLabel()
    local c=e:GetHandler()
    
    if op==1 then
        -- Main Phase 1: You cannot conduct your Battle Phase this turn.
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCode(EFFECT_CANNOT_BP)
        e1:SetTargetRange(1,0)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
        
    elseif op==2 then
        -- Battle Phase: End your Battle Phase.
        Duel.SkipPhase(tp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1)
        
    elseif op==3 then
        -- Main Phase 2: End your turn.
        Duel.SkipPhase(tp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
        -- Ao pular a Main Phase 2, o EDOPro automaticamente empurra o jogo para a End Phase, encerrando o turno.
    end
end