--Oceanic Storm Cidadel: Dawn
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--(1)Reduce Level in hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER))
	e1:SetValue(-1)
	c:RegisterEffect(e1)
	--(2)Activate "Oceanic Storm Cidadel: Nightfall"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) and Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_DECK,0,1,nil,tp) end)
	e2:SetOperation(s.acop)
	c:RegisterEffect(e2)
	--(3)Also always "Umi"
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_ADD_CODE)
	e3:SetValue(22702055)
	c:RegisterEffect(e3)
	--(3)Avoid battle damage
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(s.condition)
	e4:SetTarget(s.efilter)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	--(4)Reduce effect damage
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CHANGE_DAMAGE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(1,0)
	e5:SetCondition(s.condition)
	e5:SetValue(s.damval)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e6)
	--(5)Set
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,2))
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_FZONE)
	e7:SetCountLimit(1,id)
	e7:SetTarget(s.settg)
	e7:SetOperation(s.setop)
	c:RegisterEffect(e7)
end
s.listed_names={CARD_UMI}
--(2)Activate "Oceanic Storm Cidadel: Nightfall"
function s.fieldfilter(c,tp)
	return c:IsCode(777003350) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_DECK,0,1,nil,tp)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.SendtoDeck(c,nil,2,REASON_EFFECT)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.fieldfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp) then
		--Duel.SendtoDeck(c,nil,2,REASON_EFFECT)
	end
end
--(3)Avoid battle damage
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
function s.efilter(e,c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end
--(4)Reduce effect damage
function s.damval(e,re,val,r,rp,rc)
	if (r&REASON_EFFECT)~=0 then return 0 end
	return val
end
--(5)Set
function s.setfilter(c)
	return (c:IsSetCard(0x312) or c:IsCode(76823930) or c:ListsCode(CARD_UMI)) and c:IsSSetable() and not c:IsType(TYPE_FIELD)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		Duel.SSet(tp,tc)
		if tc:IsTrapCard() then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,3))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end