-- Mischief
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    -- Verifica se você tem cartas na mão para misturar no déqui e se AMBOS os jogadores podem comprar 1 carta
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
        and Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
        
    local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,tp,LOCATION_HAND)
    -- Como a compra é mútua, informamos ao motor do jogo que o Player 0 (ambos) comprará cartas
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Coleta todas as cartas da sua mão na resolução
    local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
    if #g==0 then return end
    
    -- Envia toda a mão para o déqui e o embaralha
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    
    -- Verifica se pelo menos 1 carta foi parar efetivamente no déqui (para cumprir o "then")
    local og=Duel.GetOperatedGroup()
    if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
        -- Separa a primeira ação (devolver) da segunda ação (comprar) na mesma corrente
        Duel.BreakEffect()
        
        -- Ambos os jogadores compram 1 carta
        Duel.Draw(tp,1,REASON_EFFECT)
        Duel.Draw(1-tp,1,REASON_EFFECT)
    end
end