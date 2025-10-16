--Queen of Sky Wind - Serena
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	c:EnableReviveLimit()
	--(1)Special Summon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.FALSE)
	c:RegisterEffect(e0)
	--(2)Special Summon itself from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--(3)Cannot be destroyed by effects that do not target it
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	--(4)Destroy opponent's cards
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_BECOME_TARGET)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(function(e,tp,eg) return eg:IsContains(e:GetHandler()) end)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	--(5)Indes by battle
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.indestg)
	e4:SetOperation(s.indesop)
	c:RegisterEffect(e4)
end
--(2)Special Summon itself from the hand
function s.selfspfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x306)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(s.selfspfilter,tp,LOCATION_EXTRA+LOCATION_MZONE,0,nil)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>=3 and g:GetClassCount(Card.GetCode)>=3
end
--(3)Cannot be destroyed by effects that do not target it
function s.indvalue(e,re,rp,c)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g:IsContains(c)
end

function s.efilter(e,te)
	if not te then return false end
	local c=e:GetHandler()
	local ec=te:GetHandler()
	return not (ec:IsHasCardTarget(c) or (te:IsHasType(EFFECT_TYPE_ACTIONS) and te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and c:IsRelateToEffect(te)))
end
--(4)Destroy opponent's cards
function s.cfilter(c)
	return c:IsSetCard(0x306)
end
function s.lmfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9999) and c:IsType(TYPE_FUSION)
end
function s.desfilter(c)
	return c:IsFaceup() or c:IsFacedown()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sg=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_ONFIELD,1,ct,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
	if Duel.IsExistingMatchingCard(s.lmfilter,tp,LOCATION_ONFIELD,0,1,nil) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	Duel.Destroy(g,REASON_EFFECT)
end
function s.chainlm(e,rp,tp)
	return tp==rp
end
--(5)Indes by battle
function s.indestg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(aux.NOT(Card.IsHasEffect),tp,LOCATION_MZONE,0,1,nil,EFFECT_INDESTRUCTABLE_BATTLE) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	Duel.SelectTarget(tp,aux.NOT(Card.IsHasEffect),tp,LOCATION_MZONE,0,1,1,nil,EFFECT_INDESTRUCTABLE_BATTLE)
end
function s.indesop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		--It cannot be destroyed by battle this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3000)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end