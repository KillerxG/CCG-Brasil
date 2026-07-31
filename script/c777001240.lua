-- Timerx Gate
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Enviar da mão pro GY -> Special Summon do déqui -> Bônus Chronos
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOGRAVE + CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Efeito 2: Banir do GY -> Buscar "Polymerization" ou "Fusion"
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.thcon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

-- ====================================================================
-- Efeito 1: Enviar e Invocar (Resolução Contínua)
-- ====================================================================
function s.tgfilter(c, e, tp)
    -- O monstro precisa ir da mão pro GY e você precisa ter um alvo válido no déqui
    return c:IsSetCard(0x305) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
        and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_DECK, 0, 1, nil, e, tp)
end

function s.spfilter(c, e, tp)
    return c:IsSetCard(0x305) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.chronosfilter(c)
    return c:IsFaceup() and c:GetOriginalCodeRule() == 777000640
end

function s.exgyfilter(c)
    return c:IsType(TYPE_FUSION) and c:IsAbleToGrave()
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingMatchingCard(s.tgfilter, tp, LOCATION_HAND, 0, 1, nil, e, tp) end
        
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_HAND)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end

function s.activate(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.tgfilter, tp, LOCATION_HAND, 0, 1, 1, nil, e, tp)
    
    -- "and if you do..."
    if #g > 0 and Duel.SendtoGrave(g, REASON_EFFECT) > 0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local sg = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
        
        if #sg > 0 and Duel.SpecialSummon(sg, 0, tp, tp, false, false, POS_FACEUP) > 0 then
            
            -- "then, if you control Ruler of Timerx - Chronos..."
            if Duel.IsExistingMatchingCard(s.chronosfilter, tp, LOCATION_MZONE, 0, 1, nil) 
                and Duel.IsExistingMatchingCard(s.exgyfilter, tp, LOCATION_EXTRA, 0, 1, nil)
                and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
                
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
                local exg = Duel.SelectMatchingCard(tp, s.exgyfilter, tp, LOCATION_EXTRA, 0, 1, 1, nil)
                Duel.SendtoGrave(exg, REASON_EFFECT)
            end
        end
    end
end

-- ====================================================================
-- Efeito 2: Buscar Magia de Fusão
-- ====================================================================
function s.confilter(c)
    return c:IsFaceup() and c:IsSetCard(0x305) and c:IsType(TYPE_MONSTER)
end

function s.thcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.confilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.polyfilter(c)
    -- O SetCard 0x46 engloba tanto "Polymerization" quanto "Fusion" na engine do EDOPro
    return c:IsType(TYPE_SPELL) and c:IsSetCard(0x46) and c:IsAbleToHand()
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.polyfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.polyfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end