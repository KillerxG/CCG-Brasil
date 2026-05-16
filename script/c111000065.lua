-- Gift of Pumpkins
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local p=1-tp -- Oponente
    -- Verifica se o oponente tem pelo menos 2 cartas no déqui para comprar
    if chk==0 then return Duel.IsPlayerCanDraw(p,2) end
    
    -- Define o oponente como alvo e o número 2 como o parâmetro da quantidade
    Duel.SetTargetPlayer(p)
    Duel.SetTargetParam(2)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,p,2)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Resgata a informação de quem é o jogador e a quantidade do alvo
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    
    -- Checa se ele ainda pode comprar na hora de resolver
    if Duel.IsPlayerCanDraw(p,d) then
        -- Abre uma janela perguntando ao oponente (p) se ele deseja realizar as compras
        if Duel.SelectYesNo(p,aux.Stringid(id,0)) then
            Duel.Draw(p,d,REASON_EFFECT)
        end
    end
end