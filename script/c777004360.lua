--Naikardian - Marionette
--Scripted by Codex
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--(1)Cannot be Ritual Summoned, except by "Naikardian's Invasion"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.ritlimit)
	c:RegisterEffect(e1)
	--(2)Special Summon 1 "Marionette" Token
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.tkcon)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)
	--(3)There can only be 1 "Naikardian" monster on the field
	c:SetUniqueOnField(1,1,aux.FilterBoolFunction(Card.IsSetCard,0x317),LOCATION_MZONE)
	--(4)Check if this card was Ritual Summoned using "Zaskar"
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(s.matcheck)
	c:RegisterEffect(e4)
	--(4)Unaffected by the opponent's card effects
	local e4a=Effect.CreateEffect(c)
	e4a:SetType(EFFECT_TYPE_SINGLE)
	e4a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4a:SetCode(EFFECT_IMMUNE_EFFECT)
	e4a:SetRange(LOCATION_MZONE)
	e4a:SetCondition(s.immcon)
	e4a:SetValue(s.immval)
	c:RegisterEffect(e4a)
	--(5)Cannot Special Summon monsters from the Extra Deck
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(1,0)
	e5:SetTarget(s.exlimit)
	c:RegisterEffect(e5)
	--(6)Cannot be targeted for attacks while you control another monster
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.atcon)
	e6:SetValue(aux.imval1)
	c:RegisterEffect(e6)
	--(7)Protect face-up Spells/Traps you control
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e7:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e7:SetRange(LOCATION_MZONE)
	e7:SetTargetRange(LOCATION_SZONE|LOCATION_FZONE,0)
	e7:SetTarget(s.sttg)
	e7:SetValue(aux.tgoval)
	c:RegisterEffect(e7)
	local e7a=e7:Clone()
	e7a:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e7a:SetValue(s.indval)
	c:RegisterEffect(e7a)
	--(8)Take control of 1 opponent's monster
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,3))
	e8:SetCategory(CATEGORY_CONTROL)
	e8:SetType(EFFECT_TYPE_QUICK_O)
	e8:SetCode(EVENT_FREE_CHAIN)
	e8:SetRange(LOCATION_MZONE)
	e8:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e8:SetCountLimit(1)
	e8:SetCondition(function() return Duel.IsMainPhase() end)
	e8:SetCost(s.ctcost)
	e8:SetTarget(s.cttg)
	e8:SetOperation(s.ctop)
	c:RegisterEffect(e8)
	--(9)Set 1 "Destiny Board" from the Deck or GY
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,4))
	e9:SetCategory(CATEGORY_SET)
	e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e9:SetCode(EVENT_PHASE+PHASE_END)
	e9:SetRange(LOCATION_MZONE)
	e9:SetCountLimit(1)
	e9:SetCondition(s.setcon)
	e9:SetTarget(s.settg)
	e9:SetOperation(s.setop)
	c:RegisterEffect(e9)
end
s.listed_names={777004330,777004350,777004355,777004365,94212438}
s.listed_series={0x317}

--(1)Cannot be Ritual Summoned, except by "Naikardian Invasion"
function s.ritlimit(e,se,sp,st)
	if (st&SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL then
		return se and se:GetHandler():IsCode(777004330)
	end
	return true
end

--(2)Special Summon 1 "Marionette" Token
function s.exfilter(c,sp)
	return c:IsSummonPlayer(sp) and c:IsPreviousLocation(LOCATION_EXTRA)
end
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (eg:IsContains(c) and c:IsRitualSummoned()) or eg:IsExists(s.exfilter,1,nil,1-tp)
end
function s.can_summon_token(tp,code)
	return Duel.IsPlayerCanSpecialSummonMonster(tp,code,0,TYPES_TOKEN,2000,2000,6,RACE_MACHINE,ATTRIBUTE_DARK)
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and (s.can_summon_token(tp,777004355) or s.can_summon_token(tp,777004365)) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local b1=s.can_summon_token(tp,777004355)
	local b2=s.can_summon_token(tp,777004365)
	if not (b1 or b2) then return end
	local code
	if b1 and b2 then
		code=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))==0 and 777004355 or 777004365
	else
		code=b1 and 777004355 or 777004365
	end
	local token=Duel.CreateToken(tp,code)
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end

--(4)Unaffected by the opponent's card effects if Ritual Summoned using "Zaskar"
function s.matcheck(e,c)
	if c:GetMaterial():IsExists(Card.IsCode,1,nil,777004350) then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~(RESET_TOFIELD|RESET_LEAVE|RESET_TEMP_REMOVE),EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,5))
	end
end
function s.immcon(e)
	local c=e:GetHandler()
	return c:IsRitualSummoned() and c:HasFlagEffect(id)
end
function s.immval(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

--(5)Cannot Special Summon monsters from the Extra Deck
function s.exlimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end

--(6)Cannot be targeted for attacks while you control another monster
function s.atcon(e)
	local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(aux.TRUE,c:GetControler(),LOCATION_MZONE,0,1,c)
end

--(7)Protect face-up Spells/Traps you control
function s.sttg(e,c)
	return c:IsFaceup()
end
function s.indval(e,re,rp)
	return rp~=e:GetHandlerPlayer()
end

--(8)Take control of 1 opponent's monster
function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsType,2,false,nil,nil,TYPE_TOKEN) end
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsType,2,2,false,nil,nil,TYPE_TOKEN)
	Duel.Release(g,REASON_COST)
end
function s.ctfilter(c)
	return c:IsControlerCanBeChanged()
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.ctfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local tc=Duel.SelectMatchingCard(tp,s.ctfilter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if tc then Duel.GetControl(tc,tp) end
end

--(9)Set 1 "Destiny Board" from the Deck or GY
function s.setfilter(c)
	return c:IsCode(94212438) and c:IsSSetable()
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp)
		and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_SZONE,0,1,nil,94212438)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then Duel.SSet(tp,g) end
end
