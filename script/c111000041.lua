-- Reagroup
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    -- b1: É o seu turno
    local b1 = Duel.GetTurnPlayer()==tp
    -- b2: É o turno do oponente E você controla pelo menos 1 monstro que pode voltar para a mão
    local b2 = Duel.GetTurnPlayer()~=tp and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_MZONE,0,1,nil)
    
    if chk==0 then return b1 or b2 end
    
    local op=0
    if b1 then
        op=1
    else
        op=2
        local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,0,nil)
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,tp,LOCATION_MZONE)
    end
    e:SetLabel(op) -- Salva qual efeito foi escolhido para a resolução
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local op=e:GetLabel()
    
    if op==1 then
        -- Se for o seu turno: Encerra o turno
        local turnp=Duel.GetTurnPlayer()
        Duel.SkipPhase(turnp,PHASE_DRAW,RESET_PHASE+PHASE_END,1)
        Duel.SkipPhase(turnp,PHASE_STANDBY,RESET_PHASE+PHASE_END,1)
        Duel.SkipPhase(turnp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
        Duel.SkipPhase(turnp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
        Duel.SkipPhase(turnp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
        
        -- Garante que a Fase de Batalha não aconteça
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_BP)
        e1:SetTargetRange(1,0)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,turnp)
        
    elseif op==2 then
        -- Se for o turno do oponente: Retorna seus monstros
        local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,0,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
        end
    end
end