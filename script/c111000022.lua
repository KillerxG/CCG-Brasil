-- Madness
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_HANDES+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    -- Verifica se há pelo menos 1 carta na mão para descartar e 2 no Extra Deck para banir viradas para baixo
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
        and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_EXTRA,0,2,nil,tp,POS_FACEDOWN) end
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_EXTRA)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Descarta 1 carta da mão
    if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD,nil)>0 then
        -- "then": Representa que a ação seguinte ocorre após o descarte com sucesso
        Duel.BreakEffect()
        
        local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_EXTRA,0,nil,tp,POS_FACEDOWN)
        if #g>=2 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            -- Permite que você escolha quais 2 cartas do déqui adicional serão banidas
            local sg=g:Select(tp,2,2,nil)
            Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
        end
    end
end