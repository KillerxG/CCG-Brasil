-- Possession
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito: Dar controle do seu monstro com maior ATK
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_CONTROL)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- ====================================================================
-- Filtro de Validação
-- ====================================================================
function s.filter(c)
    -- O monstro precisa estar virado para cima e o jogo precisa permitir a troca de controle
    return c:IsFaceup() and c:IsControlerCanBeChanged()
end

-- ====================================================================
-- Seleção do Alvo (Target)
-- ====================================================================
function s.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    -- Lógica para CHKC (Proteção caso o alvo seja selecionado de outra forma)
    if chkc then
        local g = Duel.GetMatchingGroup(s.filter, tp, LOCATION_MZONE, 0, nil)
        local max_atk = 0
        if #g > 0 then
            max_atk = g:GetMaxGroup(Card.GetAttack):GetFirst():GetAttack()
        end
        return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) 
            and s.filter(chkc) and chkc:GetAttack() == max_atk
    end
    
    -- Checa se a ativação é legal (se você tem pelo menos 1 monstro válido)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_MZONE, 0, 1, nil)
    end
    
    -- Puxa todos os seus monstros válidos
    local g = Duel.GetMatchingGroup(s.filter, tp, LOCATION_MZONE, 0, nil)
    
    -- A função GetMaxGroup cria um grupo exclusivo com o(s) monstro(s) de maior ATK
    local max_g = g:GetMaxGroup(Card.GetAttack)
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONTROL)
    
    -- Abre a janela de escolha. Se houver apenas 1, ele é escolhido automaticamente.
    -- Se houver empate, o "your choice" entra em ação aqui permitindo escolher 1.
    local tc = max_g:Select(tp, 1, 1, nil)
    
    Duel.SetTargetCard(tc)
    Duel.SetOperationInfo(0, CATEGORY_CONTROL, tc, 1, 0, 0)
end

-- ====================================================================
-- Resolução (Operation)
-- ====================================================================
function s.activate(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    
    -- Na resolução, verifica se o alvo ainda está no campo e virado para cima
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        -- Passa o controle do monstro para o oponente (1 - tp)
        Duel.GetControl(tc, 1 - tp)
    end
end