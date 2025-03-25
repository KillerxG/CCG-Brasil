--Frost King Psychessman
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(s.sfilter),1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--(1)Activate Limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_CANNOT_TRIGGER)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(s.coltg)
	c:RegisterEffect(e1)
	--(2)Destroy all opponent's S/T
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--(3)Destroy all cards in this column and adjacent
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.attg)
	e3:SetOperation(s.attop)
	c:RegisterEffect(e3)
end
--Synchro Summon
function s.sfilter(c,val,scard,sumtype,tp)
	return c:IsSetCard(0x262,scard,sumtype,tp) and c:IsAttribute(ATTRIBUTE_WATER,scard,sumtype,tp)
end
--(1)Activate Limit
function s.coltg(e,c)
	return c:IsFaceup() and e:GetHandler():GetColumnGroup():IsContains(c)
end
--(2)Destroy all opponent's S/T
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_ONFIELD,1,c) end
	local sg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,e:GetHandler())
	Duel.Destroy(sg,REASON_EFFECT)
end
--(3)Destroy all cards in this column and adjacent
function s.attfilter(c,seq)
	return c:GetSequence()==4-seq or (c:IsLocation(LOCATION_MZONE) and (c:GetSequence()==4-seq+1 or c:GetSequence()==4-seq-1))
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.attfilter,tp,0,LOCATION_MZONE,1,nil,e:GetHandler():GetSequence()) end
	local g=Duel.GetMatchingGroup(s.attfilter,tp,0,LOCATION_MZONE,nil,e:GetHandler():GetSequence())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.attfilter,tp,0,LOCATION_MZONE,nil,e:GetHandler():GetSequence())
	Duel.Destroy(g,REASON_EFFECT)
end