--Northern Guild New Adventurer
--Scripted by KillerxG
local s, id = GetID()
function s.initial_effect(c)
    --(1)Activate: Special from Deck, Fusion Summon, Normal Summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end
--(1)Activate: Special from Deck, Fusion Summon, Normal Summon
function s.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return false end
    local b1 = Duel.GetFlagEffect(tp, id) == 0 and s.tg1(e, tp, eg, ep, ev, re, r, rp, 0)
    local b2 = Duel.GetFlagEffect(tp, id + 1) == 0 and s.tg2(e, tp, eg, ep, ev, re, r, rp, 0)
    local b3 = Duel.GetFlagEffect(tp, id + 2) == 0 and s.tg3(e, tp, eg, ep, ev, re, r, rp, 0)
    if chk == 0 then return b1 or b2 or b3 end
    local ops = {}
    local opval = {}
    if b1 then table.insert(ops, aux.Stringid(id, 0)); table.insert(opval, 1) end
    if b2 then table.insert(ops, aux.Stringid(id, 1)); table.insert(opval, 2) end
    if b3 then table.insert(ops, aux.Stringid(id, 2)); table.insert(opval, 3) end
    local select = Duel.SelectOption(tp, table.unpack(ops))
    local op = opval[select + 1]
    e:SetLabel(op)
    Duel.RegisterFlagEffect(tp, id + (op - 1), RESET_PHASE | PHASE_END, 0, 1)
    if op == 1 then
        e:SetCategory(CATEGORY_SPECIAL_SUMMON | CATEGORY_HANDES)
        e:SetProperty(0)
        s.tg1(e, tp, eg, ep, ev, re, r, rp, 1)
    elseif op == 2 then
        e:SetCategory(CATEGORY_SPECIAL_SUMMON | CATEGORY_FUSION_SUMMON)
        e:SetProperty(0)
        s.tg2(e, tp, eg, ep, ev, re, r, rp, 1)
    elseif op == 3 then
        e:SetCategory(CATEGORY_SUMMON)
        e:SetProperty(0)
        s.tg3(e, tp, eg, ep, ev, re, r, rp, 1)
    end
end
function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local op = e:GetLabel()
    if op == 1 then
        s.op1(e, tp, eg, ep, ev, re, r, rp)
    elseif op == 2 then
        s.op2(e, tp, eg, ep, ev, re, r, rp)
    elseif op == 3 then
        s.op3(e, tp, eg, ep, ev, re, r, rp)
    end
end
--Special from Deck
function s.discard_filter(c)
    return c:IsSetCard(0x280) and c:IsDiscardable(REASON_EFFECT)
end
function s.spfilter(c, e, tp)
    return c:IsSetCard(0x280) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function s.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.discard_filter, tp, LOCATION_HAND, 0, 1, e:GetHandler())
            and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_DECK, 0, 1, nil, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_HANDES, nil, 1, tp, LOCATION_HAND)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end
function s.op1(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DISCARD)
    local g = Duel.SelectMatchingCard(tp, s.discard_filter, tp, LOCATION_HAND, 0, 1, 1, e:GetHandler())    
    if #g > 0 and Duel.SendtoGrave(g, REASON_EFFECT | REASON_DISCARD) > 0 then
        if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local sg = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
        if #sg > 0 then
            Duel.SpecialSummon(sg, 0, tp, tp, false, false, POS_FACEUP)
        end
    end
end
--Fusion Summon
function s.matfilter(c)
    return c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsAbleToDeck()
end
function s.fusfilter(c, e, tp, m, f, chkf)
    return c:IsType(TYPE_FUSION) and c:IsSetCard(0x280) and (not f or f(c))
        and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_FUSION, tp, false, false) and c:CheckFusionMaterial(m, nil, chkf)
end
function s.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        local chkf = tp
        local mg = Duel.GetMatchingGroup(s.matfilter, tp, LOCATION_GRAVE | LOCATION_REMOVED, 0, nil)
        local res = Duel.IsExistingMatchingCard(s.fusfilter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, mg, nil, chkf)
        if not res then
            local ce = Duel.GetChainMaterial(tp)
            if ce ~= nil then
                local fgroup = ce:GetTarget()
                local mg2 = fgroup(ce, e, tp)
                local mf = ce:GetValue()
                res = Duel.IsExistingMatchingCard(s.fusfilter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, mg2, mf, chkf)
            end
        end
        return res
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_GRAVE | LOCATION_REMOVED)
end
function s.op2(e, tp, eg, ep, ev, re, r, rp)
    local chkf = tp
    local mg = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.matfilter), tp, LOCATION_GRAVE | LOCATION_REMOVED, 0, nil)
    local sg1 = Duel.GetMatchingGroup(s.fusfilter, tp, LOCATION_EXTRA, 0, nil, e, tp, mg, nil, chkf)
    local mg2 = nil
    local sg2 = nil
    local ce = Duel.GetChainMaterial(tp)    
    if ce ~= nil then
        local fgroup = ce:GetTarget()
        mg2 = fgroup(ce, e, tp)
        local mf = ce:GetValue()
        sg2 = Duel.GetMatchingGroup(s.fusfilter, tp, LOCATION_EXTRA, 0, nil, e, tp, mg2, mf, chkf)
    end    
    if #sg1 > 0 or (sg2 ~= nil and #sg2 > 0) then
        local sg = sg1:Clone()
        if sg2 then sg:Merge(sg2) end
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local tg = sg:Select(tp, 1, 1, nil)
        local tc = tg:GetFirst()        
        if sg1:IsContains(tc) and (sg2 == nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp, ce:GetDescription())) then
            local mat1 = Duel.SelectFusionMaterial(tp, tc, mg, nil, chkf)
            tc:SetMaterial(mat1)
            Duel.SendtoDeck(mat1, nil, SEQ_DECKSHUFFLE, REASON_EFFECT | REASON_MATERIAL | REASON_FUSION)
            Duel.BreakEffect()
            Duel.SpecialSummon(tc, SUMMON_TYPE_FUSION, tp, tp, false, false, POS_FACEUP)
        else
            local mat2 = Duel.SelectFusionMaterial(tp, tc, mg2, nil, chkf)
            local fop = ce:GetOperation()
            fop(ce, e, tp, tc, mat2)
        end
        tc:CompleteProcedure()
    end
end
--Normal Summon
function s.sumfilter(c)
    return c:IsSetCard(0x280) and c:IsSummonable(true, nil)
end
function s.tg3(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.sumfilter, tp, LOCATION_HAND | LOCATION_MZONE, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_SUMMON, nil, 1, 0, 0)
end
function s.op3(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SUMMON)
    local g = Duel.SelectMatchingCard(tp, s.sumfilter, tp, LOCATION_HAND | LOCATION_MZONE, 0, 1, 1, nil)
    local tc = g:GetFirst()
    if tc then
        Duel.Summon(tp, tc, true, nil)
    end
end