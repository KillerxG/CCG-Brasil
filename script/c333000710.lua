--Melt Queen Psychesswoman
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--Xyz Summon
	Xyz.AddProcedure(c,nil,5,2,nil,nil,nil,nil,false,s.xyzcheck)
	c:EnableReviveLimit()
	--(1)Attach
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.DetachFromSelf(2,2))
	e1:SetTarget(s.attg)
	e1:SetOperation(s.attop)
	c:RegisterEffect(e1)
	--(2)Special Summon 1 Level "Psychess" monster from Deck or GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetCost(Cost.DetachFromSelf(1,1))
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--(3)Disable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.con)
	e3:SetTarget(s.coltg)
	c:RegisterEffect(e3)
end
--Xyz Summon
function s.xyzfilter(c,xyz,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE,xyz,SUMMON_TYPE_XYZ,tp) and c:IsSetCard(0x262)
end
function s.xyzcheck(g,tp,xyz)
	local mg=g:Filter(function(c) return not c:IsHasEffect(511001175) end,nil)
	return mg:IsExists(s.xyzfilter,1,nil,xyz,tp)
end
--(1)Attach
function s.attfilter(c,seq)
	return c:GetSequence()==4-seq or (c:IsLocation(LOCATION_MZONE) and (c:GetSequence()==4-seq+1 or c:GetSequence()==4-seq-1))
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.attfilter,tp,0,LOCATION_MZONE,1,nil,e:GetHandler():GetSequence()) end
	local g=Duel.GetMatchingGroup(s.attfilter,tp,0,LOCATION_MZONE,nil,e:GetHandler():GetSequence())
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.attfilter,tp,0,LOCATION_MZONE,nil,e:GetHandler():GetSequence())
	Duel.Overlay(c,g)
end
--(2)Special Summon 1 Level "Psychess" monster from Deck or GY
function s.filter(c,e,tp)
	return c:IsSetCard(0x262) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
--(3)Disable
function s.con(e)
	return e:GetHandler():GetOverlayCount()>1
end
function s.coltg(e,c)
	return e:GetHandler():GetColumnGroup(1,1):IsContains(c) and c:IsFaceup()
end