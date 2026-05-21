--Queen of Sky Wind - Serena
--Scripted by Codex
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--You can only Special Summon this card once per turn
	c:SetSPSummonOnce(id)
	--Cannot be Normal Summoned/Set
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.FALSE)
	c:RegisterEffect(e0)
	--Special Summon procedure
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--Unaffected by opponent's non-targeting effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	--Add "Sky Wind" cards
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	--If this card becomes targeted: negate face-up cards your opponent controls
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_BECOME_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCondition(s.negcon)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
end
s.listed_series={0x306}

function s.swmonfilter(c)
	return c:IsSetCard(0x306) and c:IsMonster() and (not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup())
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.swmonfilter,tp,LOCATION_MZONE|LOCATION_EXTRA,0,nil)
	return g:GetClassCount(Card.GetCode)>=3
end

function s.efilter(e,te)
	local c=e:GetHandler()
	if te:GetOwnerPlayer()==c:GetControler() then return false end
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not (tg and tg:IsContains(c))
end

function s.thfilter(c)
	return c:IsSetCard(0x306) and c:IsAbleToHand() and (not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup())
end
function s.thtgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x306) and c:IsMonster()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.thtgfilter(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.thtgfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.thtgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local ct=math.floor(math.max(g:GetFirst():GetAttack(),0)/1000)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,math.max(ct,1),tp,LOCATION_GRAVE|LOCATION_EXTRA)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	local ct=math.floor(math.max(tc:GetAttack(),0)/1000)
	if ct<=0 then return end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE|LOCATION_EXTRA,0,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:Select(tp,1,math.min(ct,#g),nil)
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,sg)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
function s.swnamefilter(c)
	return c:IsFaceup() and c:IsSetCard(0x306)
end
function s.negfilter(c)
	return c:IsFaceup() and not c:IsDisabled()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=Duel.GetMatchingGroup(s.swnamefilter,tp,LOCATION_ONFIELD,0,nil):GetClassCount(Card.GetCode)
	if chkc then
		return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.negfilter(chkc)
	end
	if chk==0 then
		return ct>0 and Duel.IsExistingTarget(s.negfilter,tp,0,LOCATION_ONFIELD,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,s.negfilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e):Filter(Card.IsRelateToEffect,nil,e)
	for tc in aux.Next(g) do
		if tc:IsFaceup() and not tc:IsDisabled() then
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			tc:RegisterEffect(e2)
		end
	end
end