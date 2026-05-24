-- Silver Fangs' Sacred Scriptures
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Busca e Retorno para a Mão (caso controle a Kyara)
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- Efeito 2: Setar ou Adicionar do GY
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.gycon)
    e2:SetTarget(s.gytg)
    e2:SetOperation(s.gyop)
    c:RegisterEffect(e2)
end

-- ====================================================================
-- Efeito 1: Buscar do Deck e Recuperar da Magia
-- ====================================================================
function s.thfilter(c)
    return c:IsSetCard(0x307) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.kyarafilter(c)
    -- Procura o ID 777001320 pelo nome original
    return c:IsFaceup() and c:GetOriginalCode() == 777001320
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    
    if #g > 0 and Duel.SendtoHand(g, nil, REASON_EFFECT) > 0 then
        Duel.ConfirmCards(1 - tp, g)
        
        local c = e:GetHandler()
        -- CORREÇÃO: Adicionado "and c:GetFlagEffect(id) == 0". 
        -- Se ela tiver a flag de ter vindo do GY, a escolha de voltar para a mão NÃO aparece!
        if c:IsRelateToEffect(e) and Duel.IsExistingMatchingCard(s.kyarafilter, tp, LOCATION_MZONE, 0, 1, nil) 
            and c:GetFlagEffect(id) == 0 then
            
            if Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
                Duel.BreakEffect()
                c:CancelToGrave() 
                Duel.SendtoHand(c, nil, REASON_EFFECT) 
            end
        end
    end
end

-- ====================================================================
-- Efeito 2: Setar do Cemitério ou Adicionar à Mão (Kyara)
-- ====================================================================
function s.gycon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:GetTurnID() ~= Duel.GetTurnCount()
        and Duel.GetLP(tp) > Duel.GetLP(1 - tp) 
        and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard, 0x307), tp, LOCATION_MZONE, 0, 1, nil)
end

function s.gytg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local b1 = c:IsSSetable()
    local b2 = Duel.IsExistingMatchingCard(s.kyarafilter, tp, LOCATION_MZONE, 0, 1, nil) and c:IsAbleToHand()
    if chk == 0 then return b1 or b2 end
    
    if b2 then
        Duel.SetPossibleOperationInfo(0, CATEGORY_TOHAND, c, 1, 0, 0)
    end
    if b1 then
        Duel.SetPossibleOperationInfo(0, CATEGORY_LEAVE_GRAVE, c, 1, 0, 0)
    end
end

function s.gyop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    
    local b1 = c:IsSSetable()
    local b2 = Duel.IsExistingMatchingCard(s.kyarafilter, tp, LOCATION_MZONE, 0, 1, nil) and c:IsAbleToHand()
    
    if b2 and (not b1 or Duel.SelectYesNo(tp, aux.Stringid(id, 3))) then
        Duel.SendtoHand(c, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, c)
    elseif b1 then
        Duel.SSet(tp, c)
        
        -- O SEGREDO: Registra a flag invisível na carta para o efeito 1 saber que ela veio do GY
        c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD, 0, 1)
        
        -- Regra: Banir quando deixar o campo
        local e1 = Effect.CreateEffect(c)
        e1:SetDescription(3300)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
        e1:SetReset(RESET_EVENT + RESETS_REDIRECT)
        e1:SetValue(LOCATION_REMOVED)
        c:RegisterEffect(e1)
    end
end