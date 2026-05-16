--Siver Fangs Pray
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.drcost)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	--(2)Gain LP
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.lptg)
	e2:SetOperation(s.lpop)
	c:RegisterEffect(e2)
end
--(1)Draw
function s.drcostfilter(c)
	return c:IsMonster() and c:IsSetCard(0x307)	and c:IsAbleToGraveAsCost()
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.drcostfilter,tp,LOCATION_HAND,0,1,nil) end
		Duel.DiscardHand(tp,s.drcostfilter,1,1,REASON_COST+REASON_DISCARD)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandlerPlayer()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	if Duel.Draw(tp,2,REASON_EFFECT)>0 
		and Duel.GetLP(tp)<Duel.GetLP(1-tp) then
			Duel.BreakEffect()
			Duel.Recover(tp,1000,REASON_EFFECT)
	end
end
--(2)Gain LP
function s.costfilter(c)
	return c:IsMonster() and not c:IsPublic()
end
function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	if e:GetLabel()==1 then
		e:SetLabel(0)
	end
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	if #g==0 then return end
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	local tc=g:GetFirst()
	if tc:IsMonster() then
		Duel.Recover(tp,tc:GetLevel()*200,REASON_EFFECT)
	end
	if tc:IsMonster() and tc:IsSetCard(0x307) then
		Duel.BreakEffect()
		Duel.Recover(tp,tc:GetLevel()*400,REASON_EFFECT)
	end
end

