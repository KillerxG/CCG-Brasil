--Ginsetsu, Great Fox
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Spirit Return
	local sme,soe=Spirit.AddProcedure(c,EVENT_SPSUMMON_SUCCESS)
	--Mandatory return
	sme:SetCategory(CATEGORY_TOHAND)
	sme:SetTarget(s.mrettg)
	sme:SetOperation(s.retop)
	--Optional return
	soe:SetCategory(CATEGORY_TOHAND)
	soe:SetTarget(s.orettg)
	soe:SetOperation(s.retop)	
	--(2)Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--(3)Change Stats
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.cptg)
	e2:SetOperation(s.cpop)
	c:RegisterEffect(e2)
end
--(1)Spirit Return
function s.mrettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Spirit.MandatoryReturnTarget(e,tp,eg,ep,ev,re,r,rp,1)
end
function s.orettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Spirit.OptionalReturnTarget(e,tp,eg,ep,ev,re,r,rp,0)  end
	Spirit.OptionalReturnTarget(e,tp,eg,ep,ev,re,r,rp,1)	
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsAbleToHand() then		
		Duel.SendtoHand(c,nil,REASON_EFFECT)			
	end
end
--(2)Special Summon
function s.atkfilter(c)
	return c:IsFaceup() and (c:GetAttack()>=1800 or c:IsAbleToHand())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.atkfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) then		
		local b1=(tc:IsFaceup() and tc:GetAttack()>=1800)
		local b2=(tc:IsFaceup() and c:IsAbleToHand())
		if chk==0 then return b1 or b2 end
		local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
			e:SetLabel(op)
			local g=(op==1 and g1 or g2)
			if e:GetLabel()==1 then
				local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(-1800)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			else
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
			end
		
	end
end
--(3)Change Stats
function s.cpfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:HasLevel() and not c:IsCode(id)
end
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cpfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.cpfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.cpfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsFaceup()) then return end
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	--Add name
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetValue(tc:GetOriginalCode())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	--Add Race
	local e2=e1:Clone()
	e2:SetCode(EFFECT_ADD_RACE)
	e2:SetValue(tc:GetRace())
	c:RegisterEffect(e2)
	--Add Attribute
	local e3=e1:Clone()
	e3:SetCode(EFFECT_ADD_ATTRIBUTE)
	e3:SetValue(tc:GetAttribute())
	c:RegisterEffect(e3)
	--Change Level
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CHANGE_LEVEL)
	e4:SetValue(tc:GetLevel())
	c:RegisterEffect(e4)
end