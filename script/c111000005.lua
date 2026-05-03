-- Special Room
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local p=1-tp -- Oponente
    local ht=Duel.GetFieldGroupCount(p,LOCATION_HAND,0)
    local ct=6-ht
    
    -- Verifica se o oponente tem menos de 6 cartas na mão e se o déqui dele tem cartas suficientes
    if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(p,ct) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,p,ct)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local p=1-tp -- Oponente
    local ht=Duel.GetFieldGroupCount(p,LOCATION_HAND,0)
    local ct=6-ht
    
    -- Recalcula na resolução, caso a quantidade de cartas na mão do oponente tenha mudado em alguma corrente
    if ct>0 and Duel.IsPlayerCanDraw(p,ct) then
        -- Pergunta ao oponente se ele quer comprar as cartas
        if Duel.SelectYesNo(p,aux.Stringid(id,0)) then
            Duel.Draw(p,ct,REASON_EFFECT)
        end
    end
end