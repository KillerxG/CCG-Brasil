-- Reinforcements of Beast-Warriors
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.filter(c)
    -- Filtra apenas os monstros virados para cima para receberem o bônus
    return c:IsFaceup()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    -- Verifica se o oponente controla pelo menos 1 monstro virado para cima (0, LOCATION_MZONE)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Coleta todos os monstros virados para cima que o oponente controla no momento da resolução
    local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
    local c=e:GetHandler()
    
    -- Inicia um laço de repetição (loop) para aplicar o efeito em cada monstro do grupo
    for tc in aux.Next(g) do
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(1000)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD) -- O bônus é permanente até o monstro sair de campo ou ser virado para baixo
        tc:RegisterEffect(e1)
    end
end