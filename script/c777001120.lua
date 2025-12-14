--Shinigami Attack
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Make the opponent tribute a monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.relcon)
	e1:SetCost(s.relcost)
	e1:SetTarget(s.reltg)
	e1:SetOperation(s.relop)
	c:RegisterEffect(e1)
end
--(1)Make the opponent tribute a monster
function s.confilter(c)
	return c:IsSetCard(0x304) and c:IsFaceup()
end
function s.relcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.relcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,c)
	Duel.Release(g,REASON_COST)
end
function s.reltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsReleasable,tp,0,LOCATION_ONFIELD,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,2,0,LOCATION_ONFIELD)
end
function s.relop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(Card.IsReleasable,1-tp,LOCATION_ONFIELD,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_RELEASE)
		local sg=g:Select(1-tp,2,2,nil)
		Duel.HintSelection(sg)
		Duel.Release(sg,REASON_RULE,1-tp)
	end
end