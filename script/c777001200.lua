-- Timerx Mad Surgeon
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Retornado ao déqui -> Special Summon
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EVENT_TO_DECK)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Efeito 2: Sp. Summon do déqui -> Pagar 1000 LP -> Fusion Summon (mão, campo, GY pro déqui)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_FUSION_SUMMON + CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.fuscon)
    --e2:SetCost(s.fuscost)
    e2:SetTarget(s.fustg)
    e2:SetOperation(s.fusop)
    c:RegisterEffect(e2)

    -- Efeito 3: No GY + Controlar Chronos -> Roubar do GY oponente, negar e mudar Tipo/Atributo
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_TODECK + CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, id + 2)
    e3:SetCondition(s.revcon)
    e3:SetTarget(s.revtg)
    e3:SetOperation(s.revop)
    c:RegisterEffect(e3)
end

-- ====================================================================
-- Efeito 1: Retornado ao déqui -> Special Summon
-- ====================================================================
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

-- ====================================================================
-- Efeito 2: Pagar 1000 LP e Fusion Summon
-- ====================================================================
function s.fuscon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end

function s.fuscost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 1000) end
    Duel.PayLPCost(tp, 1000)
end

function s.matfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end

function s.fusfilter(c, e, tp, m)
    return c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_FUSION, tp, false, false)
        and c:CheckFusionMaterial(m, nil, tp)
end

function s.fustg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        local mg = Duel.GetMatchingGroup(s.matfilter, tp, LOCATION_HAND + LOCATION_ONFIELD + LOCATION_GRAVE, 0, nil)
        return Duel.IsExistingMatchingCard(s.fusfilter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, mg)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_HAND + LOCATION_ONFIELD + LOCATION_GRAVE)
end

function s.fusop(e, tp, eg, ep, ev, re, r, rp)
    local mg = Duel.GetMatchingGroup(s.matfilter, tp, LOCATION_HAND + LOCATION_ONFIELD + LOCATION_GRAVE, 0, nil)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local tg = Duel.SelectMatchingCard(tp, s.fusfilter, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp, mg)
    local tc = tg:GetFirst()
    
    if tc then
        local mat = Duel.SelectFusionMaterial(tp, tc, mg, nil, tp)
        tc:SetMaterial(mat)
        Duel.SendtoDeck(mat, nil, SEQ_DECKSHUFFLE, REASON_EFFECT + REASON_MATERIAL + REASON_FUSION)
        Duel.BreakEffect()
        Duel.SpecialSummon(tc, SUMMON_TYPE_FUSION, tp, tp, false, false, POS_FACEUP)
        tc:CompleteProcedure()
    end
end

-- ====================================================================
-- Efeito 3: Roubar do GY, Negar e Declarar Tipo/Atributo
-- ====================================================================
function s.chronosfilter(c)
    -- ID direto conforme solicitado na correção do seu registro
    return c:IsFaceup() and c:GetOriginalCodeRule() == 777000640
end

function s.revcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.chronosfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.revfilter(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.revtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1 - tp) and s.revfilter(chkc, e, tp) end
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsAbleToDeck()
        and Duel.IsExistingTarget(s.revfilter, tp, 0, LOCATION_GRAVE, 1, nil, e, tp) end
        
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.revfilter, tp, 0, LOCATION_GRAVE, 1, 1, nil, e, tp)
    
    Duel.SetOperationInfo(0, CATEGORY_TODECK, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function s.revop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    
    -- Embaralha a si mesmo no déqui
    if c:IsRelateToEffect(e) and Duel.SendtoDeck(c, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) > 0 and c:IsLocation(LOCATION_DECK + LOCATION_EXTRA) then
        
        -- Special Summon do alvo no GY oponente (Para o SEU campo)
        if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP) then
            -- Nega os efeitos (EFFECT_DISABLE e EFFECT_DISABLE_EFFECT)
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(e1, true)
            local e2 = Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(e2, true)
            
            Duel.SpecialSummonComplete()
            
            -- "then you can declare 1 Monster Type and 1 Attribute..."
            if Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RACE)
                local rc = Duel.AnnounceRace(tp, 1, RACE_ALL)
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATTRIBUTE)
                local att = Duel.AnnounceAttribute(tp, 1, 0x7f)
                
                local e3 = Effect.CreateEffect(c)
                e3:SetType(EFFECT_TYPE_SINGLE)
                e3:SetCode(EFFECT_CHANGE_RACE)
                e3:SetValue(rc)
                e3:SetReset(RESET_EVENT + RESETS_STANDARD)
                tc:RegisterEffect(e3)
                
                local e4 = e3:Clone()
                e4:SetCode(EFFECT_CHANGE_ATTRIBUTE)
                e4:SetValue(att)
                tc:RegisterEffect(e4)
            end
        end
    end
end