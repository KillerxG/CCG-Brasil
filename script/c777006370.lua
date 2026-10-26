--Mirror Knight Calling
--Scripted by Codex
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--(1)Ritual Summon 1 DARK Ritual Monster
	local ritual_params={
		handler=c,
		lvtype=RITPROC_GREATER,
		filter=function(c)
			return c:IsAttribute(ATTRIBUTE_DARK)
		end
	}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(Cost.SelfReveal)
	e1:SetTarget(Ritual.Target(ritual_params))
	e1:SetOperation(Ritual.Operation(ritual_params))
	c:RegisterEffect(e1)
	--(2)Place this card in the Spell & Trap Zone and Special Summon Tokens
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.plcon)
	e2:SetTarget(s.pltg)
	e2:SetOperation(s.plop)
	c:RegisterEffect(e2)
	--(3)Cards in your Spell & Trap Zone cannot be destroyed by your opponent's card effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_SZONE,0)
	e3:SetCondition(s.auracon)
	e3:SetValue(s.indval)
	c:RegisterEffect(e3)
	--(4)The Tokens' ATK becomes equal to the ATK of the monster they battle
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SET_ATTACK_FINAL)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(s.atkcon)
	e4:SetTarget(s.atktg)
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)
	--(5)Special Summon 1 Monster Card from your Spell & Trap Zone
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.auracon)
	e5:SetCost(s.spcost)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
end
s.listed_names={id,48179391,110000100,110000101,777006340,777006350,777006371}
--(2)Place this card in the Spell & Trap Zone and Special Summon Tokens
function s.plcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsRitualSummoned()
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and not c:IsForbidden() and c:CheckUniqueOnField(tp) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOKEN,nil,4,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,4,tp,0)
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0
		or not c:CheckUniqueOnField(tp) then return end
	if not Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	e1:SetReset(RESET_EVENT+(RESETS_STANDARD&~RESET_TURN_SET))
	c:RegisterEffect(e1)
	local ft=math.min(4,Duel.GetLocationCount(tp,LOCATION_MZONE))
	if ft<=0 or not s.sealcheck(tp)
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,777006371,0,TYPES_TOKEN,0,0,1,RACE_WARRIOR,ATTRIBUTE_DARK) then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local t={}
	for i=1,ft do t[i]=i end
	local ct=Duel.AnnounceNumber(tp,table.unpack(t))
	for i=1,ct do
		local token=Duel.CreateToken(tp,777006371)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.SpecialSummonComplete()
end
--(3)Cards in your Spell & Trap Zone cannot be destroyed by your opponent's card effects
function s.sealfilter(c)
	return c:IsFaceup() and c:IsCode(48179391,110000100,110000101,777006340,777006350)
end
function s.sealcheck(tp)
	return Duel.IsExistingMatchingCard(s.sealfilter,tp,LOCATION_FZONE,0,1,nil)
end
function s.auracon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsContinuousSpell() and s.sealcheck(e:GetHandlerPlayer())
end
function s.indval(e,re,rp)
	return rp==1-e:GetHandlerPlayer()
end
--(4)The Tokens' ATK becomes equal to the ATK of the monster they battle
function s.atkcon(e)
	return s.auracon(e) and Duel.IsPhase(PHASE_DAMAGE_CAL) and Duel.GetAttackTarget()
end
function s.atktg(e,c)
	return c:IsFaceup() and c:IsCode(777006371) and c:GetBattleTarget()
end
function s.atkval(e,c)
	return c:GetBattleTarget():GetAttack()
end
--(5)Special Summon 1 Monster Card from your Spell & Trap Zone
function s.cfilter(c)
	return c:IsCode(777006371) and c:IsReleasable()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Release(g,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsOriginalType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
