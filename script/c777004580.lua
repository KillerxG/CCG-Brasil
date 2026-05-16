--Theationist Training
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DICE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--(2)Dice of Fate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.mattg)
	e2:SetOperation(s.matop)
	c:RegisterEffect(e2)
end
s.roll_dice=true
--(1)Destoy
function s.cfilter(c)
	return c:IsFaceup() and (c:IsLevelBelow(1) or c:IsRankBelow(1) or c:IsLinkBelow(1))
end
function s.filter1(c)
	return c:IsFaceup() and (c:IsLevelBelow(11) or c:IsRankBelow(11) or c:IsLinkBelow(11))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(s.cfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,2)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.filter2(c,lv)
	return c:IsFaceup() and (c:IsLevelBelow(lv-1) or c:IsRankBelow(lv-1) or c:IsLinkBelow(lv-1))
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local d1,d2=Duel.TossDice(tp,2)
	local g=Duel.GetMatchingGroup(s.filter2,tp,0,LOCATION_MZONE,nil,d1+d2)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
--(2)Dice of Fate
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.TossDice(tp,1)
	if d==1 or d==2 then
		if e:GetHandler():IsRelateToEffect(e) then
		Duel.SendtoHand(e:GetHandler(),1-tp,REASON_EFFECT)
		end	
	elseif d==3 or d==4 then
		if e:GetHandler():IsRelateToEffect(e) then
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
		end	
	else
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsSSetable() then
			Duel.SSet(tp,c)
		end
	end
end