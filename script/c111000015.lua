-- Travel
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,5,tp,LOCATION_DECK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 then
        local g=Duel.GetDecktopGroup(tp,5)
        Duel.DisableShuffleCheck()
        Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
    end
end