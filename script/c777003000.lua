--Promised Land, Excess
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Special Summon 1 "Promised Land, Hiftle"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--(2)To your GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={777003040}
--(1)Special Summon 1 "Promised Land, Hiftle"
function s.cfilter(c,tp)
	return c:IsReleasableByEffect() and c:IsFaceup() and (c:IsType(TYPE_LINK) or c:IsType(TYPE_XYZ))
end
function s.spfilter(c,e,tp)
	return c:IsRitualMonster() and c:IsCode(777003040) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end
function s.rescon(sg,e,tp,mg)
	return Duel.GetMZoneCount(tp,sg)>0 --and sg:IsExists(s.cfilter,1,nil,sg,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	if chk==0 then return #g>=1 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
		and aux.SelectUnselectGroup(g,e,tp,1,1,s.rescon,0) end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	if #g<1 then return end
	local rg=aux.SelectUnselectGroup(g,e,tp,1,1,s.rescon,1,tp,HINTMSG_RELEASE)
	if Duel.Release(rg,REASON_EFFECT)==1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			if Duel.SpecialSummon(g,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP) then
			--Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_DISCARD)
			end
		end
	end
end
--(2)To your GY
function s.thfilter(c)
	return c:IsAbleToGrave()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,0,LOCATION_GRAVE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,0,LOCATION_GRAVE,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
		Duel.SendtoGrave(tc,tp,REASON_EFFECT)
	end
end