--Iori, Warrior of the Starry Sky
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--(1)Reduce Levels by 3
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfReveal)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
	--(2)Special Summon itself
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_DECK+LOCATION_HAND) end)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--(3)Multiply Level by 3
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+2)
	e3:SetTarget(s.tritg)
	e3:SetOperation(s.triop)
	c:RegisterEffect(e3)
end
--(1)Reduce Levels by 3
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsLevelAbove,4),tp,LOCATION_MZONE,0,1,nil) end
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsLevelAbove,4),tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-3)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end
--(2)Special Summon itself
function s.rmfilter(c)
	return c:IsLevelAbove(6) and c:IsAbleToRemove()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK,0,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #g>0 then
				--Duel.HintSelection(g)
				Duel.BreakEffect()
				Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end
--(3)Multiply Level by 3
function s.lvfilter(c,e)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsCanBeEffectTarget(e)
end
function s.lvcheck(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetLevel)==1
end
function s.tritg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_MZONE,0,nil,e)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.lvcheck,0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.lvcheck,1,tp,HINTMSG_FACEUP)
	Duel.SetTargetCard(sg)
end
function s.triop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tg=Duel.GetTargetCards(e):Filter(Card.IsFaceup,nil)
	for tc in aux.Next(tg) do
		--Triple their Levels
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL_FINAL)
		e1:SetValue(tc:GetLevel()*3)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end