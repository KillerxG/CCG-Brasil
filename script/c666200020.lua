--Cheat Code Birdware
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --(1)Banish itself it it leaves the field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e1:SetCondition(function(e) return e:GetHandler():IsFaceup() end)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)
	--(2)Treat equipped monster as a "Cheat Code" monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_ADD_SETCODE)
	e2:SetValue(0x352)
	c:RegisterEffect(e2)
	--(3)Equip this card to a monster from Banishment
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
	--(3.1)Equip this card to a monster from hand
	local e4=e3:Clone()
	e4:SetRange(LOCATION_HAND)
	e4:SetCondition(s.eq2con)
	c:RegisterEffect(e4)
	--(3.1.1)Register that a player has activated "Cheat Code Overcharge" during this turn
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end)
	--(3.2)Equip this card to a monster from Szone
	local e5=e3:Clone()
	e5:SetRange(LOCATION_SZONE)
	e5:SetTarget(s.eq2tg)
	e5:SetOperation(s.eq2op)
	c:RegisterEffect(e5)
	--(4)Special Summon from hand or Banishment
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,id+1)
	e6:SetTarget(s.gysptg)
	e6:SetOperation(s.gyspop)
	c:RegisterEffect(e6)
	--(4.1)Activate from hand
	local e7=e6:Clone()
	e7:SetRange(LOCATION_HAND)
	e7:SetCondition(s.eq2con)
	c:RegisterEffect(e7)
end
--(3)Equip this card to a monster from Banishment
function s.eqfilter(c)
	return c:IsFaceup() and c:IsMonster() and ((c:IsRace(RACE_CYBERSE) and (c:IsAttribute(ATTRIBUTE_EARTH) or c:IsAttribute(ATTRIBUTE_WIND))) or c:IsSetCard(0x352))
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and tc and tc:IsRelateToEffect(e) and tc:IsControler(tp) and not tc:IsFacedown() then
		Duel.Equip(tp,c,tc,true)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		e1:SetLabelObject(tc)
		c:RegisterEffect(e1)
	end
end
--(3.1.1)Register that a player has activated "Cheat Code Overcharge" during this turn
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.HasFlagEffect(rp,id) and re:GetHandler():IsCode(666200030) and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.RegisterFlagEffect(rp,id,RESET_EVENT|RESET_PHASE|PHASE_END,0,0)
	end
end
--(3.1)Equip this card to a monster from hand
--(4.1)Activate from hand
function s.eq2con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.HasFlagEffect(tp,id)
end
--(3.2)Equip this card to a monster from Szone
function s.eq2tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.eq2op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsControler(tp) and not tc:IsFacedown() then
		Duel.Equip(tp,c,tc,true)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		e1:SetLabelObject(tc)
		c:RegisterEffect(e1)
	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
--(4)Special Summon from hand or Banishment
function s.gysfilter(c,e,tp)
	return c:IsSetCard(0x352) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
function s.gysptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.gysfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.gyspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.gysfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end