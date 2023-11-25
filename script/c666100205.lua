--Chosen By The Legend
--Scripted by Imp
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon Procedure
	Link.AddProcedure(c,s.matfilter,1,1)
	c:EnableReviveLimit()
	--Set
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e0:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCountLimit(1,id)
	e0:SetCondition(s.lkcon)
	e0:SetTarget(s.settg)
	e0:SetOperation(s.setop)
	c:RegisterEffect(e0)
	--Change Race
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.lkcon)
	e1:SetTarget(s.rctg)
	e1:SetOperation(s.rcop)
	c:RegisterEffect(e1)
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.lkcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
--Link Summon Procedure
function s.matfilter(c)
	return c:IsSummonType(SUMMON_TYPE_NORMAL) and (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_WARRIOR) or c:IsRace(RACE_SPELLCASTER))
end
function s.lkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
--Set
function s.tfilter1(c)
	return c:IsCode(11082056) and c:IsAbleToHand()
end
function s.setfilter(c)
	return (c:IsCode(57470761) or c:IsCode(44095762) or (83555666) or (57728570)) and c:IsTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SSet(tp,g) then
		local th=Duel.GetFirstMatchingCard(s.tfilter1,tp,LOCATION_DECK,0,nil)
		if th then
		Duel.SendtoHand(th,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,th)
	end
end
end
--Change Race
function s.tfilter2(c)
	return c:IsCode(46232525) and c:IsAbleToHand()
end
function s.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	local rc=c:AnnounceAnotherRace(tp)
	e:SetLabel(rc)
end
function s.rcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_CHANGE_RACE)
		e4:SetValue(e:GetLabel())
		e4:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e4)
		local th=Duel.GetFirstMatchingCard(s.tfilter2,tp,LOCATION_DECK,0,nil)
		if th then
		Duel.SendtoHand(th,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,th)
	end
end
end
--Special Summon
function s.tfilter3(c)
	return c:IsCode(1784686) and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x10a2) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local zone=e:GetHandler():GetLinkedZone(tp)
		return zone~=0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,zone)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetHandler():GetLinkedZone(tp)
	if zone==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,zone)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone) then
		local th=Duel.GetFirstMatchingCard(s.tfilter3,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
		if th then
		Duel.SendtoHand(th,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,th)
	end
end
end