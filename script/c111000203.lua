-- Cyber-Cryptographic Salvage
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.filter(c)
    -- Verifica se a carta no cemitério é válida para ser adicionada à mão
    return c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
    -- Checa se existe pelo menos 1 alvo válido no seu cemitério
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    -- O jogador seleciona de 1 a 2 cartas no próprio cemitério
    local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,2,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Resgata os alvos selecionados na ativação
    local g=Duel.GetTargetCards(e)
    
    if #g>0 then
        -- Envia as cartas do cemitério para a mão
        Duel.SendtoHand(g,nil,REASON_EFFECT)
    end
end