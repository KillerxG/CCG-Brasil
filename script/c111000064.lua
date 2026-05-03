-- Pumpkin Storm
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

function s.cfilter(c)
    -- Verifica se o monstro está virado para cima e possui o tipo Plant (Planta)
    return c:IsFaceup() and c:IsRace(RACE_PLANT)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    -- A condição só é verdadeira se NÃO houver nenhum monstro Plant sob o seu controle
    return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.filter(c)
    -- Filtra as cartas no campo para pegar apenas Magias e Armadilhas
    return c:IsType(TYPE_SPELL+TYPE_TRAP)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    -- Como a própria armadilha ativada é uma armadilha no campo, essa condição sempre será verdadeira,
    -- mas a verificação de chk==0 é padrão e segura.
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil) end
    
    local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,0,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Coleta todas as Magias e Armadilhas do seu lado do campo na resolução
    local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,0,nil)
    
    if #g>0 then
        -- Destrói todas de uma vez, incluindo esta própria carta (o motor do EDOPro lida com isso perfeitamente)
        Duel.Destroy(g,REASON_EFFECT)
    end
end