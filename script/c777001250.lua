-- Timerx Fissure
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Embaralhar Timerx e colocar cartas do oponente no fundo do déqui
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E + TIMING_MAIN_END)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.actcon)
    e1:SetTarget(s.acttg)
    e1:SetOperation(s.actop)
    c:RegisterEffect(e1)

    -- Efeito 2: No Cemitério + Controlar Chronos -> Setar esta carta
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetHintTiming(0, TIMING_END_PHASE)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.setcon)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
end

-- ====================================================================
-- Efeito 1: Remoção e Ativador de Combos
-- ====================================================================
function s.lvl5filter(c)
    -- Confere se você controla um "Timerx" de Nível 5 ou maior
    return c:IsFaceup() and c:IsSetCard(0x305) and c:IsLevelAbove(5)
end

function s.actcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.lvl5filter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.tdfilter(c)
    -- Aceita os "Timerx" originais no campo (SZone ou MZone) e no Cemitério
    return c:IsSetCard(0x305) and (c:IsType(TYPE_MONSTER) or c:IsOriginalType(TYPE_MONSTER)) 
        and c:IsAbleToDeck() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end

function s.acttg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.tdfilter, tp, LOCATION_ONFIELD + LOCATION_GRAVE, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_ONFIELD + LOCATION_GRAVE)
    Duel.SetPossibleOperationInfo(0, CATEGORY_TODECK, nil, 1, 1 - tp, LOCATION_ONFIELD)
end

function s.actop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter), tp, LOCATION_ONFIELD + LOCATION_GRAVE, 0, nil)
    if #g == 0 then return end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    -- Permite escolher "qualquer número" (de 1 até o máximo disponível)
    local sg = g:Select(tp, 1, 99, nil)
    
    if #sg > 0 then
        Duel.HintSelection(sg)
        if Duel.SendtoDeck(sg, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) > 0 then
            
            -- Confere quantos monstros efetivamente voltaram para o déqui / Extra Deck
            local og = Duel.GetOperatedGroup()
            local ct = og:FilterCount(Card.IsLocation, nil, LOCATION_DECK + LOCATION_EXTRA)
            
            if ct > 0 then
                local opg = Duel.GetMatchingGroup(Card.IsAbleToDeck, tp, 0, LOCATION_ONFIELD, nil)
                -- Opcional: "then you can place cards your opponent controls..."
                if #opg > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
                    Duel.BreakEffect()
                    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
                    -- Permite selecionar "até o número de monstros embaralhados" (1 a ct)
                    local btg = opg:Select(tp, 1, ct, nil)
                    
                    Duel.HintSelection(btg)
                    Duel.SendtoDeck(btg, nil, SEQ_DECKBOTTOM, REASON_EFFECT)
                end
            end
        end
    end
end

-- ====================================================================
-- Efeito 2: Setar do Cemitério
-- ====================================================================
function s.chronosfilter(c)
    return c:IsFaceup() and c:GetOriginalCodeRule() == 777000640
end

function s.setcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.chronosfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.settg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsSSetable() end
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, e:GetHandler(), 1, 0, 0)
end

function s.setop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsSSetable() then
        Duel.SSet(tp, c)
        -- Trava para banir a carta quando ela deixar o campo
        local e1 = Effect.CreateEffect(c)
        e1:SetDescription(3300) -- Mensagem visual no sistema indicando o banimento pendente
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
        e1:SetReset(RESET_EVENT + RESETS_REDIRECT)
        e1:SetValue(LOCATION_REMOVED)
        c:RegisterEffect(e1)
    end
end