--Warbeast Rookie
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --(1)If this card on the field would be used as Synchro Material, 1 Beast-Warrior in your hand can be used as 1 of the other materials
	Synchro.AddHandMaterialEffect(c,id,function(c) return c:IsRace(RACE_BEASTWARRIOR) end)	
	--(2)Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,id+1)
	e1:SetCondition(s.tkcon)
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCondition(s.tk2con)
	c:RegisterEffect(e3)
end
--(2)Special Summon
function s.cfilter1(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(777001840)
end
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetPreviousLocation()==LOCATION_HAND and (r&REASON_DISCARD)~=0
end
function s.tk2con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and r==REASON_SYNCHRO and c:GetReasonCard():IsRace(RACE_BEASTWARRIOR)
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,777001885,0x308,TYPES_TOKEN|TYPE_TUNER,1000,1000,2,RACE_BEAST,ATTRIBUTE_WATER)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if s.tktg(e,tp,eg,ep,ev,re,r,rp,0) then
		local c=e:GetHandler()
		local token=Duel.CreateToken(tp,777001885)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	if Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.SpecialSummonComplete()
end