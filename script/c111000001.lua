-- Book of Corruption
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
    -- Filtra por monstros virados para cima do tipo Illusion (Ilusão)
    return c:IsFaceup() and c:IsRace(RACE_ILLUSION)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    -- A condição só é verdadeira se você NÃO controlar nenhum monstro Ilusão
    return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.spfilter(c,e,tp)
    -- Checa se o monstro pode ser invocado do Extra Deck por você (tp) no campo do oponente (1-tp)
    return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        -- Verifica se o oponente tem espaço na zona de monstros vindo do Extra Deck
        return Duel.GetLocationCountFromEx(1-tp,tp,nil,nil)>0 
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Checa o espaço novamente durante a resolução
    if Duel.GetLocationCountFromEx(1-tp,tp,nil,nil)<=0 then return end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    
    if #g>0 then
        -- Invoca o monstro selecionado. Os parâmetros 'tp, 1-tp' determinam que você (tp) 
        -- invoca para o controle do oponente (1-tp).
        Duel.SpecialSummon(g,0,tp,1-tp,false,false,POS_FACEUP)
    end
end