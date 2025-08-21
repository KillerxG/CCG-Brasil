--West Royal Dragon - Regent Irya
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x288),1,1,Synchro.NonTunerEx(Card.IsRace,RACE_DRAGON),1,99)
	--(1)Change Name
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(777003710)
	c:RegisterEffect(e1)
	--(2)Negate column
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_ONFIELD)
	e2:SetTarget(s.coltg)
	c:RegisterEffect(e2)
	--(3)Banish all monsters on the field, then re Special Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.rmsptg)
	e3:SetOperation(s.rmspop)
	c:RegisterEffect(e3)
end
s.listed_names={777003710}
--(2)Disable
function s.coltg(e,c)
	return e:GetHandler():GetColumnGroup():IsContains(c) and c:IsFaceup()
end
--(3)Banish all monsters on the field, then re Special Summon
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