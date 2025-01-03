--Cheat Code Kuraiown
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMixRep(c,true,true,aux.FilterBoolFunctionEx(s.ffilter),2,2,666200010)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,nil,nil,nil,nil,false)
    --(1)Banish itself it it leaves the field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e1:SetCondition(function(e) return e:GetHandler():IsFaceup() end)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)
	--(2)ATK Up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--(3)Treat equipped monster as a "Cheat Code" monster
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_ADD_SETCODE)
	e3:SetValue(0x352)
	c:RegisterEffect(e3)
	--(4)Change Name
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_CHANGE_CODE)
	e4:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e4:SetValue(666200010)
	c:RegisterEffect(e4)
	--(5)Multi attack
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_EXTRA_ATTACK)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.atkcon)
	e5:SetValue(s.atk2val)
	c:RegisterEffect(e5)
	--(6)Change die result
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_TOSS_DICE_NEGATE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetOperation(s.diceop)
	c:RegisterEffect(e6)
	--(7)Special Summon this card from Banishment
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,1))
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetCategory(CATEGORY_EQUIP+CATEGORY_SPECIAL_SUMMON)
	e7:SetRange(LOCATION_REMOVED)
	e7:SetCountLimit(1,id)
	e7:SetTarget(s.eqtg)
	e7:SetOperation(s.eqop)
	c:RegisterEffect(e7)
	aux.AddEREquipLimit(c,nil,s.eqval,Card.EquipByEffectAndLimitRegister,e7)
	--(7.1)Special Summon this card from Szone
	local e8=e7:Clone()
	e8:SetRange(LOCATION_SZONE)
	e8:SetTarget(s.eq2tg)
	e8:SetOperation(s.eq2op)
	c:RegisterEffect(e8)
	--(8)Equip
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,0))
	e9:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e9:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e9:SetCode(EVENT_SPSUMMON_SUCCESS)
	e9:SetCountLimit(1,id+1)
	e9:SetCondition(s.spcon)
	e9:SetTarget(s.sptg)
	e9:SetOperation(s.spop)
	c:RegisterEffect(e9)
	local e10=Effect.CreateEffect(c)
	e10:SetDescription(aux.Stringid(id,0))
	e10:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e10:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e10:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e10:SetCode(EVENT_EQUIP)
	e10:SetCountLimit(1,id+1)
	e10:SetTarget(s.sptg)
	e10:SetOperation(s.spop)
	c:RegisterEffect(e10)
end
--Fusion Procedure
function s.ffilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_CYBERSE,fc,sumtype,tp) and c:IsLinkAbove(2)
end
function s.matfilter(c,tp)
	return c:IsAbleToDeckOrExtraAsCost() and c:IsFaceup()
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
end
function s.contactop(g)
	Duel.SendtoDeck(g,nil,0,REASON_COST+REASON_MATERIAL)
end
--(2)ATK Up
function s.atkval(e,c)
	return e:GetHandler():GetEquipGroup():GetSum(Card.GetAttack)/2
end
--(5)Multi attack
function s.atkcon(e)
	return e:GetHandler():GetEquipCount()>0
end
function s.atk2val(e)
	return e:GetHandler():GetEquipCount()
end
--(6)Change die result
function s.diceop(e,tp,eg,ep,ev,re,r,rp)
	local cc=Duel.GetCurrentChain()
	local cid=Duel.GetChainInfo(cc,CHAININFO_CHAIN_ID)
	if s[0]~=cid  and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			local dc={Duel.GetDiceResult()}
			local ac=1
			local ct=(ev&0xff)+(ev>>16)
			Duel.Hint(HINT_CARD,0,id)
			if ct>1 then
				local val,idx=Duel.AnnounceNumber(tp,table.unpack(dc,1,ct))
				ac=idx+1
			end
			if dc[ac]==1 or dc[ac]==3 or dc[ac]==5 then	dc[ac]=Duel.AnnounceNumber(tp,1,2,3,4,5,6)
			else dc[ac]=Duel.AnnounceNumber(tp,1,2,3,4,5,6) end
		Duel.SetDiceResult(table.unpack(dc))
		s[0]=cid
	end
end
--(7)Special Summon this card from Banishment
function s.eqfilter(c)
	return c:IsFaceup() and c:IsLinkMonster() and c:IsRace(RACE_CYBERSE)
end
function s.eqval(ec,c,tp)
	return ec:IsControler(tp) and ec:IsFaceup() and ec:IsLinkMonster() and ec:IsRace(RACE_CYBERSE) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) then
		c:EquipByEffectAndLimitRegister(e,tp,tc)
	end
end
--(7.1)Special Summon this card from Szone
function s.eq2tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.eq2op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) then
		c:EquipByEffectAndLimitRegister(e,tp,tc)
	end
end
--(8)Equip
function s.spcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsMonsterCard() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then 
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
