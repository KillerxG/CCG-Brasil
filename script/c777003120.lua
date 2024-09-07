--U.P.E. Flying Manta
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Special Summon this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--(2)Place 1 "U.P.E." monster from your Deck in S/T Zone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	--(3)Place this card in S/T Zone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+2)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetTarget(s.rectg)
	e3:SetOperation(s.recop)
	c:RegisterEffect(e3)
end
--(1)Special Summon this card
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_FIELD),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
--(2)Place 1 "U.P.E." monster from your Deck in S/T Zone
function s.filter(c)
	return c:IsSetCard(0x274) and c:IsMonster() and not c:IsForbidden()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
	end
end
--(3)Place this card in S/T Zone
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local c=e:GetHandler()
	if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		--(3.1)Becomes Continuous Spell
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
		--(3.2)Place 1 random card in your opponent's Extra Deck in your S/T Zone
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,3))
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e2:SetProperty(EFFECT_FLAG_DELAY)
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		e2:SetRange(LOCATION_SZONE)
		e2:SetCountLimit(1,id+3)
		e2:SetCondition(s.extcon)
		e2:SetTarget(s.exttg)
		e2:SetOperation(s.extop)
		c:RegisterEffect(e2)
	end
end
--(3.2)Place 1 random card in your opponent's Extra Deck in your S/T Zone
function s.cfilter(c,tp,sumt)
	return c:IsFaceup() and c:IsSetCard(0x274) and c:IsSummonType(sumt) and c:IsSummonPlayer(tp)
end
function s.extcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp,SUMMON_TYPE_FUSION)
end
function s.extfilter(c)
	return c:IsMonster() and not c:IsForbidden()
end
function s.exttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.extfilter,tp,0,LOCATION_EXTRA,1,nil) 
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
function s.extop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.extfilter,tp,0,LOCATION_EXTRA,nil)
	if #g==0 or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local tc=g:RandomSelect(tp,1):GetFirst()
	if Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		--(3.2.1)Becomes Continuous Spell
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
		--(3.2.2)Treated as "U.P.E."
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_SETCODE)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
		e2:SetRange(LOCATION_SZONE)
		e2:SetValue(0x274)
		tc:RegisterEffect(e2)
		--(3.2.3)ATK Up
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_UPDATE_ATTACK)
		e3:SetRange(LOCATION_SZONE)
		e3:SetTargetRange(LOCATION_MZONE,0)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
		e3:SetTarget(s.tg)
		e3:SetValue(s.val)
		tc:RegisterEffect(e3)
	end	
end
--(3.2.3)ATK Up
function s.tg(e,c)
	return c:IsSetCard(0x274)
end
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x274)
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_SZONE,0,nil)*200
end
