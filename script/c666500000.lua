--Typenull_Brawler.lua
--Scripted by Imp
local s,id=GetID()
function s.initial_effect(c)
   	--Special Summon
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_HAND)
	e0:SetCountLimit(1,id)
	e0:SetCondition(s.spcon)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)
	--Link Summon ("Typenull_Brawler.lua")
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id+1)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetTarget(s.lktg)
	e1:SetOperation(s.lkop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_QUICK_O)
	e2:SetCondition(function(e) return e:GetHandler():IsSetCard(0x660) and Duel.IsMainPhase() end)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCondition(s.matcon)
	e3:SetOperation(s.matop2)
	c:RegisterEffect(e3)
	--Send to Deck/Special Summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id+2)
	e4:SetCondition(function(e,tp,eg,ep,ev,re) return e:GetHandler():IsReason(REASON_EFFECT) and re and re:IsMonsterEffect() and re:GetHandler():IsSetCard(0x660) end)
	e4:SetTarget(s.tdsptg)
	e4:SetOperation(s.tdspop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e5)
end
--Special Summon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	return #g==0 or g:FilterCount(Card.IsSetCard,nil,0x660)==#g
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
--Link Summon ("Typenull_Brawler.lua")
function s.lkfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsLinkSummonable()
end
function s.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.lkfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.lkfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	if sc then
		Duel.LinkSummon(tp,sc)
	end
end
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK
end
function s.matop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	if not rc:IsSetCard(0x660) then return end
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,id+1)
	e6:SetCondition(function() return Duel.IsMainPhase() end)
	e6:SetTarget(s.lktg)
	e6:SetOperation(s.lkop)
	e6:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e6)
end
--Send to Deck/Special Summon
function s.tdspfilter(c,e,tp,ft)
	return c:IsSetCard(0x660) and c:IsMonster() and c:HasLevel() and c:IsFaceup()
		and (c:IsAbleToDeck() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.tdsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tdspfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
	end
function s.tdspop(e,tp,eg,ep,ev,re,r,rp)
 	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdspfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil,e,tp,ft)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
		local sc=g:Select(tp,1,1,nil):GetFirst()
		local b1=sc:IsAbleToDeck()
		local b2=ft>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,4)},
			{b2,aux.Stringid(id,5)})
		if not op then return end
		Duel.BreakEffect()
		if op==1 then
			Duel.HintSelection(sc,true)
			Duel.SendtoDeck(sc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		else
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end