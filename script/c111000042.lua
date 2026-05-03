-- Problems
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    -- Checa se você controla 2 ou mais monstros
    return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>=2
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
    if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,0,1,nil) end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    
    if tc and tc:IsRelateToEffect(e) then
        -- Captura o ATK original antes do monstro sair do campo
        local atk=tc:GetBaseAttack()
        -- Tratamento para monstros com ATK "?" que retornam valor negativo no código
        if atk<0 then atk=0 end 
        
        -- Destrói o monstro. Se for um sucesso e o ATK for maior que 0, aplica o dano
        if Duel.Destroy(tc,REASON_EFFECT)>0 and atk>0 then
            Duel.BreakEffect() -- Representa o "then" do seu texto
            Duel.Damage(tp,atk,REASON_EFFECT)
        end
    end
end