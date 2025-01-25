--Kiss of Noct Frost
--Scripted by KillerxG
local EFFECT_DOUBLE_XYZ_MATERIAL=511001225 --to be removed when the procedure is updated
local s,id=GetID()
function s.initial_effect(c)
	--(1)Equip only to a WATER monster
	aux.AddEquipProcedure(c,nil,s.eqfilter)
	--(2)Treat Equipped monster as 2 materials for Xyz Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_DOUBLE_XYZ_MATERIAL)
	e1:SetOperation(function(e,c,matg) return c:IsSetCard(0x353) and c.minxyzct and c.minxyzct>=2 and matg:FilterCount(s.gryphonhoptfilter,nil)<2 end)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--(3)ATK Up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
	--(4)Treat as "Noct Frost" monster
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_ADD_SETCODE)	
	e3:SetValue(0x353)
	c:RegisterEffect(e3)
	--(5)Equip this card from GY or banishment
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(s.eqcon)
	e4:SetTarget(s.eqtg)
	e4:SetOperation(s.eqop)
	c:RegisterEffect(e4)
end
--(1)Equip only to a WATER monster
function s.eqfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end
--(2)Treat Equipped monster as 2 materials for Xyz Summon
function s.gryphonhoptfilter(c)
	return c:IsCode(id) and c:IsHasEffect(EFFECT_DOUBLE_XYZ_MATERIAL)
end
--(3)ATK Up
function s.value(e,c)
	local ec=e:GetHandler():GetEquipTarget()
	if ec:IsType(TYPE_XYZ) then
		return c:GetOverlayCount()*500
	else
		return 0
	end
end
--(5)Equip this card from GY or banishment
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x353) and c:IsControler(tp)
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.rcyfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_XYZ)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.rcyfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rcyfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.rcyfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
		Duel.Equip(tp,c,tc)
	end
end