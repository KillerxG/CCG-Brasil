--Digital Adventurer Digitalize
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--(1)Give unaffected to your "Digital Adventurer" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--(2)Recycle
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.roll_dice=true
--(1)Give unaffected to your "Digital Adventurer" monsters unaffected to your "Digital Advent
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x298)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)	
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,0,nil)
		if #g>0 then
			Duel.BreakEffect()
			for gc in g:Iter() do
				--Your monsters are unaffected by opponent's card effects
				local e3=Effect.CreateEffect(c)
				e3:SetDescription(3110)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_IMMUNE_EFFECT)
				e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
				e3:SetRange(LOCATION_ONFIELD)
				e3:SetValue(s.efilter)
				e3:SetOwnerPlayer(tp)
				e3:SetReset(RESETS_STANDARD_PHASE_END)
				gc:RegisterEffect(e3)
			end
		end
end
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
--(2)Recycle
function s.thfilter(c)
	return c:IsFaceup() and c:IsCode(333000560)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_SZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.TossDice(tp,1)
	if d==4 or d==5 or d==6 then
		if e:GetHandler():IsRelateToEffect(e) then
			Duel.SendtoHand(e:GetHandler(),tp,REASON_EFFECT)
		end		
	end
end

