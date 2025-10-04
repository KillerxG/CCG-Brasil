--Forest Legion Scout
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,Card.IsNonEffectMonster,2)
	--(1)Directly Attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	--(2)ATK Up
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	--(3)Special Summon itself
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(aux.exccon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
--(2)ATK Up
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
--(3)Special Summon itself
function s.rmfilter(c)
	return c:IsSetCard(0x255) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true,false)
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetOriginalCode)==#sg
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_GRAVE|LOCATION_MZONE,0,e:GetHandler())
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local g=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_REMOVE,nil,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end