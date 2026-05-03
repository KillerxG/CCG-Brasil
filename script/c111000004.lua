-- Possession
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_CONTROL)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.filter(c)
    -- Filtra monstros virados para cima que podem mudar de controle
    return c:IsFaceup() and c:IsAbleToChangeControler()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
    if chkc then 
        if not (chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc)) then return false end
        -- Se estiver checando o alvo (chkc), garante que o alvo seja um dos que têm o maior ATK
        local _,tg=g:GetMaxGroup(Card.GetAttack)
        return tg and tg:IsContains(chkc)
    end
    -- Verifica se o oponente tem espaço na zona de monstros e se você controla algum monstro válido
    if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and #g>0 end
    
    -- Separa apenas os monstros com o maior ATK para a seleção
    local _,tg=g:GetMaxGroup(Card.GetAttack)
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
    local sg=tg:Select(tp,1,1,nil)
    Duel.SetTargetCard(sg)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,sg,1,0,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    -- Checa se o monstro ainda está no campo e se há espaço no lado do oponente
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then
        -- Transfere o controle do monstro para o oponente (1-tp)
        Duel.GetControl(tc,1-tp)
    end
end