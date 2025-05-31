--West Royal Dragon - Burrow
--Scripted by KillerxG
local s,id=GetID()
local RACES=RACE_FIEND+RACE_DRAGON
function s.initial_effect(c)
	--(1)Ritual Summon
	local e1=Ritual.CreateProc(c,RITPROC_GREATER,aux.FilterBoolFunction(Card.IsRace,RACES),nil,aux.Stringid(id,0),nil,nil,nil,nil,nil,function(e,tp,g,sc)return g:IsContains(e:GetHandler()) or  g:IsContains(e:GetHandler())  end)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	c:RegisterEffect(e1)
	--(2)Double this card's DEF
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e2:SetCondition(s.defcon)
	e2:SetValue(c:GetDefense()*2)
	c:RegisterEffect(e2)
	--(3)Defend your attacked monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCategory(CATEGORY_DEFCHANGE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(TIMING_DAMAGE_STEP)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.condition)
	e3:SetCost(Cost.SelfBanish)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
--(2)Double this card's DEF
function s.spfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
function s.defcon(e)
	return e:GetHandler():IsDefensePos() and Duel.IsExistingMatchingCard(s.spfilter,0,LOCATION_MZONE,0,1,e:GetHandler())
end
--(3)Defend your attacked monster
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local phase=Duel.GetCurrentPhase()
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	local d=Duel.GetAttackTarget()
	return d and d:IsControler(tp) and d:IsAttackPos() and d:IsSetCard(0x288)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
	if not d:IsRelateToBattle() then return end
	Duel.ChangePosition(d,POS_FACEUP_DEFENSE)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	e1:SetValue(2000)
	d:RegisterEffect(e1)
end