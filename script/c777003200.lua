--Elementale Stage
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--(1)Cannot Attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.atktarget)
	c:RegisterEffect(e2)
	--(2)Prevent effect target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.immtg)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--(3)If Special: You can Rearrange Monsters
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(function(e,tp,eg) return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp) end)
	e3:SetTarget(s.reatg)
	e3:SetOperation(s.reaop)
	c:RegisterEffect(e3)
	--(4)When Monster effect activate: You can Rearrange Monsters
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(s.discon)
	e4:SetTarget(s.reatg)
	e4:SetOperation(s.reaop)
	c:RegisterEffect(e4)
	--(5)Pos Change
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_SET_POSITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)	
	e5:SetTarget(s.target)
	e5:SetValue(POS_FACEUP_DEFENSE)
	c:RegisterEffect(e5)
end
--(1)Cannot Attack
function s.atktarget(e,c)
	return (c:GetLevel()>=4 and not c:IsCode(777003130)) or c:GetRank()>=1 or c:GetLink()>=1 
end
--(2)Prevent effect target
function s.immtg(e,c)
	return (c:IsSetCard(0x310) and c:IsFaceup()) or c:IsFacedown()
end
--(3)Rearrange Monsters
function s.reatg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:HasFlagEffect(id) and Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_MMZONE,0,2,nil) end
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1)
end
--(3)If Special: You can Rearrange Monsters
function s.reaop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MMZONE,0,nil)
	Duel.ShuffleSetCard(g)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and re:IsMonsterEffect()
end
--(5)Pos Change
function s.target(e,c)
	return c:IsLevel(3) and c:IsFaceup() and c:IsSetCard(0x310)
end