-- Lava Hole
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
    if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,#g*500)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Coleta todos os monstros que você controla na resolução
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
    
    if #g>0 then
        -- O ct armazena quantos monstros foram efetivamente destruídos
        local ct=Duel.Destroy(g,REASON_EFFECT)
        
        -- "and if you do": Se pelo menos 1 monstro foi destruído
        if ct>0 then
            Duel.BreakEffect()
            -- Aplica 500 de dano para cada monstro destruído com sucesso
            Duel.Damage(tp,ct*500,REASON_EFFECT)
        end
    end
end