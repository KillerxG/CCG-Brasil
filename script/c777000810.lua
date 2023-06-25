--Draconic Phoenix Knight
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --(1)Add this card from GY to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--(2)Type Dragon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ADD_RACE)
	e2:SetCondition(s.con)
	e2:SetValue(RACE_DRAGON)
	c:RegisterEffect(e2)
	--(3)Fusion Summon
	local params = {aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),aux.FALSE,s.fextra,Fusion.ShuffleMaterial,nil}
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e3:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e3)
	--(4)Treated as a Fusion monster
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_ADD_TYPE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(TYPE_FUSION)
	c:RegisterEffect(e4)
	--(5)Treated as a Synchro monster
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_ADD_TYPE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(TYPE_SYNCHRO)
	c:RegisterEffect(e5)
end
--(1)Add this card from GY to your hand
function s.costfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsLocation(LOCATION_EXTRA) and c:IsAbleToRemoveAsCost(POS_FACEUP)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_EXTRA,0,1,nil) end
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x300) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~0 and c:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,c)
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=g:Select(tp,1,1,nil):GetFirst()
			if sg and Duel.SpecialSummonStep(sg,0,tp,tp,false,false,POS_FACEUP) then
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_UPDATE_ATTACK)
					e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
					e1:SetValue(500)
					sg:RegisterEffect(e1)
					local e2=e1:Clone()
					e2:SetCode(EFFECT_UPDATE_DEFENSE)
					sg:RegisterEffect(e2)
					local e3=e1:Clone()
					e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
					e3:SetDescription(3001)
					e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
					e3:SetRange(LOCATION_MZONE)
					e3:SetValue(1)
					sg:RegisterEffect(e3)
				Duel.SpecialSummonComplete()
			end
		end
	end
end
--(2)Type Dragon
function s.con(e)
	return e:GetHandler():IsLocation(LOCATION_GRAVE+LOCATION_MZONE)
end
--(3)Fusion Summon
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsFaceup,Card.IsAbleToDeck),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
end