--Ex Puppet Heartless Battle
--Scripted by Misaki
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x1320)
	--(1)Add Ex Puppet to Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.teop)
	c:RegisterEffect(e1)
	--(2)Add Counter (self)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_FZONE)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	--(3)Replace Counter
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_LEAVE_FIELD_P)
	e3:SetRange(LOCATION_FZONE)
	e3:SetOperation(s.addop2)
	c:RegisterEffect(e3)
end
s.counter_list={0x1320}
--(1)Add Ex Puppet to Extra Deck
function s.tefilter(c)
	return c:IsSetCard(0x320) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.teop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.tefilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoExtraP(sg,nil,REASON_EFFECT)
	end
end
--(2)Add Counter (self)
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and rp==tp then
        c:AddCounter(0x1320,1)
	end
end
--(3)Replace Counter
function s.addop2(e,tp,eg,ep,ev,re,r,rp)
	local count=0
	for c in aux.Next(eg) do
		if not c:IsCode(id) and c:IsLocation(LOCATION_ONFIELD) then
			count=count+c:GetCounter(0x1320)
		end
	end
	if count>0 then
		e:GetHandler():AddCounter(0x1320,count)
	end
end
