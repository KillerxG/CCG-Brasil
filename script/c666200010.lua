--Cheat Code Kurai
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
	--(2)Equip "Cheat Code" monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
	--(2.1)Equip "Cheat Code" monster activate in hand
	local e4=e3:Clone()
	e4:SetRange(LOCATION_HAND)
	e4:SetCondition(s.eq2con)
	c:RegisterEffect(e4)
	--(2.2)Register that a player has activated "Cheat Code Overcharge" during this turn
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end)
	--(3)Special Summon this card from Banishment
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_EQUIP+CATEGORY_SPECIAL_SUMMON)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCountLimit(1,id+1)
	e3:SetTarget(s.eq2tg)
	e3:SetOperation(s.eq2op)
	c:RegisterEffect(e3)
	aux.AddEREquipLimit(c,nil,s.eqval,Card.EquipByEffectAndLimitRegister,e3)
	--(3.1)Special Summon this card from hand
	local e4=e3:Clone()
	e4:SetRange(LOCATION_HAND)
	e4:SetCondition(s.eq2con)
	c:RegisterEffect(e4)
	--(3.2)Special Summon this card from Szone
	local e5=e3:Clone()
	e5:SetRange(LOCATION_SZONE)
	e5:SetTarget(s.eq3tg)
	e5:SetOperation(s.eq3op)
	c:RegisterEffect(e5)
end
--(1)Equip "Cheat Code" monster
function s.efilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,c)
end
function s.eqfilter(c,tc)
	return not c:IsForbidden() and (c:IsMonster() and c:IsSetCard(0x352)) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND|LOCATION_DECK))
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.efilter(chkc,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.efilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.efilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsControler(tp) and tc:IsRace(RACE_CYBERSE)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,tc)
	local eq=g:GetFirst()
	if eq then
		Duel.Equip(tp,eq,tc,true)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		e1:SetLabelObject(tc)
		eq:RegisterEffect(e1)
	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
--(2.1)Equip "Cheat Code" monster activate in hand
function s.eq2con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.HasFlagEffect(tp,id)
end
--(2.2)Register that a player has activated "Cheat Code Overcharge" during this turn
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.HasFlagEffect(rp,id) and re:GetHandler():IsCode(666200030) and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.RegisterFlagEffect(rp,id,RESET_EVENT|RESET_PHASE|PHASE_END,0,0)
	end
end
--(3)Special Summon this card from Banishment
function s.eqfdsilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsRace(RACE_CYBERSE)
end
function s.eqval(ec,c,tp)
	return ec:IsControler(tp) and ec:IsFaceup() and ec:IsMonster() and ec:IsRace(RACE_CYBERSE) and not c:IsForbidden()
end
function s.eq2tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfdsilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.eqfdsilter,tp,LOCATION_MZONE,0,1,nil) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfdsilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.eq2op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) then
		c:EquipByEffectAndLimitRegister(e,tp,tc)
	end
end
--(3.2)Special Summon this card from Szone
function s.eq3tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfdsilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.eqfdsilter,tp,LOCATION_MZONE,0,1,nil) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfdsilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.eq3op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) then
		c:EquipByEffectAndLimitRegister(e,tp,tc)
	end
end
