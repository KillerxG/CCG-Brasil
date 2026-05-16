-- Mortal Rests
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    -- Verifica se existe pelo menos 1 carta no seu cemitério para ativar
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_GRAVE,0,1,nil) end
    
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_GRAVE,0,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,tp,LOCATION_GRAVE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Coleta todas as cartas no seu cemitério durante a resolução
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_GRAVE,0,nil)
    
    if #g>0 then
        -- Bane o grupo inteiro virado para baixo
        Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
    end
end