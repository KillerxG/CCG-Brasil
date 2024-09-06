--Thundering Fire
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Procedure
	c:EnableReviveLimit()
	local e0=Fusion.AddProcMixN(c,true,true,s.ffilter,2)[1]
	e0:SetDescription(aux.Stringid(id,0))
	local e1=Fusion.AddProcMixN(c,true,true,s.ffilter2,1)[1]
	e1:SetDescription(aux.Stringid(id,1))
end
function s.ffilter(c,fc,sumtype,tp)
	return c:IsSetCard(0x275)
end
function s.ffilter2(c,fc,sumtype,tp)
	return c:IsSetCard(0x275) and c:IsHasEffect(777001740)
end