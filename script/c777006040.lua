-- Creature-Warden, Leonis
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Special Summon ao ser comprado (exceto na Draw Phase) e destruir 1 carta
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON | CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_TO_HAND)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.spcon)
    e1:SetCost(s.spcost) -- Adicionado custo para revelar a carta da mão
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Efeito 2: Colocar no fundo do Deck, reduzir ATK e anexar matéria Xyz
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetTarget(s.atktg)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)
end

s.listed_series = {0x251}

-- ==========================================================
-- Efeito 1: Gatilho de Compra (Draw)
-- ==========================================================
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    -- Verifica diretamente na memória da carta se ela foi comprada originada do Deck
    return c:IsReason(REASON_DRAW) and c:IsPreviousLocation(LOCATION_DECK) and Duel.GetCurrentPhase() ~= PHASE_DRAW
end

function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    -- Exige que a carta seja atestada na mão (local privado) e força a engine a exibi-la para validar a ativação
    if chk == 0 then return not c:IsPublic() end
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
    Duel.SetPossibleOperationInfo(0, CATEGORY_DESTROY, nil, 1, 1 - tp, LOCATION_ONFIELD)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        local g = Duel.GetMatchingGroup(nil, tp, 0, LOCATION_ONFIELD, nil)
        
        -- Pergunta opcionalmente se deseja destruir uma carta
        if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
            local sg = g:Select(tp, 1, 1, nil)
            Duel.HintSelection(sg)
            Duel.Destroy(sg, REASON_EFFECT)
        end
    end
end

-- ==========================================================
-- Efeito 2: Retornar ao Fundo do Deck, Reduzir ATK e Anexar
-- ==========================================================
function s.atktg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToDeck() and Duel.IsExistingMatchingCard(Card.IsFaceup, tp, 0, LOCATION_MZONE, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, c, 1, 0, 0)
end

function s.xyzfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x251)
end

function s.ritfilter(c)
    return c:IsType(TYPE_RITUAL) and c:IsMonster()
end

function s.atkop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SendtoDeck(c, nil, SEQ_DECKBOTTOM, REASON_EFFECT) > 0 and c:IsLocation(LOCATION_DECK) then
        local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil)
        if #g > 0 then
            for tc in aux.Next(g) do
                local e1 = Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_ATTACK)
                e1:SetValue(-1000)
                e1:SetReset(RESET_EVENT | RESETS_STANDARD)
                tc:RegisterEffect(e1)
            end
            
            local xyzg = Duel.GetMatchingGroup(s.xyzfilter, tp, LOCATION_MZONE, 0, nil)
            local ritg = Duel.GetMatchingGroup(s.ritfilter, tp, LOCATION_GRAVE, LOCATION_GRAVE, nil)
            
            if #xyzg > 0 and #ritg > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_XMATERIAL)
                local mat = ritg:Select(tp, 1, 1, nil)
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
                local xyz = xyzg:Select(tp, 1, 1, nil):GetFirst()
                if xyz and #mat > 0 then
                    Duel.Overlay(xyz, mat)
                end
            end
        end
    end
end