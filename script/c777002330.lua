--Jellycrew Devil
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--(1)Destroy Extra
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.atkcost)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--(2)ATK Down
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
end
s.listed_names={777002340}
--(1)Destroy Extra
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER)
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,c) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,c)
		Duel.Release(g,REASON_COST)	
end
function s.filter(c)
	return c:IsAbleToGrave()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if chk==0 then return g:FilterCount(s.filter,nil)>=2 end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsType,1-tp,LOCATION_EXTRA+TYPE_PENDULUM,0,nil,TYPE_EXTRA+TYPE_PENDULUM)
	if #g<2 then return end
	local rg=g:RandomSelect(tp,2)
	if Duel.SendtoGrave(rg,REASON_EFFECT) then		
		
	end	
end
--(2)ATK Down
function s.atkfilter(c)
	return c:IsFaceup() and c:IsRitualMonster()
end
function s.atkval(e,c)
	local tatk=0
	local g=Duel.GetMatchingGroup(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		tatk=tatk+tc:GetDefense()/2
		tc=g:GetNext()
	end
	return -tatk
end
