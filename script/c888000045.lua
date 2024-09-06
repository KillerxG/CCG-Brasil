--Oceanic Storm Fleet
--Scripted by Imp, Misaki
local s,id=GetID()
function s.initial_effect(c)
	--(1)Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--(2)Protect "Oceanic Storm"
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x312))
	e2:SetValue(s.indct)
	c:RegisterEffect(e2)
	--(3)Set "Oceanic Storm" Spell/Trap Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	--(4)Set Spell/Trap opponent GY
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.target2)
	e4:SetOperation(s.operation2)
	c:RegisterEffect(e4)
end
s.listed_series={0x312}
--(2)Protect "Oceanic Storm"
function s.indct(e,re,r,rp)
	if (r&REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else
		return 0
	end
end
--(3)Set "Oceanic Storm" Spell/Trap Deck
function s.filter(c,tp)
	return c:IsSetCard(0x312) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable() and not c:IsCode(id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
	if Duel.SSet(tp,g:GetFirst())~=0 then
    	local e1=Effect.CreateEffect(e:GetHandler())
    	e1:SetType(EFFECT_TYPE_SINGLE)
    	e1:SetCode(EFFECT_CANNOT_TRIGGER)
    	e1:SetReset(RESET_EVENT+RESETS_CANNOT_ACT+RESET_PHASE+PHASE_END)
    	g:GetFirst():RegisterEffect(e1)
    end
	Duel.ConfirmCards(1-tp,g)
end
end
--(4)Set Spell/Trap opponent GY
function s.filter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.filter2,tp,0,LOCATION_GRAVE,1,nil) end
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,0,LOCATION_GRAVE,1,1,nil)
	if g:GetCount()>0 then
		if Duel.SSet(tp,g:GetFirst())~=0 then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_TRIGGER)
        e1:SetReset(RESET_EVENT+RESETS_CANNOT_ACT+RESET_PHASE+PHASE_END)
        g:GetFirst():RegisterEffect(e1)
    end
		Duel.ConfirmCards(1-tp,g)
	end
end