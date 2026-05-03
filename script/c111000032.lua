-- No Survivors
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.tgfilter(c)
    -- Verifica se a carta é um monstro e se pode ser enviada ao cemitério
    return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    -- Checa se existe pelo menos 1 monstro no campo (LOCATION_MZONE) ou na mão (LOCATION_HAND)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil) end
    
    local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,tp,LOCATION_MZONE+LOCATION_HAND)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Coleta todos os monstros válidos na mão e no campo durante a resolução
    local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,nil)
    
    if #g>0 then
        -- Envia todos de uma vez para o cemitério usando a constante de efeito
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end