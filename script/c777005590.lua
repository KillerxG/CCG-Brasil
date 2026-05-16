--Fuyumi, the Snow Sorceress
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--(1)Discard 2 or more Beast-Warrior monsters and Special Summon 1 Beast-Warrior Synchro Monster from your Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.extrasptg)
	e1:SetOperation(s.extraspop)
	c:RegisterEffect(e1)
	--(2)Return to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
--(1)Discard 2 or more Beast-Warrior monsters and Special Summon 1 Beast-Warrior Synchro Monster from your Extra Deck
function s.discardfilter(c)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsMonster() and c:HasLevel() and c:IsDiscardable(REASON_EFFECT)
end
function s.rescon(sg,e,tp,mg)
	return Duel.IsExistingMatchingCard(s.extraspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg:GetSum(Card.GetOriginalLevel)+e:GetHandler():GetOriginalLevel())
end
function s.extraspfilter(c,e,tp,lv)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsType(TYPE_SYNCHRO) and c:IsLevel(lv)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.extrasptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_SYNCHRO)
		if #pg>0 then return false end
		local c=e:GetHandler()
		local g=Duel.GetMatchingGroup(s.discardfilter,tp,LOCATION_HAND,0,c)
		return s.discardfilter(c) and #g>0 and aux.SelectUnselectGroup(g,e,tp,1,#g,s.rescon,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,2)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.extraspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.discardfilter,tp,LOCATION_HAND,0,c)
	if #g==0 then return end
	local rg=aux.SelectUnselectGroup(g,e,tp,1,#g,s.rescon,1,tp,HINTMSG_DISCARD)
	if #rg==0 then return end
	rg:AddCard(c)
	if Duel.SendtoGrave(rg,REASON_DISCARD|REASON_EFFECT)==0 then return end
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_SYNCHRO)
	if #pg>0 then return end
	local lv=rg:GetSum(Card.GetOriginalLevel)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.extraspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv):GetFirst()
	if sc and Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
		sc:CompleteProcedure()
	end
end
--(2)Return to hand
function s.descostfilter(c)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsDiscardable()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.descostfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.descostfilter,1,1,REASON_COST|REASON_DISCARD)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end