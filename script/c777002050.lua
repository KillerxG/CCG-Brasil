--Draconic Travel
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e0:SetCost(s.thcost)
	c:RegisterEffect(e0)
	--(1)ATK Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsSetCard(0x300) end)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--(2)Reveal any number of FIRE monsters in your hand, shuffle them into the Deck, then draw the same number of cards
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	--Can be activated the turn it was Set by banishing 1 face-up "Maliss" monster you control
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e3:SetValue(function(e) e:SetLabel(1) end)
	e3:SetCondition(function(e) return Duel.IsExistingMatchingCard(s.thcostfilter,e:GetHandlerPlayer(),LOCATION_EXTRA,0,1,nil,e:GetHandlerPlayer()) end)
	c:RegisterEffect(e3)
	e0:SetLabelObject(e3)
end

function s.thcostfilter(c,tp)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToRemove(tp)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local label_obj=e:GetLabelObject()
	if chk==0 then label_obj:SetLabel(0) return true end
	if label_obj:GetLabel()>0 then
		label_obj:SetLabel(0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.thcostfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
--(1)ATK Up
function s.atkfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsMonster() and c:IsFaceup()
end
function s.atkval(e,c)
	return 200*Duel.GetMatchingGroupCount(s.atkfilter,e:GetHandlerPlayer(),LOCATION_REMOVED,0,nil)
end
--(2)Reveal any number of FIRE monsters in your hand, shuffle them into the Deck, then draw the same number of cards
function s.tdfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsMonster() and c:IsAbleToDeck() and not c:IsPublic()
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_HAND,0,1,99,nil)
	if #g>0 then
		Duel.ConfirmCards(1-tp,g)
		local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		if ct>0 then
			Duel.ShuffleDeck(tp)
			if Duel.IsPlayerCanDraw(tp) then
				Duel.BreakEffect()
				Duel.Draw(tp,ct,REASON_EFFECT)
			end
		end
	end
end