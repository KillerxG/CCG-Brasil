-- Fly
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.rmfilter(c,tp)
    -- Checa se o monstro pode ser banido virado para baixo
    return c:IsAbleToRemove(tp,POS_FACEDOWN)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE)
    -- A informação de compra (Draw) não é garantida no SetOperationInfo porque é opcional para o oponente
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
    
    -- "and if you do": Se o monstro foi banido virado para baixo com sucesso
    if #g>0 and Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)>0 then
        local p=1-tp -- Oponente
        
        -- Pergunta ao oponente se ele quer comprar 1 carta do déqui
        if Duel.IsPlayerCanDraw(p,1) and Duel.SelectYesNo(p,aux.Stringid(id,0)) then
            Duel.Draw(p,1,REASON_EFFECT)
        end
    end
end