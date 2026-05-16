-- Fairies Peace
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_HANDES)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.filter(c)
    -- O monstro deve estar virado para cima e ter um ataque maior que 0 para poder ser reduzido
    return c:IsFaceup() and c:GetAttack()>0
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
    -- Verifica se você tem um monstro válido no seu campo e pelo menos 1 carta na mão para descartar
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil)
        and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
        
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    -- Seleciona 1 monstro do seu próprio lado do campo como alvo
    Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    
    -- Checa se o alvo ainda é válido e se continua virado para cima
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        -- Salva o ataque atual antes de aplicar o efeito
        local pre_atk=tc:GetAttack()
        
        -- Zera o ataque do monstro
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(0)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        
        -- A condicional do "then": Se o ataque era maior que 0 e agora realmente é 0, o descarte prossegue
        if pre_atk>0 and tc:GetAttack()==0 then
            -- BreakEffect separa os tempos de resolução para o jogo entender que são etapas sequenciais
            Duel.BreakEffect()
            
            -- O jogador tp seleciona e descarta 1 carta da própria mão por efeito de carta
            Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD,nil)
        end
    end
end