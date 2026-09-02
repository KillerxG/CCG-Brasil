--
--Scripted by KillerxG
local s,id=GetID()
Duel.LoadScript("proc_divine_hierarchy_mod.lua")
function s.initial_effect(c)
	--Synchro Summon
	Synchro.AddProcedure(c,s.tunerfilter,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--Divine Hierarchy Rank 1
	DivineHierarchyMod.Register(c,1)
	--(1)Place Yokai Scales
	local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.pencon)
    e1:SetTarget(s.pentg)
    e1:SetOperation(s.penop)
    c:RegisterEffect(e1)
	--(2)ATK/DEF Up
	local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)    
    local e3=e2:Clone()
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e3)
	--(3)Revive
	local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetCountLimit(1, id)
    e4:SetCondition(s.spcon)
    e4:SetCost(s.spcost)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end
s.material={777006250}
--Synchro Summon
function s.tunerfilter(c,lc,stype,tp)
	return c:IsSummonCode(lc,stype,tp,777006250) or c:IsHasEffect(777006280)
end
--(1)Place Yokai Scales
function s.pencon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.penfilter(c)
    return c:IsRace(RACE_YOKAI) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end

function s.pentg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        local ft = 0
        if Duel.CheckLocation(tp, LOCATION_PZONE, 0) then ft = ft + 1 end
        if Duel.CheckLocation(tp, LOCATION_PZONE, 1) then ft = ft + 1 end        
        return ft > 0 and Duel.IsExistingMatchingCard(s.penfilter, tp, LOCATION_DECK, 0, 1, nil)
    end
end
function s.penop(e, tp, eg, ep, ev, re, r, rp)
    local ft = 0
    if Duel.CheckLocation(tp, LOCATION_PZONE, 0) then ft = ft + 1 end
    if Duel.CheckLocation(tp, LOCATION_PZONE, 1) then ft = ft + 1 end
    if ft == 0 then return end
    local g = Duel.GetMatchingGroup(s.penfilter, tp, LOCATION_DECK, 0, nil)
    if #g == 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOFIELD)
    local sg = aux.SelectUnselectGroup(g, e, tp, 1, ft, aux.dncheck, 1, tp, HINTMSG_TOFIELD)
    if sg and #sg > 0 then
        for tc in aux.Next(sg) do
            Duel.MoveToField(tc, tp, tp, LOCATION_PZONE, POS_FACEUP, true)
        end
    end
end
--(2)ATK/DEF Up
function s.stfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.atkval(e, c)
    return Duel.GetMatchingGroupCount(s.stfilter, c:GetControler(), LOCATION_GRAVE, 0, nil) * 100
end
--(3)Revive
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsReason(REASON_BATTLE + REASON_EFFECT) and c:IsReason(REASON_DESTROY)
end
function s.cfilter(c)
    return c:IsType(TYPE_SPELL + TYPE_TRAP) and not c:IsType(TYPE_FIELD) and c:IsAbleToGraveAsCost()
end
function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)    
    local g = Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil)
    Duel.SendtoGrave(g, REASON_COST)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP_DEFENSE) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_DEFENSE) > 0 then
        -- Aplica o efeito nativo de "Banish it when it leaves the field"
        local e1 = Effect.CreateEffect(c)
        e1:SetDescription(3300) -- String global da engine para esse texto de banimento
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetValue(LOCATION_REMOVED)
        e1:SetReset(RESET_EVENT + RESETS_REDIRECT)
        c:RegisterEffect(e1, true)
    end
end