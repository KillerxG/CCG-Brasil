--Cheat Code Kondoru
--Scripted by Imp
local s,id=GetID()
function s.initial_effect(c)
    --Send to Hand
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_TOHAND)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e0:SetCountLimit(1,id)
	e0:SetCost(s.thcost)
	e0:SetTarget(s.thtg)
	e0:SetOperation(s.thop)
	c:RegisterEffect(e0)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
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
--Send to Hand
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	Duel.Release(c,REASON_COST)
end
function s.exmfilter(c)
	return c:GetSequence()>=5
end
function s.thfilter(c,sync)
	return  (c:IsSetCard(0x352) or (sync and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_CYBERSE) and c:IsMonster()) and c:IsFaceup()) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local sync=Duel.IsExistingMatchingCard(s.exmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,e:GetHandler(),sync) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local sync=Duel.IsExistingMatchingCard(s.exmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,e:GetHandler(),sync)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
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