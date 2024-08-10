--Draconic Witch - Zero
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --(1)Type Dragon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_RACE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(RACE_DRAGON)
	c:RegisterEffect(e1)	
	--(2)Search "Draconic"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	e2:SetLabel(0)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetLabel(0)
	c:RegisterEffect(e3)
	--(3)Banish Dragon or "Draconic" cards from the GY and Special Summon 1 Dragon Monster 
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+1)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
--(2)Search "Draconic"
function s.spfilter1(c,e,tp,check)
	return c:IsSetCard(0x300) and not c:IsCode(id) and c:IsAbleToHand()
		and (check==0 or Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_EXTRA,0,1,c,e,tp))
end
function s.banfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and (c:IsAbleToRemoveAsCost() or c:IsAbleToRemove()) 
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local b=Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp,1)
	if chk==0 then return b end
	if b and Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_EXTRA,0,1,nil) ---- banish
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local g=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_EXTRA,0,1,1,nil) ---- banish
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp,0) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,e:GetLabel()+1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		Duel.BreakEffect() 
		if e:GetLabel()~=1 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g2=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
			if #g2>0 then
				Duel.BreakEffect() 
				Duel.Remove(g2,POS_FACEUP,REASON_EFFECT)
			end
		end
end
--(3)Banish Dragon or "Draconic" cards from the GY and Special Summon 1 Dragon Monster 
function s.costfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsLocation(LOCATION_EXTRA) and c:IsAbleToRemoveAsCost(POS_FACEUP)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_EXTRA,0,1,nil) end
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.sinfilter(c)
	return c:IsMonster() and (c:IsSetCard(0x300) or c:IsRace(RACE_DRAGON)) and c:IsAbleToRemove()
end
function s.spfilter(c,e,tp,lv)
	return ((c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_FIRE) and not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,777000680),tp,LOCATION_ONFIELD,0,1,nil)) 
		or (Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,777000680),tp,LOCATION_ONFIELD,0,1,nil) and c:IsRace(RACE_DRAGON))) and c:IsLevelAbove(5) and c:IsLevelBelow(lv) and not c:IsPublic()
		and ((c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,777000680),tp,LOCATION_ONFIELD,0,1,nil)) 
			or (Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,777000680),tp,LOCATION_ONFIELD,0,1,nil) and c:IsCanBeSpecialSummoned(e,0,tp,true,false))) 
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=Duel.GetMatchingGroupCount(s.sinfilter,tp,LOCATION_GRAVE,0,nil)
		return ct>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ct*4+3) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sg=Duel.GetMatchingGroup(s.sinfilter,tp,LOCATION_GRAVE,0,nil)
	if #sg<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,#sg*4+3):GetFirst()
	if not tc then return end
	Duel.ConfirmCards(1-tp,tc)
	local ct=tc:GetLevel()//4
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local ssg=sg:Select(tp,ct,ct,nil)
	if #ssg==0 then return end
	if Duel.Remove(ssg,POS_FACEUP,REASON_EFFECT)>0 and ssg:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) then
		Duel.BreakEffect()
		if Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)==0 then return end
		if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,777000680),tp,LOCATION_ONFIELD,0,1,nil) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2,true)
		end
		tc:CompleteProcedure()
	end
end
