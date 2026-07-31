-- Shinigami Grimoire
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Adicionar do Déqui (Custo Opcional de Tributo para busca dupla)
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.thcost)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- Efeito 2: Setar do Cemitério e Tributar por efeito
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_LEAVE_GRAVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.setcon)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
end

-- ====================================================================
-- Efeito 1: Busca e Tributo Opcional
-- ====================================================================
function s.cfilter(c)
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsReleasable()
end

function s.thfilter(c)
    return c:IsSetCard(0x304) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.thfilter2(c, lv, code)
    -- Filtro do segundo alvo: Mesmo nível, nome diferente
    return c:IsSetCard(0x304) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
        and c:GetOriginalLevel() == lv and not c:IsCode(code)
end

function s.thfilter_double(c, tp)
    -- Verifica se, para a carta 'c', existe pelo menos um par compatível no déqui
    return s.thfilter(c) and Duel.IsExistingMatchingCard(s.thfilter2, tp, LOCATION_DECK, 0, 1, c, c:GetOriginalLevel(), c:GetCode())
end

function s.thcost(e, tp, eg, ep, ev, re, r, rp, chk)
    -- Salva na Label se o custo foi pago (0 = Não, 1 = Sim)
    e:SetLabel(0)
    if chk == 0 then return true end -- O target (s.thtg) já segura a validação base de busca
    
    -- Confere se pode tributar e se possui alvos viáveis para a busca dupla
    if Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_MZONE + LOCATION_HAND, 0, 1, nil)
        and Duel.IsExistingMatchingCard(s.thfilter_double, tp, LOCATION_DECK, 0, 1, nil, tp)
        and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
        
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
        local g = Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_MZONE + LOCATION_HAND, 0, 1, 1, nil)
        if #g > 0 and Duel.Release(g, REASON_COST) > 0 then
            e:SetLabel(1)
        end
    end
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    -- Recupera a informação do custo pago
    local tributed = (e:GetLabel() == 1)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    
    local g1 = nil
    if tributed then
        -- Se tributou, obrigatoriamente força a escolha de um monstro que possua um par no déqui
        g1 = Duel.SelectMatchingCard(tp, s.thfilter_double, tp, LOCATION_DECK, 0, 1, 1, nil, tp)
    else
        g1 = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    end
    
    if g1 and #g1 > 0 and Duel.SendtoHand(g1, nil, REASON_EFFECT) > 0 and g1:GetFirst():IsLocation(LOCATION_HAND) then
        Duel.ConfirmCards(1 - tp, g1)
        
        -- Aplica a segunda busca obrigatória
        if tributed then
            Duel.BreakEffect()
            local tc = g1:GetFirst()
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
            local g2 = Duel.SelectMatchingCard(tp, s.thfilter2, tp, LOCATION_DECK, 0, 1, 1, nil, tc:GetOriginalLevel(), tc:GetCode())
            if #g2 > 0 then
                Duel.SendtoHand(g2, nil, REASON_EFFECT)
                Duel.ConfirmCards(1 - tp, g2)
            end
        end
    end
end

-- ====================================================================
-- Efeito 2: Setar do Cemitério e Tributar por Efeito
-- ====================================================================
function s.bossfilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777001120
end

function s.setcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.bossfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.settg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsSSetable() end
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, c, 1, 0, 0)
end

function s.effcfilter(c)
    -- Diferente do custo padrão, esse efeito tributa por resolução (REASON_EFFECT)
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsReleasableByEffect()
end

function s.setop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsSSetable() then
        Duel.SSet(tp, c)
        
        -- Configura a penalidade de banimento nativamente na carta
        local e1 = Effect.CreateEffect(c)
        e1:SetDescription(3300)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
        e1:SetReset(RESET_EVENT + RESETS_REDIRECT)
        e1:SetValue(LOCATION_REMOVED)
        c:RegisterEffect(e1)
        
        -- Bônus opcional após Setar ("then you can...")
        local g = Duel.GetMatchingGroup(s.effcfilter, tp, LOCATION_MZONE + LOCATION_HAND, 0, nil)
        if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
            local sg = g:Select(tp, 1, 1, nil)
            Duel.Release(sg, REASON_EFFECT)
        end
    end
end