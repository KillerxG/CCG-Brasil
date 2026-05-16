-- Celestial Guardian - Ceal
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Special Summon da mão (Efeito de Ignição)
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Efeito 2: Buscar "Celestial Guardian" Monster
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TOHAND | CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1, {id, 2})
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    local e3 = e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    -- Efeito 3: Banir para equipar e destruir
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_EQUIP | CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_MZONE | LOCATION_GRAVE)
    e4:SetCountLimit(1, {id, 3})
    e4:SetCost(s.eqcost)
    e4:SetTarget(s.eqtg)
    e4:SetOperation(s.eqop)
    c:RegisterEffect(e4)
end

s.listed_series = {0x252}
s.listed_names = {id}

-- ==========================================================
-- Efeito 1: Invocação da Mão
-- ==========================================================
function s.eqcfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_EQUIP)
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.eqcfilter, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
    end
end

-- ==========================================================
-- Efeito 2: Buscar "Celestial Guardian" Monstro
-- ==========================================================
function s.thfilter(c)
    return c:IsSetCard(0x252) and c:IsMonster() and not c:IsCode(id) and c:IsAbleToHand()
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

-- ==========================================================
-- Efeito 3: Equipar do GY e Destruir
-- ==========================================================
function s.eqcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToRemoveAsCost() end
    Duel.Remove(c, POS_FACEUP, REASON_COST)
end

function s.cgtfilter(c, tp)
    return c:IsFaceup() and c:IsSetCard(0x252) and c:IsMonster()
        and Duel.IsExistingTarget(s.eqspfilter, tp, LOCATION_GRAVE, 0, 1, nil, c)
end

function s.eqspfilter(c, ec)
    return c:IsType(TYPE_EQUIP) and c:IsSpell() and c:CheckEquipTarget(ec)
end

function s.eqtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return false end -- Desativa chkc nativo porque teremos alvos de múltiplas naturezas
    if chk == 0 then return Duel.IsExistingTarget(s.cgtfilter, tp, LOCATION_MZONE, 0, 1, e:GetHandler(), tp) end
    
    -- Alvo 1: O Monstro na sua mesa
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local g1 = Duel.SelectTarget(tp, s.cgtfilter, tp, LOCATION_MZONE, 0, 1, 1, e:GetHandler(), tp)
    local tc = g1:GetFirst()
    
    -- Alvo 2: A Magia de Equipamento no seu GY que atenda aos requisitos do Alvo 1
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
    local g2 = Duel.SelectTarget(tp, s.eqspfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, tc)
    
    Duel.SetOperationInfo(0, CATEGORY_EQUIP, g2, 1, tp, LOCATION_GRAVE)
    Duel.SetPossibleOperationInfo(0, CATEGORY_DESTROY, nil, 1, 1 - tp, LOCATION_ONFIELD)
end

function s.eqop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetTargetCards(e)
    
    -- Separa os alvos usando filtros para não confundir o monstro com a magia
    local tc = g:Filter(Card.IsMonster, nil):GetFirst()
    local eqc = g:Filter(Card.IsType, nil, TYPE_EQUIP):GetFirst()
    
    -- Confirma se ambos continuam alvos legais (e se o monstro não foi virado para baixo no meio da corrente)
    if tc and eqc and tc:IsRelateToEffect(e) and tc:IsFaceup() and eqc:IsRelateToEffect(e) then
        if Duel.Equip(tp, eqc, tc) then
            local dg = Duel.GetMatchingGroup(nil, tp, 0, LOCATION_ONFIELD, nil)
            if #dg > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
                local sg = dg:Select(tp, 1, 1, nil)
                Duel.HintSelection(sg)
                Duel.Destroy(sg, REASON_EFFECT)
            end
        end
    end
end