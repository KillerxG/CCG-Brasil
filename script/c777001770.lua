--Thundering Fire
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Treat as 2 Materials
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(777001740)
	e1:SetValue(2)
	c:RegisterEffect(e1)
end
