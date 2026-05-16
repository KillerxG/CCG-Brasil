-- Creature-Warden Blast
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Opção 1: Controle de Monstros e Xyz Summon
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    -- Corrigido para CATEGORY_SPECIAL_SUMMON
    e1:SetCategory(CATEGORY_CONTROL | CATEGORY_SPECIAL_SUMMON) 
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E | TIMING_MAIN_END)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.opt1con)
    e1:SetTarget(s.opt1tg)
    e1:SetOperation(s.opt1op)
    c:RegisterEffect(e1)

    -- Opção 2: Anexar cartas do oponente a um Xyz seu
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E | TIMING_MAIN_END)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCondition(s.opt2con)
    e2:SetTarget(s.opt2tg)
    e2:SetOperation(s.opt2op)
    c:RegisterEffect(e2)
end

s.listed_series = {0x251}

-- ==========================================================
-- Opção 1: Controlar e Xyz Summon
-- ==========================================================
function s.ritfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x251) and c:IsType(TYPE_RITUAL)
end

function s.opt1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.ritfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.ctfilter(c)
    return c:IsFaceup() and c:HasLevel() and c:IsControlerCanBeChanged()
end

function s.opt1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1 - tp) and s.ctfilter(chkc) end
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) >= 2
        and Duel.IsExistingTarget(s.ctfilter, tp, 0, LOCATION_MZONE, 2, nil) end
        
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONTROL)
    local g = Duel.SelectTarget(tp, s.ctfilter, tp, 0, LOCATION_MZONE, 2, 2, nil)
    Duel.SetOperationInfo(0, CATEGORY_CONTROL, g, 2, 0, 0)
end

function s.opt1op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetTargetCards(e)
    if #g == 0 then return end
    
    if Duel.GetLocationCount(tp, LOCATION_MZONE) >= #g and Duel.GetControl(g, tp) > 0 then
        
        local mg = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)
        for tc in aux.Next(mg) do
            if tc:HasLevel() then
                local e1 = Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e1:SetCode(EFFECT_CHANGE_LEVEL)
                e1:SetValue(10)
                e1:SetReset(RESET_EVENT | RESETS_STANDARD)
                tc:RegisterEffect(e1)
            end
        end
        
        local xyzg = Duel.GetMatchingGroup(Card.IsXyzSummonable, tp, LOCATION_EXTRA, 0, nil, nil)
        if #xyzg > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
            local xyz = xyzg:Select(tp, 1, 1, nil):GetFirst()
            if xyz then
                Duel.XyzSummon(tp, xyz, nil)
            end
        end
    end
end

-- ==========================================================
-- Opção 2: Anexar cartas do oponente ao seu Xyz
-- ==========================================================
function s.xyzfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x251) and c:IsType(TYPE_XYZ)
end

function s.opt2con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.xyzfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.atchfilter(c)
    return not c:IsType(TYPE_TOKEN)
end

function s.opt2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsOnField() and chkc:IsControler(1 - tp) and s.atchfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.atchfilter, tp, 0, LOCATION_ONFIELD, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_XMATERIAL)
    local g = Duel.SelectTarget(tp, s.atchfilter, tp, 0, LOCATION_ONFIELD, 1, 2, nil)
end

function s.opt2op(e, tp, eg, ep, ev, re, r, rp)
    local tg = Duel.GetTargetCards(e)
    if #tg == 0 then return end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local xyzg = Duel.SelectMatchingCard(tp, s.xyzfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
    local xc = xyzg:GetFirst()
    
    if xc and not xc:IsImmuneToEffect(e) then
        Duel.Overlay(xc, tg)
    end
end