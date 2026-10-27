--Hallowferno World
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--(1)When this card is activated, send your non-FIRE/non-Illusion monsters to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--(2)Excavate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.excavtg)
	e2:SetOperation(s.excavop)
	c:RegisterEffect(e2)
	--(3)FIRE Illusion monsters you control are unaffected by your opponent's activated effects during your Main Phase 1
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(function(e) return Duel.IsTurnPlayer(e:GetHandlerPlayer()) and Duel.IsPhase(PHASE_MAIN1) end)
	e3:SetTarget(function(e,c) return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_ILLUSION) end)
	e3:SetValue(s.immval)
	c:RegisterEffect(e3)
	--(4)Special Summon restriction
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(1,0)
	e4:SetTarget(s.splimit)
	c:RegisterEffect(e4)
end
--(1)When this card is activated, send your non-FIRE/non-Illusion monsters to the GY
function s.tgfilter(c)
	return not c:IsAttribute(ATTRIBUTE_FIRE)
		and not c:IsRace(RACE_ILLUSION)
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,tp,LOCATION_MZONE)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,0,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
--(2)Excavate
function s.excavtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.excavspfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_ILLUSION) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.excavop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	Duel.ConfirmDecktop(tp,5)
	local excavg=Duel.GetDecktopGroup(tp,5)
	local remaining_count=#excavg
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local g=excavg:Match(s.excavspfilter,nil,e,tp)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=g:Select(tp,1,1,nil)
			if #sg>0 then
				Duel.DisableShuffleCheck()
				remaining_count=remaining_count-1
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
	if remaining_count>0 then
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>remaining_count then
			Duel.MoveToDeckBottom(remaining_count,tp)
		end
		Duel.SortDeckbottom(tp,tp,remaining_count)
	end
end
--(3)FIRE Illusion monsters you control are unaffected by your opponent's activated effects during your Main Phase 1
function s.immval(e,te)
	return te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and te:IsActivated()
end
--(4)Special Summon restriction
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsAttribute(ATTRIBUTE_FIRE) or c:IsRace(RACE_ILLUSION))
end