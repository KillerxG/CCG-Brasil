-- Attack Up
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.filter(c)
    -- O alvo precisa ser um monstro virado para cima para poder receber o bônus de ATK
    return c:IsFaceup()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
    -- Verifica se existe pelo menos 1 monstro virado para cima no campo do oponente (0, LOCATION_MZONE)
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    -- Você escolhe exatamente 1 monstro alvo no campo inimigo
    Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    -- Checa se o alvo ainda é válido e se continua virado para cima na resolução
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        -- Aplica o bônus de 1000 ATK
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(1000)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD) -- Permanece enquanto a carta não resetar (for destruída, banida, etc.)
        tc:RegisterEffect(e1)
    end
end