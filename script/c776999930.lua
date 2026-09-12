-- Lord of Shinigamis - Darkness
-- Scripted by Codex
--[[ Effects:
	E0: Cannot be Normal Summoned/Set. This card's Divine Hierarchy Rank is 1.
	E1: This card cannot be destroyed by battle or card effects.
	E2: Once per turn: You can Tribute 3 other monsters from your hand or field, and if you do, increase this card's Hierarchy Rank by 1.
	E3: Once per turn: You can target 1 DARK monster in any GYs; Special Summon it.
	E4: Once per turn (Quick Effect): You can target 1 other monster on the field; Tribute it.
]]
local s,id=GetID()
Duel.LoadScript("proc_divine_hierarchy_mod.lua")
function s.initial_effect(c)
	DivineHierarchyMod.Register(c,1)
	c:EnableReviveLimit()
	--(1)Cannot be destroyed by battle or card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e1b)
	--(2)Tribute 3 other monsters to increase this card's Hierarchy Rank
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RELEASE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.hrtg)
	e2:SetOperation(s.hrop)
	c:RegisterEffect(e2)
	--(3)Special Summon 1 DARK monster from either GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--(4)Tribute 1 other monster on the field
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_RELEASE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e4:SetTarget(s.reltg)
	e4:SetOperation(s.relop)
	c:RegisterEffect(e4)
end
function s.hrfilter(c)
	return c:IsMonster() and c:IsReleasableByEffect()
end
function s.hrtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.hrfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,3,c) end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,3,tp,LOCATION_HAND|LOCATION_MZONE)
end
function s.hrop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.hrfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,c)
	if #g<3 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local rg=g:Select(tp,3,3,nil)
	if Duel.Release(rg,REASON_EFFECT)==3 and c:IsRelateToEffect(e) and c:IsFaceup() then
		DivineHierarchyMod.IncreaseRank(c,1,RESET_EVENT|RESETS_STANDARD)
	end
end
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.relfilter(c,e)
	return c:IsReleasableByEffect() and c:IsCanBeEffectTarget(e)
end
function s.reltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc~=c and s.relfilter(chkc,e) end
	if chk==0 then return Duel.IsExistingTarget(s.relfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectTarget(tp,s.relfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,e)
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,0,0)
end
function s.relop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Release(tc,REASON_EFFECT)
	end
end
