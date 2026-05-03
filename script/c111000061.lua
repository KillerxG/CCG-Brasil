-- Recovery
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_RECOVER)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
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

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    -- Define o oponente (1-tp) como o alvo do efeito e os 1500 de LP como parâmetro
    Duel.SetTargetPlayer(1-tp)
    Duel.SetTargetParam(1500)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,1500)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Recupera a informação de quem é o jogador e qual o valor da cura
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    
    -- O oponente (p) recupera 1500 de LP (d)
    Duel.Recover(p,d,REASON_EFFECT)
end