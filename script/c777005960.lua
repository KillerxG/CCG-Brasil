--West Royal Dragon Alluring Emissary
--Scripted by KillerxG
local s, id = GetID()
function s.initial_effect(c)
    --(1)Ritual Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.ritcost)
    e1:SetTarget(s.rittg)
    e1:SetOperation(s.ritop)
    c:RegisterEffect(e1)
	--(2)Self Special Summon, then can Fusion Summon
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.cost)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end
--(1)Ritual Summon
function s.ritcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return not c:IsPublic() end
    Duel.ConfirmCards(1-tp, c)
end
function s.ritfilter(rc, e, tp, mg, c)
    if not (rc:IsRace(RACE_DRAGON | RACE_FIEND) and rc:IsType(TYPE_RITUAL) and rc:IsCanBeSpecialSummoned(e, SUMMON_TYPE_RITUAL, tp, false, true)) then return false end
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local m = mg:Clone()
    m:RemoveCard(c) 
    m:RemoveCard(rc)
    local res = false    
    if ft > 0 then
        if c:GetLevel() >= rc:GetLevel() then
            res = true
        else
            res = m:CheckWithSumGreater(Card.GetLevel, rc:GetLevel() - c:GetLevel())
        end
    else
        local fg = m:Filter(Card.IsLocation, nil, LOCATION_MZONE)
        for fc in aux.Next(fg) do
            local m2 = m:Clone()
            m2:RemoveCard(fc)
            local diff = rc:GetLevel() - c:GetLevel() - fc:GetLevel()
            if diff <= 0 then 
                res = true
            else
                res = m2:CheckWithSumGreater(Card.GetLevel, diff)
            end
            m2:DeleteGroup()
            if res then break end
        end
    end
    m:DeleteGroup()
    return res
end
function s.rittg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        local mg = Duel.GetRitualMaterial(tp)
        if not mg:IsContains(c) then return false end
        return Duel.IsExistingMatchingCard(s.ritfilter, tp, LOCATION_HAND, 0, 1, nil, e, tp, mg, c)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND)
end
function s.mvfilter(c)
    return c:GetSequence() < 5 and Duel.GetLocationCount(c:GetControler(), LOCATION_MZONE) > 0
end
function s.ritop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end    
    local mg = Duel.GetRitualMaterial(tp)
    if not mg:IsContains(c) then return end    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local tg = Duel.SelectMatchingCard(tp, s.ritfilter, tp, LOCATION_HAND, 0, 1, 1, nil, e, tp, mg, c)
    local rc = tg:GetFirst()    
    if rc then
        local mat = Group.FromCards(c)
        mg:RemoveCard(c)
        mg:RemoveCard(rc) 
        local diff = rc:GetLevel() - c:GetLevel()
        local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)        
        local mat2 = Group.CreateGroup()
        if diff > 0 then
            if ft > 0 then
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
                mat2 = mg:SelectWithSumGreater(tp, Card.GetLevel, diff)
            else
                local fg = mg:Filter(Card.IsLocation, nil, LOCATION_MZONE)
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
                local field_tc = fg:FilterSelect(tp, function(fc)
                    local m2 = mg:Clone()
                    m2:RemoveCard(fc)
                    local d2 = diff - fc:GetLevel()
                    local result = d2 <= 0 or m2:CheckWithSumGreater(Card.GetLevel, d2)
                    m2:DeleteGroup()
                    return result
                end, 1, 1, nil):GetFirst()                
                mat2:AddCard(field_tc)
                mg:RemoveCard(field_tc)
                local diff2 = diff - field_tc:GetLevel()
                if diff2 > 0 then
                    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
                    local mat3 = mg:SelectWithSumGreater(tp, Card.GetLevel, diff2)
                    mat2:Merge(mat3)
                end
            end
        else
            if ft == 0 then
                local fg = mg:Filter(Card.IsLocation, nil, LOCATION_MZONE)
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
                local field_tc = fg:Select(tp, 1, 1, nil):GetFirst()
                mat2:AddCard(field_tc)
            end
        end
        mat:Merge(mat2)
        rc:SetMaterial(mat)
        Duel.ReleaseRitualMaterial(mat)
        Duel.BreakEffect()
        Duel.SpecialSummon(rc, SUMMON_TYPE_RITUAL, tp, tp, false, true, POS_FACEUP)
        rc:CompleteProcedure()
        local mv_g = Duel.GetMatchingGroup(s.mvfilter, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
        if #mv_g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 1))
            local mv_tc = mv_g:Select(tp, 1, 1, nil):GetFirst()
            if mv_tc then
                local p = mv_tc:GetControler()
                local invalid_mask = 0x60
                for i = 0, 4 do
                    if not Duel.CheckLocation(p, LOCATION_MZONE, i) then
                        invalid_mask = invalid_mask | (1 << i)
                    end
                end
                if p ~= tp then
                    invalid_mask = invalid_mask << 16
                end
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOZONE)
                local zone = Duel.SelectDisableField(tp, 1, p==tp and LOCATION_MZONE or 0, p==tp and 0 or LOCATION_MZONE, invalid_mask)
                if zone and zone > 0 then
                    local seq = 0
                    local z = zone
                    if p ~= tp then z = z >> 16 end
                    while z > 1 do
                        z = z >> 1
                        seq = seq + 1
                    end
                    Duel.MoveSequence(mv_tc, seq)
                end
            end
        end
    end
