--Genshin Impact - Strategy
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.nscon)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
--(1)Search
function s.nscon(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,0x291),tp,LOCATION_MZONE,0,nil)
	return ct==Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1))
		and Duel.RemoveOverlayCard(tp,1,0,1,2,REASON_COST) then
		Duel.SetTargetParam(#Duel.GetOperatedGroup())
	end
end
function s.thfilter(c)
	return c:IsSetCard(0x291) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	local ct=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if ct and ct>0 then
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_GRAVE)
	end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x291) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 or Duel.SendtoHand(g,nil,REASON_EFFECT)==0 
		or not g:GetFirst():IsLocation(LOCATION_HAND) then return end
	Duel.ConfirmCards(1-tp,g)
	local ct=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if not ct or ct<=0 or ft<ct or (ct>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then return end
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	if #sg<ct or not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local ssg=sg:Select(tp,ct,ct,nil)
	if #ssg==ct then
		Duel.BreakEffect()
		Duel.SpecialSummon(ssg,1,tp,tp,false,false,POS_FACEUP)
		--(1.1)Lock Summon
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetTarget(s.splimit)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
			aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,3),nil)
			--(1.2)Lizard check
			aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)		
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