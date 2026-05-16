-- Giant Fossil
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DICE+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,2)
    -- O valor exato do dano não é definido no SetOperationInfo pois depende dos dados
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,0) 
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local d1,d2=Duel.TossDice(tp,2)
    local damage=(d1+d2)*300
    Duel.Damage(tp,damage,REASON_EFFECT)
end