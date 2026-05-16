--FGO Army of the King Token
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	 c:AddSetcodesRule(0x294b)
	--Your "Myutant" monsters gains ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x294b))
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
end

function s.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TOKEN)
end
function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(s.atkfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	return g:GetClassCount(Card.GetCode)*200
end