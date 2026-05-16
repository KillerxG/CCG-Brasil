--West Royal Dragon - Regent Irya
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--(1)Synchro Summon procedure
	local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE | EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(s.syncon)
    e1:SetTarget(s.syntg)
    e1:SetOperation(s.synop)
    e1:SetValue(SUMMON_TYPE_SYNCHRO)
    c:RegisterEffect(e1)
	--(2)Change Name
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetValue(777003710)
	c:RegisterEffect(e2)
	--(3)Negate column
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_ONFIELD)
	e3:SetTarget(s.coltg)
	c:RegisterEffect(e3)
	--(4)Banish all monsters on the field, then re Special Summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.rmsptg)
	e4:SetOperation(s.rmspop)
	c:RegisterEffect(e4)
end
s.listed_names={777003710}
--(1)Synchro Summon procedure
function s.check_level_match(lvl1, lvl2, target_lvl)
    local l1_a = lvl1 & 0xffff
    local l1_b = lvl1 >> 16
    local l2_a = lvl2 & 0xffff
    local l2_b = lvl2 >> 16
    
    return (l1_a + l2_a == target_lvl)
        or (l1_b > 0 and l1_b + l2_a == target_lvl)
        or (l2_b > 0 and l1_a + l2_b == target_lvl)
        or (l1_b > 0 and l2_b > 0 and l1_b + l2_b == target_lvl)
end
function s.nontuner_filter(c, sc)
    return c:IsFaceup() and c:IsCode(777003710) and c:IsCanBeSynchroMaterial(sc)
end
function s.tuner_filter(c, sc, nt)
    if c == nt or not (c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSynchroMaterial(sc)) then return false end    
    local nt_lvl = nt:GetSynchroLevel(sc)
    local target_lvl = sc:GetLevel()
    if c:IsType(TYPE_TUNER) then
        local t_lvl = c:GetSynchroLevel(sc)
        if s.check_level_match(t_lvl, nt_lvl, target_lvl) then return true end
    end
    if c:IsLevelAbove(6) then
        if s.check_level_match(1, nt_lvl, target_lvl) then return true end
    end    
    return false
end
function s.syncon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    local g = Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial, tp, LOCATION_MZONE, 0, nil, c)    
    return g:IsExists(function(nt, sc, grp)
        if not s.nontuner_filter(nt, sc) then return false end
        return grp:IsExists(function(t, sc2, nt_card)
            if not s.tuner_filter(t, sc2, nt_card) then return false end
            local mat = Group.FromCards(nt_card, t)
            return Duel.GetLocationCountFromEx(tp, tp, mat, sc2) > 0
        end, 1, nt, sc, nt)
    end, 1, nil, c, g)
end
function s.syntg(e, tp, eg, ep, ev, re, r, rp, chk, c)
    local g = Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial, tp, LOCATION_MZONE, 0, nil, c)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SMATERIAL)
    local nt_g = g:FilterSelect(tp, function(nt, sc, grp)
        if not s.nontuner_filter(nt, sc) then return false end
        return grp:IsExists(function(t, sc2, nt_card)
            if not s.tuner_filter(t, sc2, nt_card) then return false end
            local mat = Group.FromCards(nt_card, t)
            return Duel.GetLocationCountFromEx(tp, tp, mat, sc2) > 0
        end, 1, nt, sc, nt)
    end, 1, 1, nil, c, g)    
    local nt = nt_g:GetFirst()
    if nt then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SMATERIAL)
        local t_g = g:FilterSelect(tp, function(t, sc, nt_card)
            if not s.tuner_filter(t, sc, nt_card) then return false end
            local mat = Group.FromCards(nt_card, t)
            return Duel.GetLocationCountFromEx(tp, tp, mat, sc) > 0
        end, 1, 1, nt, c, nt)        
        nt_g:Merge(t_g)
        nt_g:KeepAlive()
        e:SetLabelObject(nt_g)
        return true
    end
    return false
end
function s.synop(e, tp, eg, ep, ev, re, r, rp, c)
    local mat = e:GetLabelObject()
    c:SetMaterial(mat)
    Duel.SendtoGrave(mat, REASON_MATERIAL | REASON_SYNCHRO)
    mat:DeleteGroup()
end
--(3)Disable
function s.coltg(e,c)
	return e:GetHandler():GetColumnGroup():IsContains(c) and c:IsFaceup()
end
--(4)Banish all monsters on the field, then re Special Summon
function s.rmsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_EITHER,LOCATION_REMOVED)
end
function s.spfilter(c,e,tp)
	local owner=c:GetOwner()
	return c:IsFaceup() and c:IsLocation(LOCATION_REMOVED) and not c:IsReason(REASON_REDIRECT)
		and (c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,owner)
		or c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,owner))
end
function s.rmspop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup()
		local sg=og:Filter(s.spfilter,nil,e,tp)
		if #sg==0 then return end
		local your_sg,opp_sg=sg:Split(Card.IsOwner,nil,tp)
		local your_ft,opp_ft=Duel.GetLocationCount(tp,LOCATION_MZONE),Duel.GetLocationCount(1-tp,LOCATION_MZONE)
		if #your_sg>your_ft then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			your_sg=your_sg:Select(tp,your_ft,your_ft,nil)
		end
		if #opp_sg>opp_ft then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			opp_sg=opp_sg:Select(tp,opp_ft,opp_ft,nil)
		end
		sg=your_sg+opp_sg
		for sc in sg:Iter() do
			local sump=0
			local owner=sc:GetOwner()
			if sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,owner) then sump=sump|POS_FACEUP end
			if sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,owner) then sump=sump|POS_FACEDOWN_DEFENSE end
			Duel.SpecialSummonStep(sc,0,tp,owner,false,false,sump)
		end
		local fdg=sg:Filter(Card.IsFacedown,nil)
		if #fdg>0 then
			Duel.ConfirmCards(1-tp,fdg)
		end
		Duel.BreakEffect()
		Duel.SpecialSummonComplete()
	end
end