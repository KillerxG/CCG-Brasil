--Forest Legion Blader
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,Card.IsNonEffectMonster,2)
	--(1)Destroyed check
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(s.regcon)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	--(2)Special Summon itself
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--(3)ATK Up
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x255))
	e3:SetValue(600)
	c:RegisterEffect(e3)
	--(4)Can attack all monsters
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_ATTACK_ALL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
--(1)Destroyed check
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and (e:GetHandler():IsReason(REASON_BATTLE) or e:GetHandler():IsReason(REASON_EFFECT))
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_STANDBY,0,1)
end
--(2)Special Summon itself
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,1,tp,false,false) end
	e:GetHandler():ResetFlagEffect(id)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,1,tp,tp,false,false,POS_FACEUP)
	end
end
