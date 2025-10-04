--Black and Blue Wave
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Banish then draw 1 card
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
--(1)Banish then draw 1 card
function s.bluefilter(c)
	return c:IsRitualMonster() or c:IsType(TYPE_LINK)
end
function s.cfilter(c)
	return c:IsFaceup() and c:GetOverlayCount()>0 and c:GetOverlayGroup()IsExists(s.bluefilter,1,nil)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end