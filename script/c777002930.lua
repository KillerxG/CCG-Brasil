-- Pyroland Guardian Attack
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Dar alvo, enviar 3 do topo do Deck, negar efeitos e (opcionalmente) destruir
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DECKDES | CATEGORY_DISABLE | CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E | TIMING_MAIN_END)
    e1:SetCountLimit(1, {id, 1})
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)

    -- Efeito 2: Enviada do Deck ao GY -> Mudar monstro do oponente para Posição de Defesa face para baixo
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_POSITION)
    e2:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY | EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCondition(s.poscon)
    e2:SetTarget(s.postg)
    e2:SetOperation(s.posop)
    c:RegisterEffect(e2)
end

s.listed_series = {0x278, 0x52}

-- ==========================================================
-- Efeito 1: Mill 3, Negação e Destruição (Condicional)
-- ==========================================================
function s.negtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(1 - tp) and chkc:IsOnField() and chkc:IsFaceup() end
    if chk == 0 then return Duel.IsPlayerCanDiscardDeck(tp, 3) 
        and Duel.IsExistingTarget(Card.IsFaceup, tp, 0, LOCATION_ONFIELD, 1, nil) end
        
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_NEGATE)
    local g = Duel.SelectTarget(tp, Card.IsFaceup, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
    
    Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 0, tp, 3)
    Duel.SetOperationInfo(0, CATEGORY_DISABLE, g, 1, 0, 0)
    Duel.SetPossibleOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end

function s.pgfilter(c)
    -- Verifica simultaneamente o setcode de Pyroland e Guardian no campo
    return c:IsFaceup() and c:IsSetCard(0x278) and c:IsSetCard(0x52)
end

function s.negop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    
    -- "send the top 3 cards of your Deck to the GY, and if you do..."
    if Duel.DiscardDeck(tp, 3, REASON_EFFECT) > 0 then
        local og = Duel.GetOperatedGroup()
        if og:FilterCount(Card.IsLocation, nil, LOCATION_GRAVE) > 0 then
            -- "...negate its effects until the end of this turn..."
            if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsDisabled() then
                Duel.NegateRelatedChain(tc, RESET_TURN_SET)
                
                local e1 = Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_DISABLE)
                e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e1:SetReset(RESET_EVENT | RESETS_STANDARD | RESET_PHASE | PHASE_END)
                tc:RegisterEffect(e1)
                
                local e2 = Effect.CreateEffect(c)
                e2:SetType(EFFECT_TYPE_SINGLE)
                e2:SetCode(EFFECT_DISABLE_EFFECT)
                e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e2:SetValue(RESET_TURN_SET)
                e2:SetReset(RESET_EVENT | RESETS_STANDARD | RESET_PHASE | PHASE_END)
                tc:RegisterEffect(e2)
                
                if tc:IsType(TYPE_TRAPMONSTER) then
                    local e3 = Effect.CreateEffect(c)
                    e3:SetType(EFFECT_TYPE_SINGLE)
                    e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
                    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                    e3:SetReset(RESET_EVENT | RESETS_STANDARD | RESET_PHASE | PHASE_END)
                    tc:RegisterEffect(e3)
                end
                
                -- "...then, if you control a 'Pyroland Guardian' card, you can destroy it."
                if Duel.IsExistingMatchingCard(s.pgfilter, tp, LOCATION_ONFIELD, 0, 1, nil) then
                    if Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
                        Duel.BreakEffect()
                        Duel.Destroy(tc, REASON_EFFECT)
                    end
                end
            end
        end
    end
end

-- ==========================================================
-- Efeito 2: Alterar Posição quando enviada do Deck ao GY
-- ==========================================================
function s.poscon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end

function s.posfilter(c)
    -- Garante a legalidade, impedindo de dar alvo em Links ou Fichas
    return c:IsFaceup() and c:IsCanTurnSet()
end

function s.postg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1 - tp) and s.posfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.posfilter, tp, 0, LOCATION_MZONE, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_POSCHANGE)
    local g = Duel.SelectTarget(tp, s.posfilter, tp, 0, LOCATION_MZONE, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_POSITION, g, 1, 0, 0)
end

function s.posop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.ChangePosition(tc, POS_FACEDOWN_DEFENSE)
    end
end