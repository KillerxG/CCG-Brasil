-- Timerx Research
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Buscar do déqui e opcionalmente embaralhar até 2 monstros "Timerx"
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- Efeito 2: Banir do GY -> Alvejar até 3 -> Embaralhar -> Bônus Chronos
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id + 1)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.tdtg)
    e2:SetOperation(s.tdop)
    c:RegisterEffect(e2)
end

-- ====================================================================
-- Efeito 1: Busca e Embaralhar Opcional (Ativador de Combos)
-- ====================================================================
function s.thfilter(c)
    return c:IsSetCard(0x305) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.tdfilter1(c)
    -- Na mão a carta é privada (OK), mas no campo precisa estar Face-up para comprovar o SetCard
    return c:IsSetCard(0x305) and c:IsOriginalType(TYPE_MONSTER) and c:IsAbleToDeck()
        and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    Duel.SetPossibleOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_HAND + LOCATION_ONFIELD)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    
    if #g > 0 and Duel.SendtoHand(g, nil, REASON_EFFECT) > 0 and g:GetFirst():IsLocation(LOCATION_HAND) then
        Duel.ConfirmCards(1 - tp, g)
        
        -- Após buscar, checa se há peças válidas para ativar o "then you can shuffle..."
        local sg = Duel.GetMatchingGroup(s.tdfilter1, tp, LOCATION_HAND + LOCATION_ONFIELD, 0, nil)
        if #sg > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
            local tg = sg:Select(tp, 1, 2, nil)
			Duel.ConfirmCards(1 - tp, tg)
            Duel.SendtoDeck(tg, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
        end
    end
end

-- ====================================================================
-- Efeito 2: Reciclagem do GY com Bônus de Remoção
-- ====================================================================
function s.tdfilter2(c)
    return c:IsSetCard(0x305) and c:IsOriginalType(TYPE_MONSTER) and c:IsAbleToDeck()
        and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end

function s.chronosfilter(c)
    return c:IsFaceup() and c:GetOriginalCodeRule() == 777000640
end

function s.tdtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_ONFIELD + LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter2(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.tdfilter2, tp, LOCATION_ONFIELD + LOCATION_GRAVE, 0, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectTarget(tp, s.tdfilter2, tp, LOCATION_ONFIELD + LOCATION_GRAVE, 0, 1, 3, nil)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, #g, 0, 0)
end

function s.tdop(e, tp, eg, ep, ev, re, r, rp)
    local tg = Duel.GetTargetCards(e)
    if #tg > 0 and Duel.SendtoDeck(tg, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) > 0 then
        
        -- Checa se as cartas realmente foram para o déqui (ou Extra Deck, caso sejam monstros de Extra Deck)
        local og = Duel.GetOperatedGroup()
        if og:FilterCount(Card.IsLocation, nil, LOCATION_DECK + LOCATION_EXTRA) > 0 then
            
            -- Bônus: "then, if you control Ruler of Timerx - Chronos..."
            local op_cards = Duel.GetMatchingGroup(Card.IsAbleToDeck, tp, 0, LOCATION_ONFIELD, nil)
            if #op_cards > 0 and Duel.IsExistingMatchingCard(s.chronosfilter, tp, LOCATION_MZONE, 0, 1, nil) then
                if Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
                    Duel.BreakEffect()
                    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
                    local bg = op_cards:Select(tp, 1, 1, nil)
                    
                    -- "place 1 card your opponent controls on the bottom of the Deck" (Não alveja)
                    Duel.HintSelection(bg)
                    Duel.SendtoDeck(bg, nil, SEQ_DECKBOTTOM, REASON_EFFECT)
                end
            end
        end
    end
end