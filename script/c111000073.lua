-- Take a Rest
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
    -- O alvo precisa estar virado para cima e ter um ataque maior que 0 para o efeito fazer sentido
    return c:IsFaceup() and c:GetAttack()>0
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    -- Verifica se você controla pelo menos 1 monstro virado para cima com ATK maior que 0 (LOCATION_MZONE, 0)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Coleta todos os seus monstros virados para cima no momento da resolução
    local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
    local c=e:GetHandler()
    
    -- Inicia o laço de repetição para aplicar o efeito simultaneamente em cada monstro do seu grupo
    for tc in aux.Next(g) do
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL) -- Força o valor final a ser exatamente o que está no SetValue
        e1:SetValue(0)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD) -- A exaustão é permanente até a carta sair de campo ou ser virada para baixo
        tc:RegisterEffect(e1)
    end
end