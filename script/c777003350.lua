--Oceanic Storm Cidadel: Nightfall
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--(1)Activate "Oceanic Storm Cidadel: Dawn"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.accost)
	e1:SetCondition(s.accon)
	e1:SetOperation(s.acop)
	c:RegisterEffect(e1)
	--(2)Swap: Activate "Oceanic Storm Cidadel: Dawn"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) and Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_DECK,0,1,nil,tp) end)
	e2:SetOperation(s.acop)
	c:RegisterEffect(e2)
	--(3)Also always "Umi"
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_ADD_CODE)
	e3:SetValue(22702055)
	c:RegisterEffect(e3)
	--(4)Destroy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_PAY_LPCOST)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(2)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
	--(5)Avoid battle damage
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetCondition(s.condition)
	e5:SetTarget(s.efilter)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	--(6)Reduce effect damage
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_CHANGE_DAMAGE)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetRange(LOCATION_SZONE)
	e6:SetTargetRange(1,0)
	e6:SetCondition(s.condition)
	e6:SetValue(s.damval)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e7)
end
s.listed_names={CARD_UMI}
--(1)Activate "Oceanic Storm Cidadel: Dawn"
function s.cfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x312) or c:IsMonster())
end
function s.accost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,800) and not e:GetHandler():IsPublic() end
	Duel.PayLPCost(tp,800)
end
function s.fieldfilter(c,tp)
	return c:IsCode(777000830) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_DECK,0,1,nil,tp) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.fieldfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp) then
		Duel.SendtoDeck(c,nil,2,REASON_EFFECT)
	end
end
--(2)Swap: Activate "Oceanic Storm Cidadel: Dawn"
function s.field2filter(c,tp)
	return c:IsCode(777000830) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.field2filter,tp,LOCATION_DECK,0,1,nil,tp)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.SendtoDeck(c,nil,2,REASON_EFFECT)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.field2filter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp) then
		--Duel.SendtoDeck(c,nil,2,REASON_EFFECT)
	end
end
--(4)Destroy
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_MZONE|LOCATION_GRAVE)
end
function s.rmfilter(c)
	return c:IsAbleToRemove() and aux.SpElimFilter(c)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or Duel.Destroy(tc,REASON_EFFECT)==0
		or not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsOriginalCode,777003320),tp,LOCATION_MZONE,0,1,nil) then return end
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,nil)
	if #g==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=g:Select(tp,1,1,nil)
	if #rg>0 then
		Duel.BreakEffect()
		Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
	end
end
--(5)Avoid battle damage
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
function s.efilter(e,c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end
--(6)Reduce effect damage
function s.damval(e,re,val,r,rp,rc)
	if (r&REASON_EFFECT)~=0 then return 0 end
	return val
end