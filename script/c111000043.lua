-- Monster Approaching
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.spfilter(c,e,tp)
    -- Checa se o monstro pode ser invocado por invocação-especial
    return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local p=1-tp -- Oponente
    if chk==0 then return Duel.GetLocationCount(p,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,p,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,p) end
    
    -- Não cravamos o OperationInfo para o dano pois o efeito inteiro é opcional para o oponente
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,p,LOCATION_HAND+LOCATION_GRAVE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local p=1-tp -- Oponente
    
    -- Checa se ainda tem espaço no campo do oponente na hora de resolver
    if Duel.GetLocationCount(p,LOCATION_MZONE)<=0 then return end
    
    -- Pergunta ao oponente se ele quer invocar (Your opponent can...)
    if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),p,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,p) 
        and Duel.SelectYesNo(p,aux.Stringid(id,0)) then
        
        Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(p,aux.NecroValleyFilter(s.spfilter),p,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,p)
        
        -- "...and if they do" (se a invocação for um sucesso)
        -- O p,p garante que quem invoca é o oponente, para o campo do oponente
        if #g>0 and Duel.SpecialSummon(g,0,p,p,false,false,POS_FACEUP)>0 then
            -- Você (tp) recebe 1000 de dano
            Duel.Damage(tp,1000,REASON_EFFECT)
        end
    end
end