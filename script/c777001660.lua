-- Shinigami of Nightmare
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

    -- Efeito 2: Se Tributado -> Alvejar e Tributar 1 monstro do oponente
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_RELEASE)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_RELEASE)
    e2:SetCountLimit(1, id + 1)
    e2:SetTarget(s.reltg)
    e2:SetOperation(s.relop)
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
-- Efeito 1: Special Summon da mão
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
-- Efeito 2: Tributar por Efeito (Target)
-- ====================================================================
function s.relfilter(c)
    return c:IsFaceup() and c:IsReleasableByEffect()
end

function s.reltg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1 - tp) and s.relfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.relfilter, tp, 0, LOCATION_MZONE, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
    local g = Duel.SelectTarget(tp, s.relfilter, tp, 0, LOCATION_MZONE, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_RELEASE, g, 1, 0, 0)
end

function s.relop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Release(tc, REASON_EFFECT)
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

function s.trapfilter(c)
    return c:IsSetCard(0x304) and c:IsType(TYPE_TRAP) and not c:IsForbidden()
end

function s.retop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    
    if c:IsRelateToEffect(e) and Duel.SendtoHand(c, nil, REASON_EFFECT) > 0 and c:IsLocation(LOCATION_HAND) then
        
        -- Bônus do Boss: Colocar Armadilha do deck face-up no campo do oponente
        if Duel.IsExistingMatchingCard(s.bossfilter, tp, LOCATION_MZONE, 0, 1, nil)
            and Duel.GetLocationCount(1 - tp, LOCATION_SZONE) > 0
            and Duel.IsExistingMatchingCard(s.trapfilter, tp, LOCATION_DECK, 0, 1, nil)
            and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
            
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOFIELD)
            
            local g = Duel.SelectMatchingCard(tp, s.trapfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
            local tc = g:GetFirst()
            
            if tc then
                -- MoveToField com (jogador alvo = 1 - tp) e (posição = POS_FACEUP)
                Duel.MoveToField(tc, tp, 1 - tp, LOCATION_SZONE, POS_FACEUP, true)
            end
        end
    end
end