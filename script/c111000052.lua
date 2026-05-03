-- Evil Convocation
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.spfilter(c,e,tp)
    -- Filtra por monstros de TREVAS (DARK) que podem ser invocados por invocação-especial
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local p=1-tp -- p é o oponente
    if chk==0 then return Duel.GetLocationCount(p,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,p,LOCATION_DECK,0,1,nil,e,p) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,p,LOCATION_DECK)
end

function s.atkfilter(c)
    -- Filtra monstros de TREVAS virados para cima para o buff de ATK
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local p=1-tp -- Oponente
    
    -- Checa se ainda tem espaço no campo do oponente na hora de resolver
    if Duel.GetLocationCount(p,LOCATION_MZONE)<=0 then return end
    
    -- Pergunta ao oponente se ele quer invocar (Your opponent can...)
    if Duel.IsExistingMatchingCard(s.spfilter,p,LOCATION_DECK,0,1,nil,e,p) 
        and Duel.SelectYesNo(p,aux.Stringid(id,0)) then
        
        Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(p,s.spfilter,p,LOCATION_DECK,0,1,1,nil,e,p)
        
        -- "...and if they do" (se a invocação for um sucesso)
        if #g>0 and Duel.SpecialSummon(g,0,p,p,false,false,POS_FACEUP)>0 then
            
            -- Pega todos os monstros DARK do oponente e dá 2000 de ATK
            local dg=Duel.GetMatchingGroup(s.atkfilter,p,LOCATION_MZONE,0,nil)
            local tc=dg:GetFirst()
            for tc in aux.Next(dg) do
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_ATTACK)
                e1:SetValue(2000)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(e1)
            end
        end
    end
end