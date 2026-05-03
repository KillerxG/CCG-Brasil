-- Nightmare
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    -- Checa se você tem pelo menos 1 carta na mão para descartar
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
    
    -- Descarta a mão inteira
    if #g>0 then
        local ct=Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
        
        -- "then": Se as cartas foram descartadas com sucesso, verifica se o oponente pode e quer comprar
        if ct>0 then
            local p=1-tp -- Oponente
            
            -- Verifica se o oponente tem cartas suficientes no déqui para comprar e pergunta se ele quer
            if Duel.IsPlayerCanDraw(p,ct) and Duel.SelectYesNo(p,aux.Stringid(id,0)) then
                Duel.BreakEffect()
                Duel.Draw(p,ct,REASON_EFFECT)
            end
        end
    end
end