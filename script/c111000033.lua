-- Spirit Pressure
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.cfilter(c)
    -- Verifica se o monstro está virado para cima e possui o subtipo "Spirit"
    return c:IsFaceup() and c:IsType(TYPE_SPIRIT)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    -- A condição só é verdadeira se NÃO houver nenhum monstro Spirit sob o seu controle
    return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.disfilter(c)
    -- Filtra apenas os monstros que podem ser negados (igualzinho ao script de 'Parade')
    return c:IsFaceup() and not c:IsDisabled() and (c:IsType(TYPE_EFFECT) or c:GetOriginalType()&TYPE_EFFECT~=0)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_MZONE,0,1,nil) end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Coleta os monstros que serão negados
    local g=Duel.GetMatchingGroup(s.disfilter,tp,LOCATION_MZONE,0,nil)
    
    local tc=g:GetFirst()
    for tc in aux.Next(g) do
        -- Nega as habilidades de cada um deles
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e2)
    end
end