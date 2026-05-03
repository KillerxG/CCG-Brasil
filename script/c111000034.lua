-- Collecting Souls
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_HANDES)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    -- Verifica se você tem pelo menos 1 carta na mão para que a carta possa ser ativada
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
    
    local ct=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,ct,tp,1)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Coleta o grupo inteiro de cartas da sua mão na resolução
    local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
    
    if #g>0 then
        -- Envia todas as cartas simultaneamente para o cemitério, registrando como descarte por efeito
        Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
    end
end