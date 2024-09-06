--Warbeast Token
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Cannot be used as material, except for "Warbeasts"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetCondition(s.matcon)
	e1:SetValue(s.matlimit)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetCondition(s.matcon)
	e2:SetValue(s.matlimit)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e3:SetCondition(s.matcon)
	e3:SetValue(s.matlimit)
	c:RegisterEffect(e3)
end
--(1)Cannot be used as material, except for "Warbeasts"
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(777001840)
end
function s.matcon(e)
	return not Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function s.matlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x308)
end