-- Ground Quake
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Ativar 1 de 2 efeitos
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_POSITION)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- ====================================================================
-- Filtros e Lógica de Seleção
-- ====================================================================
function s.filter(c)
    -- Verifica se o monstro está virado para cima e se pode ser baixado (exclui Links e Tokens)
    return c:IsFaceup() and c:IsCanTurnSet()
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    -- Checa a viabilidade das duas opções
    local b1 = Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_MZONE, 0, 1, nil)
    local b2 = Duel.IsExistingMatchingCard(s.filter, tp, 0, LOCATION_MZONE, 1, nil)
    
    -- O efeito só pode ativar se pelo menos uma opção for válida
    if chk == 0 then return b1 or b2 end
    
    local op = 0
    -- Abre o menu de seleção se ambas as jogadas forem possíveis
    if b1 and b2 then
        op = Duel.SelectOption(tp, aux.Stringid(id, 0), aux.Stringid(id, 1))
    elseif b1 then
        op = Duel.SelectOption(tp, aux.Stringid(id, 0))
    else
        op = Duel.SelectOption(tp, aux.Stringid(id, 1)) + 1
    end
    
    -- Salva a opção escolhida na memória do efeito para usar na resolução
    e:SetLabel(op)
    
    -- Projeta a alteração de posição para o simulador
    local g = nil
    if op == 0 then
        g = Duel.GetMatchingGroup(s.filter, tp, LOCATION_MZONE, 0, nil)
    else
        g = Duel.GetMatchingGroup(s.filter, tp, 0, LOCATION_MZONE, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_POSITION, g, #g, 0, 0)
end

-- ====================================================================
-- Resolução da Opção Escolhida
-- ====================================================================
function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local op = e:GetLabel()
    local g = nil
    
    -- Puxa o grupo correspondente à escolha feita anteriormente
    if op == 0 then
        g = Duel.GetMatchingGroup(s.filter, tp, LOCATION_MZONE, 0, nil)
    else
        g = Duel.GetMatchingGroup(s.filter, tp, 0, LOCATION_MZONE, nil)
    end
    
    -- Vira todas as cartas válidas do grupo para Defesa com a face para baixo
    if #g > 0 then
        Duel.ChangePosition(g, POS_FACEDOWN_DEFENSE)
    end
end