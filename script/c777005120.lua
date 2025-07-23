--Grimoire of Lost Creatures
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--(1)Special Summon Lucifer
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--(2)Special Summon 1 Monster from either GY to either field in Defense Position
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(s.gpxyzfilter,tp,LOCATION_MZONE,0,1,nil) end)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={777005070,21251800}
--(1)Special Summon Lucifer
function s.luciferfilter(c,e,tp)
	return c:IsCode(21251800) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.luciferfilter),tp,LOCATION_HAND|LOCATION_DECK,0,nil,e,tp)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
--(2)Special Summon 1 Monster from either GY to either field in Defense Position
function s.gpxyzfilter(c)
	return c:IsCode(777005070,21251800) and c:IsFaceup()
end
function s.spfilter(c,e,tp,ftpl,ftopp)
	return ((ftpl>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE))
		or (ftopp>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp))) and not c:IsLinkMonster()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ftpl=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ftopp=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp,ftpl,ftopp) end
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,ftpl,ftopp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp,ftpl,ftopp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
	if not (b1 or b2) then return end
	local op=nil
	if b1 and b2 then
		op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,2)},
			{b2,aux.Stringid(id,3)})
	else
		op=(b1 and 1) or (b2 and 2)
	end
	local target_player=op==1 and tp or 1-tp
	Duel.SpecialSummon(tc,0,tp,target_player,false,false,POS_FACEUP_DEFENSE)
end