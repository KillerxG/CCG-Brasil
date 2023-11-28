--SAO Alicization Arc - Asuna 
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Add "Asuna" Arch
	c:AddSetcodesRule(id,true,0x282b)
	--Synchro Material
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x282),1,1,Synchro.NonTuner(nil),1,99,s.matfilter)
	c:EnableReviveLimit()
    --(1)Activate "SAO" Field Spell
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.acfcon)
	e1:SetTarget(s.acftg)
	e1:SetOperation(s.acfop)
	c:RegisterEffect(e1)
	--(2)Prevent Target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--(3)Treat 1 "SAO" as Tuner
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetCost(s.tuncost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.activate)
	c:RegisterEffect(e3)
end
--Synchro Material
function s.matfilter(c,scard,sumtype,tp)
	return c:IsType(TYPE_MONSTER,scard,sumtype,tp) and c:IsSetCard(0x282b,scard,sumtype,tp)
end
--(1)Activate "SAO" Field Spell
function s.acfcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.GetFieldCard(tp,LOCATION_SZONE,5)==nil
end
function s.filter(c,tp)
	return c:IsSetCard(0x282) and c:IsType(TYPE_FIELD) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.acftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.acfop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
end
--(2)Prevent Target
function s.mfilter(c)
	return not c:IsSetCard(0x282)
end
function s.indcon(e)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and #mg>0 and not mg:IsExists(s.mfilter,1,nil)
end
--(3)Treat 1 "SAO" as Tuner
function s.tuncost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1297,1,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,0x1297,1,REASON_COST)
end
function s.tunfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x282) and not c:IsType(TYPE_TUNER)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tunfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tunfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.tunfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())		
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end