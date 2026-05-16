-- Surrounded by Monsters
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    -- Conta quantos monstros você controla e quantos o oponente controla
    local my_monsters=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
    local opp_monsters=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
    
    -- A condição é atendida se o oponente tiver estritamente mais monstros que você
    return opp_monsters > my_monsters
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    -- A carta em si já é uma carta no campo, então sempre haverá pelo menos ela para destruir
    if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,0,1,nil) end
    
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,0,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Coleta absolutamente todas as cartas do seu lado do campo na resolução
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,0,nil)
    
    if #g>0 then
        -- Destrói todas as suas cartas (incluindo esta própria armadilha, caso ela ainda esteja no campo)
        Duel.Destroy(g,REASON_EFFECT)
    end
end