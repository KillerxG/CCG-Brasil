--Cheat Code Neko
--Scripted by Imp
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e0:SetCountLimit(1,id)
	e0:SetCost(s.spcost)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_REMOVED)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
--Special Summon
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	Duel.Release(c,REASON_COST)
end
function s.spfilter(c,e,tp,sync)
	return (c:IsSetCard(0x352) or (sync and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_CYBERSE) and c:IsMonster())) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local sync=Duel.IsExistingMatchingCard(s.exmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED+LOCATION_HAND,0,1,e:GetHandler(),e,tp,sync)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED+LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	local sync=Duel.IsExistingMatchingCard(s.exmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED+LOCATION_HAND,0,1,1,e:GetHandler(),e,tp,sync):GetFirst()
	if tc then
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
--Special Summon
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonType,1,nil,SUMMON_TYPE_SPECIAL)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local zones=eg:Filter(Card.IsSummonType,nil,SUMMON_TYPE_SPECIAL):GetLinkedZone(tp)&0x1f
	if chk==0 then return zones~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zones) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zones=eg:Filter(Card.IsSummonType,nil,SUMMON_TYPE_SPECIAL):GetLinkedZone(tp)&0x1f
	if c:IsRelateToEffect(e) and zones~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zones) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zones)
	end
end