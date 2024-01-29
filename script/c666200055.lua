--Cheat Code Kurailess
--Scripted by Imp
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon
    Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x352),aux.FilterBoolFunctionEx(Card.IsRace,RACE_CYBERSE))
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	c:EnableReviveLimit()
	--Extra Material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e0:SetRange(LOCATION_EMZONE+LOCATION_REMOVED)
	e0:SetTargetRange(LOCATION_GRAVE,0)
	e0:SetCountLimit(1)
	e0:SetTarget(function(e,c) return c:IsSetCard(0x352) and c:IsAbleToRemove() end)
	e0:SetOperation(Fusion.BanishMaterial)
	e0:SetValue(s.mtval)
	c:RegisterEffect(e0)
	--Fusion Summon
	local params = {nil,Fusion.OnFieldMat}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e1:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e1)
end
 --Fusion Summon
function s.contactfil(tp)
	return Duel.GetReleaseGroup(tp)
end
function s.contactop(g)
	Duel.Release(g,REASON_COST+REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
--Extra Material
function s.mtval(e,c)
	if not c then return false end
	return c:IsRace(RACE_CYBERSE) and c:IsControler(e:GetHandlerPlayer())
end