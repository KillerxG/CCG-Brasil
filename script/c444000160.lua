-- Okami - Yomigami
-- Scripted by Leonardofake & Imp
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
    e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e0:SetType(EFFECT_TYPE_IGNITION)
    e0:SetRange(LOCATION_MZONE)
    e0:SetCountLimit(1,id)
    e0:SetTarget(s.sptg)
    e0:SetOperation(s.spop)
    c:RegisterEffect(e0)
	--Search
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1) 
end
--Special Summon
function s.cfilter(c)
	return c:IsFaceup() and (c:IsCode(444000000) or c:IsCode(444000050))
end
function s.spfilter(c,e,tp,sync)
	return ((c:IsCode(444000000) or c:IsCode(444000050)) or (sync and c:IsSetCard(0x444))) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
	  and not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,c:GetCode()),tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local sync=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,e:GetHandler(),e,tp,sync)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	local sync=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,e:GetHandler(),e,tp,sync):GetFirst()
	if tc then
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
--Search
function s.thfilter(c)
	return c:IsSetCard(0x444) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g) 
	end
end