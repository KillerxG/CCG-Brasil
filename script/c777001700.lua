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
	--(1)Cannot be destroyed
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	c:RegisterEffect(e2)
end
function s.ffilter(c,fc,sumtype,tp)
	return c:IsSetCard(0x275)
end
function s.ffilter2(c,fc,sumtype,tp)
	return c:IsSetCard(0x275) and c:IsHasEffect(777001740)
end
--(1)Cannot be destroyed
function s.valcheck(e,c)
	if c:GetMaterialCount()==2 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetCondition(s.indcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		c:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetDescription(aux.Stringid(id,2))
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		c:RegisterEffect(e2,true)
	end
end
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end