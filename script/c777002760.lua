--Genshin Impact - Memories of the Journey
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Special Summon, then attach
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
--(1)Special Summon, then attach
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x291) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.costfilter(c)
	return c:IsDiscardable() and c:IsSetCard(0x291)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.attafilter(c)
	return c:IsSetCard(0x291) and c:IsType(TYPE_MONSTER)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)	
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local sc=g:GetFirst()
	if #g>0 and sc and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 and sc:IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(s.attafilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local pg=Duel.SelectMatchingCard(tp,s.attafilter,tp,LOCATION_DECK,0,1,1,nil)
		if #pg>0 then
			Duel.BreakEffect()
			Duel.Overlay(sc,pg)
			--(1.1)Lock Summon
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetTarget(s.splimit)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
			aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,2),nil)
			--(1.2)Lizard check
			aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)
		end
	end
end
--(1.1)Lock Summon
function s.splimit(e,c)
	return not ((c:IsOriginalSetCard(0x291) and c:IsType(TYPE_MONSTER)) or c:IsOriginalRace(RACE_WARRIOR)) and c:IsLocation(LOCATION_EXTRA)
end
--(1.2)Lizard check
function s.lizfilter(e,c)
	return not ((c:IsOriginalSetCard(0x291) and c:IsType(TYPE_MONSTER)) or c:IsOriginalRace(RACE_WARRIOR))
end