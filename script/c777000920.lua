--Dragonborn Brutal Dragon
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE),aux.FilterBoolFunctionEx(Card.IsRace,RACE_DRAGON))
	--(1)Face-down
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_REMOVE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	--(2)ATK Change
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_COST)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	--(3)Can attack all monsters
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_ATTACK_ALL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--(4)Disable
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_ONFIELD)
	e4:SetCondition(s.condition)
	e4:SetTarget(s.disable)
	e4:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e4)
end
--(1)Face-down
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local g2=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	if #g2>0 then
		Duel.ChangePosition(g2,POS_FACEDOWN_DEFENSE)
	end	
end
--(2)ATK Change
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetMatchingGroup(Card.HasNonZeroAttack,tp,0,LOCATION_MZONE,c)
	if #tg>0 and Duel.SelectEffectYesNo(tp,c) then
		Duel.Hint(HINT_CARD,0,id)
		local atk=#tg*200
		for tc in aux.Next(tg) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			tc:RegisterEffect(e1)
		end
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		c:RegisterEffect(e1)
	end
	Duel.Readjust()
end
--(4)Disable
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function s.disable(e,c)
	return c:IsFaceup() and not c:IsType(TYPE_NORMAL)
end