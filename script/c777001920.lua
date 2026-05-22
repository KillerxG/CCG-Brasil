--Warbeast Tracker - Kaelun
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --(1)Can be used as material from the hand for Beast Warrior monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_SYNCHRO_MAT_FROM_HAND)
	e1:SetRange(LOCATION_HAND)
	e1:SetValue(s.synval)
	c:RegisterEffect(e1)
	--(2)Set
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetCondition(s.set2con)
	c:RegisterEffect(e4)
end
--(1)Can be used as material from the hand for Beast Warrior monster
function s.synval(e,mc,sc)
	return sc:IsRace(RACE_BEASTWARRIOR)
end
--(2)Set
function s.cfilter1(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(777001840)
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetPreviousLocation()==LOCATION_HAND and (r&REASON_DISCARD)~=0
end
function s.set2con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and r==REASON_SYNCHRO and c:GetReasonCard():IsRace(RACE_BEASTWARRIOR)
end
function s.setfilter(c)
	return c:IsSetCard(0x308) and c:IsSpellTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		if Duel.SSet(tp,g) and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,0,1,nil) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 
			and Duel.IsPlayerCanSpecialSummonMonster(tp,777001865,0x308,TYPES_TOKEN,1800,0,4,RACE_ROCK,ATTRIBUTE_WATER)
				and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				local token=Duel.CreateToken(tp,777001865)
				Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end