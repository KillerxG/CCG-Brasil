--Oceanic Storm Blood Experience
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCost(Cost.PayLP(800))
	c:RegisterEffect(e0)
	--(1)Force your opponent pays 800 LP Damage when the opponent Special Summons from the Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.lpcon)
	e1:SetOperation(s.lpop)
	c:RegisterEffect(e1)
	--(2)Your LP becomes 4000
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.healcon)
	e2:SetOperation(s.healop)
	c:RegisterEffect(e2)
	--(3)Your "Oceanic Storm" monsters cannot be destroyed by effects that do not target them
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x312))
	e3:SetValue(s.indvalue)
	c:RegisterEffect(e3)
end
--(1)Force your opponent pays 800 LP Damage when the opponent Special Summons from the Extra Deck
function s.damfilter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.damfilter,1,nil,tp)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.CheckLPCost(1-tp,800) then
		Duel.Hint(HINT_CARD,1-tp,id)
		Duel.PayLPCost(1-tp,800)
	end
end
--(2)Your LP becomes 4000
function s.cfilter1(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(777003320)
end
function s.healcon(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandlerPlayer()
	return Duel.GetLP(tp)<=2000 and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end
function s.healop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetLP(tp,4000)
end
--(3)Your "Oceanic Storm" monsters cannot be destroyed by effects that do not target them
function s.indvalue(e,re,rp,c)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g:IsContains(c)
end