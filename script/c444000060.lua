-- Okami - Shiranui
-- Scripted by Leonardofake & Imp
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
    --Fusion Summon Procedure
    Fusion.AddProcMixN(c,true,true,444000000,1,aux.FilterBoolFunctionEx(Card.IsSetCard,0x444),2)
    Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	--Name becomes "Okami - Amaterasu" while on the field on in GY
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e0:SetValue(444000000)
	c:RegisterEffect(e0)
	--Unaffected
	local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.unfilter)
    c:RegisterEffect(e1)
	--ATK Change
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetValue(s.atkval2)
	c:RegisterEffect(e3)
	--Force Cost
  	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_ACTIVATE_COST)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(0,1)
	e4:SetCondition(s.costcon)
	e4:SetCost(s.costchk)
	e4:SetOperation(s.costop)
	c:RegisterEffect(e4)
	--Special Summon
	local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCountLimit(1,id)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
end
--Fusion Summon Procedure 
function s.contactfil(tp)
    return Duel.GetReleaseGroup(tp)
end
function s.contactop(g)
    Duel.Release(g,REASON_COST+REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
    return (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
--Unaffected
function s.unfilter(e,te)
    return te:IsActiveType(TYPE_SPELL+TYPE_TRAP) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
--ATK Change
function s.atkfilter(c)
    return (c:IsSpell() or c:IsTrap())
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_GRAVE,LOCATION_GRAVE,nil)*200
end
function s.atkfilter2(c)
    return (c:IsSpell() or c:IsTrap()) and c:IsSetCard(0x444) and c:IsFaceup()
end
function s.atkval2(e,c)
    return Duel.GetMatchingGroupCount(s.atkfilter2,c:GetControler(),LOCATION_REMOVED,LOCATION_REMOVED,nil)*300
end 
--Force Cost
function s.costcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.costchk(e,te_or_c,tp)
	local ct=#{Duel.GetPlayerEffect(tp,id)}
	return Duel.IsPlayerCanDiscardDeckAsCost(tp,2)
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(tp,2,REASON_COST)
end
--Special Summon
function s.spfilter(c,e,tp)
	return c:IsOriginalCode(444000000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end