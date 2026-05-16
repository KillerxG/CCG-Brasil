--West Royal Dragon Travel
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Excavate and add to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost) 
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
	--(2)Grant effect to "Weast Royal Dragon - Irya"
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.quickcon)
    e2:SetTarget(s.rmtg)
    e2:SetOperation(s.rmop)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(s.eftg)
    e3:SetLabelObject(e2)
    c:RegisterEffect(e3)
end
--(1)Excavate and add to hand
function s.cfilter(c, tp)
    return c:IsRitualMonster() and c:IsLevelAbove(7) and (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_FIEND)) and not c:IsPublic()
        and Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) >= c:GetLevel()
end
function s.thfilter(c)
    return c:IsSetCard(0x288) and c:IsAbleToHand()
end
function s.tgfilter(c)
    return c:IsAbleToGrave()
end
function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_HAND, 0, 1, nil, tp) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local g = Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_HAND, 0, 1, 1, nil, tp)
    Duel.ConfirmCards(1-tp, g)
    Duel.ShuffleHand(tp)
    e:SetLabel(g:GetFirst():GetLevel())
end
function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_HAND, 0, 1, nil, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
end
function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local ct = e:GetLabel()
    if ct == 0 or Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) < ct then return end
    Duel.ConfirmDecktop(tp, ct)
    local g = Duel.GetDecktopGroup(tp, ct)
    if #g > 0 then
        Duel.DisableShuffleCheck()
        if g:IsExists(s.thfilter, 1, nil) then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
            local sg = g:FilterSelect(tp, s.thfilter, 1, 1, nil)
            if #sg > 0 and Duel.SendtoHand(sg, nil, REASON_EFFECT) > 0 then
                Duel.ConfirmCards(1-tp, sg)
                Duel.ShuffleHand(tp)
                g:Sub(sg)
                if #g > 0 and g:IsExists(s.tgfilter, 1, nil) then
                    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
                    local tg = g:FilterSelect(tp, s.tgfilter, 1, 1, nil)
                    if #tg > 0 then
                        Duel.SendtoGrave(tg, REASON_EFFECT)
                    end
                end
            end
        end
        Duel.ShuffleDeck(tp)
    end
end
--(2)Grant effect to "Weast Royal Dragon - Irya"
function s.eftg(e,c)
	return c:IsType(TYPE_EFFECT) and c:IsCode(777003710) and c:IsFaceup()
end
function s.quickcon(e, tp, eg, ep, ev, re, r, rp)
    local ph = Duel.GetCurrentPhase()
    return ph == PHASE_MAIN1 or ph == PHASE_MAIN2
end
function s.rmfilter(c, e, tp)
    if not (c:IsRace(RACE_DRAGON) and c:IsAbleToRemove() and not c:IsType(TYPE_TOKEN)) then return false end
    if c:IsLocation(LOCATION_GRAVE) then
        return c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    else
        return c:IsFaceup()
    end
end
function s.rmtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE | LOCATION_GRAVE) and s.rmfilter(chkc, e, tp) end
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and Duel.IsExistingTarget(s.rmfilter, tp, 0, LOCATION_MZONE | LOCATION_GRAVE, 1, nil, e, tp)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectTarget(tp, s.rmfilter, tp, 0, LOCATION_MZONE | LOCATION_GRAVE, 1, 1, nil, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end
function s.rmop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc, POS_FACEUP, REASON_EFFECT) > 0 then
        if tc:IsLocation(LOCATION_REMOVED) and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
            Duel.BreakEffect()
            Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
        end
    end
end