--Genshin Impact - Ganyu
--Scripted by KillerxG & Slayerzs
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER),5,2,s.ovfilter,aux.Stringid(id,0))
	c:EnableReviveLimit()
	--(1)Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE+TIMING_EQUIP,TIMINGS_CHECK_MONSTER_E)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
--Xyz Summon
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_XYZ) and c:IsSetCard(0x291,lc,SUMMON_TYPE_XYZ,tp) and not c:IsCode(id)
end
--(1)Destroy
function s.filter(c,seq,flag)
	return c:GetSequence()==seq or (flag~=0 and c:IsLocation(LOCATION_ONFIELD) and (c:GetSequence()==seq+1 or c:GetSequence()==seq-1))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		local ag=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil,tc:GetSequence())
		Duel.Destroy(ag,REASON_EFFECT)
			elseif tc and tc:IsLocation(LOCATION_SZONE) then
				local ag=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_SZONE,nil,tc:GetSequence()) 
				Duel.Destroy(ag,REASON_EFFECT)
	end
end