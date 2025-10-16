--Sky Wind Offensive
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Set "Pendulum" or "Sky Wind" S/T
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	--(2)Back to hand, then Set another Scale
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
	--(3)ATK Down
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.con)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ALL))
	e3:SetValue(-1000)
	c:RegisterEffect(e3)
end
--(1)Set "Pendulum" or "Sky Wind" S/T
function s.setfilter(c)
	return (c:IsSetCard(0x306) or c:IsSetCard(0xf2)) and c:IsSpellTrap() and not c:IsCode(id) and c:IsSSetable()
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
	if #g==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local sg=g:Select(tp,1,1,nil)
	if #sg>0 then
		Duel.SSet(tp,sg)
	end
end
--(2)Back to hand, then Set another Scale
function s.filter(c)
	return c:IsFaceup() and c:IsOriginalType(TYPE_PENDULUM) and c:IsOriginalType(TYPE_MONSTER) and c:IsSetCard(0x306)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_PZONE,0,1,nil) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil)
	if chk==0 then return b1 end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_PZONE,0,1,nil) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil)
	local flag=0
	if b1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local thg=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_PZONE,0,1,1,nil)
		if Duel.SendtoHand(thg,tp,REASON_EFFECT)>0 and Duel.GetOperatedGroup():GetFirst():IsLocation(LOCATION_HAND) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local tpg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil)
			if #tpg>0 then 
				Duel.MoveToField(tpg:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true) 
			end
		end		
	end
end
--(3)ATK Down
function s.cfilter1(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(777001490)
end
function s.con(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end