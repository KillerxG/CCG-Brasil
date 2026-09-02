-- Corrupted Okami - Yomigami
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Descartar para buscar a Magia de Campo
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.thcost)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- Efeito 2: Reviver 1 Yokai Tuner do GY e (opcionalmente) aumentar Nível em 2
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1, id + 1)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

-- ====================================================================
-- Efeito 1: Descartar e Buscar a Cidade
-- ====================================================================
function s.thcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsDiscardable() end
    Duel.SendtoGrave(c, REASON_COST + REASON_DISCARD)
end

function s.thfilter(c)
    -- Busca especificamente pelo ID que você forneceu da Magia de Campo
    return c:IsCode(777006270) and c:IsAbleToHand()
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.thfilter), tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

-- ====================================================================
-- Efeito 2: Reviver Yokai Tuner e Manipular Nível
-- ====================================================================
function s.spfilter(c, e, tp)
    -- O alvo precisa ser da raça Yokai e do tipo Tuner
    return c:IsRace(RACE_YOKAI) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc, e, tp) end
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingTarget(s.spfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.spfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, tp, LOCATION_GRAVE)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    
    -- Invocação Especial
    if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        
        -- Verifica se o monstro tem nível para poder aumentá-lo e pergunta se o jogador deseja
        if tc:HasLevel() and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
            local e1 = Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_LEVEL)
            e1:SetValue(2)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(e1)
        end
    end
end