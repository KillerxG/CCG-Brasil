-- Shinigami of Compulsion
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Special Summon da mão (Tributando 1 DARK - Suporte Lair of Darkness)
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Efeito 2: Se Tributado -> Oponente escolhe S/T do Déqui/Mão para adicionar à SUA mão
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_RELEASE)
    e2:SetCountLimit(1, id + 1)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    -- ====================================================================
    -- Mecânica Spirit Exata
    -- ====================================================================
    local sme,soe=Spirit.AddProcedure(c,EVENT_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS)
    --Mandatory return
    sme:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    sme:SetTarget(s.mrettg)
    sme:SetOperation(s.retop)
    --Optional return
    soe:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    soe:SetTarget(s.orettg)
    soe:SetOperation(s.retop)
end

-- ====================================================================
-- Efeito 1: Special Summon da mão (Com suporte à Lair of Darkness)
-- ====================================================================
function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.CheckReleaseGroupCost(tp, Card.IsAttribute, 1, true, nil, c, ATTRIBUTE_DARK) end
    local g = Duel.SelectReleaseGroupCost(tp, Card.IsAttribute, 1, 1, true, nil, c, ATTRIBUTE_DARK)
    Duel.Release(g, REASON_COST)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
    end
end

-- ====================================================================
-- Efeito 2: Oponente escolhe S/T para a sua mão
-- ====================================================================
function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsSpellTrap, 1 - tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, 1 - tp, LOCATION_HAND + LOCATION_DECK)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, 1 - tp, HINTMSG_ATOHAND)
    -- O oponente (1 - tp) seleciona a carta
    local g = Duel.SelectMatchingCard(1 - tp, Card.IsSpellTrap, 1 - tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil)
    
    if #g > 0 then
        -- A carta vai para a sua mão (tp)
        Duel.SendtoHand(g, tp, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

-- ====================================================================
-- Efeito 3: Spirit Procedure (Alvos e Operação)
-- ====================================================================
function s.mrettg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
end

function s.orettg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsAbleToHand() end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
end

function s.bossfilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777001120
end

function s.retop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    
    -- Retorno do Spirit
    if c:IsRelateToEffect(e) and Duel.SendtoHand(c, nil, REASON_EFFECT) > 0 and c:IsLocation(LOCATION_HAND) then
        
        -- Bônus do Boss: Oponente escolhe um monstro para a sua mão
        if Duel.IsExistingMatchingCard(s.bossfilter, tp, LOCATION_MZONE, 0, 1, nil)
            and Duel.IsExistingMatchingCard(Card.IsType, 1 - tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil, TYPE_MONSTER)
            and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
            
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG, 1 - tp, HINTMSG_ATOHAND)
            
            local g = Duel.SelectMatchingCard(1 - tp, Card.IsType, 1 - tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil, TYPE_MONSTER)
            
            if #g > 0 then
                Duel.SendtoHand(g, tp, REASON_EFFECT)
                Duel.ConfirmCards(1 - tp, g)
            end
        end
    end
end