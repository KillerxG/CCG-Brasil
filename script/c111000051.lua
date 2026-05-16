-- Entrance Ticket
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    
    -- Custo para Normal Summon
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SUMMON_COST)
    e1:SetTargetRange(0xff,0xff) -- Agora engloba a mão e todos os outros locais
    e1:SetCost(s.costchk)
    e1:SetOperation(s.costop)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    
    -- Custo para Special Summon
    local e2=e1:Clone()
    e2:SetCode(EFFECT_SPSUMMON_COST)
    Duel.RegisterEffect(e2,tp)
end

function s.costchk(e,c,tp)
    -- Se o jogador que está invocando não for quem ativou a armadilha, passa livre
    if tp~=e:GetOwnerPlayer() then return true end
    -- Checa se você tem os 800 LP para pagar
    return Duel.CheckLPCost(tp,800)
end

function s.costop(e,tp,eg,ep,ev,re,r,rp)
    -- Cobra os 800 LP apenas de você na hora da invocação
    if tp==e:GetOwnerPlayer() then
        Duel.PayLPCost(tp,800)
    end
end