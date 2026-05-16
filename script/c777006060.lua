-- Creature-Warden, Pamella
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Special Summon ao ser comprada (exceto na Draw Phase), retornar carta e comprar
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON | CATEGORY_TODECK | CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_TO_HAND)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.spcon1)
    e1:SetCost(s.spcost1)
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)

    -- Efeito 2: Special Summon do GY e da mão (revelando 1 "Creature-Warden")
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCost(s.spcost2)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)
end

s.listed_series = {0x251}

-- ==========================================================
-- Efeito 1: Special Summon e Troca (Topo ou Fundo) -> Compra
-- ==========================================================
function s.spcon1(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsReason(REASON_DRAW) and c:IsPreviousLocation(LOCATION_DECK) and Duel.GetCurrentPhase() ~= PHASE_DRAW
end

function s.spcost1(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return not c:IsPublic() end
    Duel.ConfirmCards(1 - tp, c)
end

function s.sptg1(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
    Duel.SetPossibleOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_HAND)
    Duel.SetPossibleOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.spop1(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        local g = Duel.GetFieldGroup(tp, LOCATION_HAND, 0)
        
        -- "...then you can either place 1 card from your hand on the bottom or top of the Deck..."
        if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
            local sg = g:Select(tp, 1, 1, nil)
            local tc = sg:GetFirst()
            
            if tc then
                -- Menu perguntando para onde a carta vai (0 para Topo, 1 para Fundo)
                local op = Duel.SelectOption(tp, aux.Stringid(id, 3), aux.Stringid(id, 4))
                local seq = (op == 0) and SEQ_DECKTOP or SEQ_DECKBOTTOM
                
                if Duel.SendtoDeck(tc, nil, seq, REASON_EFFECT) > 0 and tc:IsLocation(LOCATION_DECK) then
                    -- "...then draw 1 card."
                    Duel.Draw(tp, 1, REASON_EFFECT)
                end
            end
        end
    end
end

-- ==========================================================
-- Efeito 2: Invocação Dupla (GY e Mão)
-- ==========================================================
function s.cfilter(c, e, tp)
    return c:IsSetCard(0x251) and c:IsMonster() and not c:IsPublic()
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.spcost2(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_HAND, 0, 1, nil, e, tp) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local g = Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_HAND, 0, 1, 1, nil, e, tp)
    Duel.ConfirmCards(1 - tp, g)
    Duel.ShuffleHand(tp)
    -- Memória atrelada para garantir que o monstro invocado seja o exato monstro revelado
    e:SetLabelObject(g:GetFirst())
end

function s.sptg2(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then 
        return not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT)
            and Duel.GetLocationCount(tp, LOCATION_MZONE) > 1
            and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
            and Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_HAND, 0, 1, nil, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 2, tp, LOCATION_HAND | LOCATION_GRAVE)
end

function s.spop2(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = e:GetLabelObject()
    if not c:IsRelateToEffect(e) or not tc then return end
    
    if Duel.GetLocationCount(tp, LOCATION_MZONE) < 2 or Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then return end
    
    local sg = Group.FromCards(c, tc)
    if not c:IsLocation(LOCATION_GRAVE) or not tc:IsLocation(LOCATION_HAND) then return end
    
    if Duel.SpecialSummon(sg, 0, tp, tp, false, false, POS_FACEUP) == 2 then
        for sc in aux.Next(sg) do
            local e1 = Effect.CreateEffect(c)
            e1:SetDescription(aux.Stringid(id, 5)) -- Código oficial do jogo para a mensagem "Vai para o fundo do Deck quando sair de campo"
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE | EFFECT_FLAG_CLIENT_HINT)
            e1:SetReset(RESET_EVENT | RESETS_REDIRECT)
            e1:SetValue(LOCATION_DECKBOT) -- 0x10001 (Fundo do Deck) 
            sc:RegisterEffect(e1, true)
        end
    end
end