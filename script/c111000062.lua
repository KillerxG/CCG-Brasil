-- Pumpkin Monster
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.cfilter(c)
    -- Verifica se o monstro está virado para cima e possui o tipo Plant (Planta)
    return c:IsFaceup() and c:IsRace(RACE_PLANT)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    -- A condição só é verdadeira se NÃO houver nenhum monstro Plant sob o seu controle
    return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.spfilter(c,e,tp)
    -- Checa se o monstro pode ser invocado do seu déqui (tp) no campo do oponente (1-tp)
    return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    -- Verifica se o oponente tem espaço na zona de monstros e se você tem um alvo válido no déqui
    if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Checa o espaço no campo do oponente novamente na hora de resolver
    if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    -- Abre o seu déqui para você selecionar qual monstro será "dado" ao oponente
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    
    if #g>0 then
        -- Os parâmetros 'tp, 1-tp' determinam que você (tp) invoca para o controle do oponente (1-tp)
        Duel.SpecialSummon(g,0,tp,1-tp,false,false,POS_FACEUP)
    end
end