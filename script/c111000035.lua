-- Army of Spirits
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.spfilter(c,e,tp)
    -- Checa se o monstro pode ser invocado por invocação-especial pelo oponente (tp) no campo dele (tp)
    return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local p=1-tp -- Oponente
    if chk==0 then return Duel.GetLocationCount(p,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,p,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,p) end
    
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,p,LOCATION_GRAVE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local p=1-tp -- Oponente
    
    -- Checa se o oponente ainda tem espaço no campo na hora de resolver
    if Duel.GetLocationCount(p,LOCATION_MZONE)<=0 then return end
    
    -- Pergunta ao oponente se ele quer realizar a invocação
    if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),p,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,p) 
        and Duel.SelectYesNo(p,aux.Stringid(id,0)) then
        
        Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)
        -- O oponente escolhe 1 monstro de qualquer um dos cemitérios
        local g=Duel.SelectMatchingCard(p,aux.NecroValleyFilter(s.spfilter),p,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,p)
        
        if #g>0 then
            -- O p,p garante que quem faz a invocação é o oponente, para a própria zona de monstros
            Duel.SpecialSummon(g,0,p,p,false,false,POS_FACEUP)
        end
    end
end