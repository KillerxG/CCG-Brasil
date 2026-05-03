-- Disorganized Books
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
    -- Verifica se você tem pelo menos 1 carta na mão para revelar e descartar
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Coleta todas as cartas da sua mão
    local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
    
    if #g>0 then
        -- "Reveal your hand to your opponent": Revela as cartas para o jogador 1-tp (oponente)
        Duel.ConfirmCards(1-tp,g)
        
        -- "your opponent choose 1 card in your hand": Passa o controle da seleção para o oponente
        Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DISCARD)
        local sg=g:Select(1-tp,1,1,nil)
        
        -- "and you discard it": Envia a carta escolhida para o cemitério
        if #sg>0 then
            Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
        end
        
        -- Embaralha a sua mão de volta para ocultar a ordem das cartas restantes
        Duel.ShuffleHand(tp)
    end
end