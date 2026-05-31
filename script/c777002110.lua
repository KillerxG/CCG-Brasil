-- Rockslash Ancient Tome
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Buscar 1 "Rockslash" e aplicar Dano
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- Efeito 2: Baixar do GY e Causar Dano
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.setcon)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
end

-- ====================================================================
-- Efeito 1: Buscar carta e Causar/Tomar Dano
-- ====================================================================
function s.thfilter(c)
    -- Busca qualquer carta "Rockslash", exceto outra cópia deste mesmo tomo
    return c:IsSetCard(0x309) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    -- Informa à engine que algum jogador vai tomar dano de efeito
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, PLAYER_ALL, 0)
end

function s.harunafilter(c)
    -- Checa se a "Master of Rockslash - Haruna" está virada para cima no seu campo
    return c:IsFaceup() and c:GetOriginalCode() == 777002010
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    
    if #g > 0 and Duel.SendtoHand(g, nil, REASON_EFFECT) > 0 and g:GetFirst():IsLocation(LOCATION_HAND) then
        Duel.ConfirmCards(1 - tp, g)
        
        -- "then," exige a quebra de efeito para o timing correto
        Duel.BreakEffect()
        
        -- Checa a presença da Haruna para decidir o alvo do dano
        if Duel.IsExistingMatchingCard(s.harunafilter, tp, LOCATION_MZONE, 0, 1, nil) then
            Duel.Damage(1 - tp, 500, REASON_EFFECT)
        else
            Duel.Damage(tp, 1000, REASON_EFFECT)
        end
    end
end

-- ====================================================================
-- Efeito 2: Setar do GY e Causar Dano
-- ====================================================================
function s.setcon(e, tp, eg, ep, ev, re, r, rp)
    -- Só pode ativar se a Haruna estiver no campo
    return Duel.IsExistingMatchingCard(s.harunafilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.settg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsSSetable() end
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, 500)
end

function s.setop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    
    if c:IsRelateToEffect(e) and c:IsSSetable() then
        if Duel.SSet(tp, c) > 0 then
            -- Adiciona a restrição de banimento (Banish when it leaves the field)
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetReset(RESET_EVENT + RESETS_REDIRECT)
            e1:SetValue(LOCATION_REMOVED)
            c:RegisterEffect(e1)
            
            -- "and if you do," também exige a quebra de efeito e causa o dano ao oponente
            Duel.BreakEffect()
            Duel.Damage(1 - tp, 500, REASON_EFFECT)
        end
    end
end