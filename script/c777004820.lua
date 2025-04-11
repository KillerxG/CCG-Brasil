--East Wings Champion, Catherine
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--Xyz Summon
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,s.xyzfilter,nil,2,nil,nil,2,nil,false,s.xyzcheck)
	--(1)Cannot target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--(2)Indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.indval)
	c:RegisterEffect(e2)
	--(3)Effect Gain: Unaffected
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(function(e,te) return te:IsActivated() and e:GetOwnerPlayer()~=te:GetOwnerPlayer() end)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(function(e) return e:GetHandler():IsContinuousSpell() end)
	e4:SetTarget(s.eftg)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
	--(4)Special Summon itself
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,id)
	e5:SetCondition(function(e) return e:GetHandler():IsContinuousSpell() end)
	e5:SetTarget(s.attachtg)
	e5:SetOperation(s.attachop)
	c:RegisterEffect(e5)
	--(5)Take Control
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_CONTROL)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_MZONE)
	e6:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e6:SetCountLimit(1,id+1)
	e6:SetCost(s.ctrlcost)
	e6:SetTarget(s.ctrltg)
	e6:SetOperation(s.ctrlop)
	c:RegisterEffect(e6)
end
--Xyz Summon
function s.xyzfilter(c,xyz,sumtype,tp)
	return c:IsType(TYPE_XYZ,xyz,sumtype,tp) and c:IsSetCard(0x314,xyz,sumtype,tp)
end
function s.xyzcheck(g,tp,xyz)
	local mg=g:Filter(function(c) return not c:IsHasEffect(511001175) end,nil)
	return mg:GetClassCount(Card.GetRank)==1
end
--(2)Indes
function s.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end
--(3)Effect Gain: Unaffected
function s.eftg(e,c)
	local g=e:GetHandler():GetColumnGroup(1,1)
	return c:IsType(TYPE_EFFECT) and c:IsSetCard(0x314) and c:GetSequence()<5 and g:IsContains(c)
end
--(4)Special Summon itself
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsCanBeXyzMaterial(c,tp,REASON_EFFECT) and chkc:IsFaceup() end
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,0x314),tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then return ct>0 and Duel.IsExistingTarget(aux.FaceupFilter(Card.IsCanBeXyzMaterial,c,tp,REASON_EFFECT),tp,0,LOCATION_MZONE,1,c) 
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
	Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsCanBeXyzMaterial,c,tp,REASON_EFFECT),tp,0,LOCATION_MZONE,1,ct,c)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end
	local tg=Duel.GetTargetCards(e):Remove(Card.IsImmuneToEffect,nil,e)
	if #tg>0 and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.Overlay(c,tg,true)
	end
end
--(5)Take Control
function s.ctrlfilter(c,e,tp)
	return c:IsFaceup() and c:IsMonsterCard() and c:IsContinuousSpell() and c:IsAbleToGraveAsCost()
end
function s.ctrlcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST)
	local b2=Duel.IsExistingMatchingCard(s.ctrlfilter,tp,LOCATION_SZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=nil
	if b1 and b2 then
		op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,3)},
			{b2,aux.Stringid(id,4)})
	else
		op=(b1 and 1) or (b2 and 2)
	end
	if op==1 then
		e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.ctrlfilter,tp,LOCATION_SZONE,0,1,1,nil)
		Duel.SendtoGrave(g,REASON_COST)
	end
end
function s.ctrltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsControlerCanBeChanged),tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsControlerCanBeChanged),tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,tp,0)
end
function s.ctrlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.GetControl(tc,tp)
		if tc:HasLevel() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(7)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		end
	end
end
