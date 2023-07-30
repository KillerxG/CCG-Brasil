--Warbeast Archer
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --(1)SS Token then this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)
end
--(1)SS Token then this card
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+5,0,TYPES_TOKEN+TYPE_TUNER,1200,600,2,RACE_BEASTWARRIOR,ATTRIBUTE_LIGHT) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and Duel.IsPlayerCanSpecialSummonMonster(tp,id+5,0,TYPES_TOKEN+TYPE_TUNER,1200,600,2,RACE_BEASTWARRIOR,ATTRIBUTE_LIGHT) then
		local token=Duel.CreateToken(tp,id+5)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
			Duel.SpecialSummonComplete()
			--(1.1)Lock Summon
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetTarget(s.splimit)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
			aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,1),nil)
			--(1.2)Lizard check
			aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)
		end
	end
end
--(1.1)Lock Summon
function s.splimit(e,c)
	return not (c:IsRace(RACE_BEASTWARRIOR) or c:IsRace(RACE_BEAST) or c:IsType(TYPE_SYNCHRO)) and c:IsLocation(LOCATION_EXTRA)
end
--(1.2)Lizard check
function s.lizfilter(e,c)
	return not (c:IsOriginalRace(RACE_BEASTWARRIOR) or c:IsOriginalRace(RACE_BEAST) or c:IsType(TYPE_SYNCHRO))
end