end
--(2)Self Special Summon, then can Fusion Summon
function s.cfilter(c, tp)
    if not (c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and not c:IsPublic()) then return false end
    local ct = math.floor(c:GetLevel() / 4)
    return ct > 0 and Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) >= ct
end
function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_HAND, 0, 1, nil, tp) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local g = Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_HAND, 0, 1, 1, nil, tp)
    Duel.ConfirmCards(1-tp, g)
    Duel.ShuffleHand(tp)
    local tc = g:GetFirst()
    local val = tc:GetCode() | (tc:GetLevel() << 32)
    e:SetLabel(val)
end
function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then 
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
            and Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_HAND, 0, 1, nil, tp)
    end
    local val = e:GetLabel()
    local ct = math.floor((val >> 32) / 4)
    Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 0, tp, ct)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
    Duel.SetPossibleOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end
function s.fusion_filter(c, e, tp, m, f, chkf)
    return c:IsType(TYPE_FUSION) and c:IsSetCard(0x288) and (not f or f(c))
        and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_FUSION, tp, false, false) and c:CheckFusionMaterial(m, nil, chkf)
end
function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local val = e:GetLabel()
    local code = val & 0xffffffff 
    local lv = val >> 32          
    local ct = math.floor(lv / 4) 
    if ct == 0 then return end
    if Duel.DiscardDeck(tp, ct, REASON_EFFECT) > 0 then
        if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CHANGE_CODE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetValue(code)
            e1:SetReset(RESET_EVENT | RESETS_STANDARD)
            c:RegisterEffect(e1)
            local chkf = tp
            local f_mg = Duel.GetFusionMaterial(tp) 
            local f_res = Duel.IsExistingMatchingCard(s.fusion_filter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, f_mg, nil, chkf)
            if f_res and Duel.SelectYesNo(tp, aux.Stringid(id,3)) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
                local f_sg = Duel.SelectMatchingCard(tp, s.fusion_filter, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp, f_mg, nil, chkf)
                local f_tc = f_sg:GetFirst()
                if f_tc then
                    local f_mat = Duel.SelectFusionMaterial(tp, f_tc, f_mg, nil, chkf)
                    f_tc:SetMaterial(f_mat)
                    Duel.SendtoGrave(f_mat, REASON_EFFECT | REASON_MATERIAL | REASON_FUSION)
                    Duel.BreakEffect()
                    Duel.SpecialSummon(f_tc, SUMMON_TYPE_FUSION, tp, tp, false, false, POS_FACEUP)
                    f_tc:CompleteProcedure()
                end
            end
        end
    end
end