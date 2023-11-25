--Promised Land, Cherubim
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)To your GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)	
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--(2)Indestructable by Effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--(3)Can Attack 3 times
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetValue(2)
	c:RegisterEffect(e3)
end
--(1)To your GY
function s.costfilter(c)
	return c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rt=math.min(2,Duel.GetTargetCount(aux.TRUE,tp,0,LOCATION_ONFIELD,nil))
	if chk==0 then return aux.IceBarrierDiscardCost(s.costfilter,true,1,rt)(e,tp,eg,ep,ev,re,r,rp,0) end
	e:SetLabel(aux.IceBarrierDiscardCost(s.costfilter,true,1,rt)(e,tp,eg,ep,ev,re,r,rp,1))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	local ct=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local eg=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,ct,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,eg,ct,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetTargetCards(e)
	if #rg>0 then 
		Duel.SendtoGrave(rg,tp,REASON_EFFECT)
	end
end