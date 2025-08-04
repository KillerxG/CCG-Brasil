--MonGal Witch's House
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--(1)Act limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(1)
	e2:SetCondition(s.actcon)
	c:RegisterEffect(e2)
	--(2)Inflict 200 damage to the opponent when a "MonGal" monster inflicts damage to them
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_DAMAGE)
	e3:SetCondition(s.damcon)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	--(3)Search
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
--(1)Act limit
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x257) and c:IsControler(tp)
end
function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return (a and s.cfilter(a,tp)) or (d and s.cfilter(d,tp))
end
--(2)Inflict 200 damage to the opponent when a "MonGal" monster inflicts damage to them
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	if not (ep==1-tp and Duel.GetLP(1-tp)>0) then return false end
	if r&REASON_BATTLE>0 then
		return eg:GetFirst():IsSetCard(0x257)
	end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Damage(1-tp,200,REASON_EFFECT)
end
--(3)Search
function s.eqconfilter(c)
	return c:IsMonster() and c:IsSetCard(0x257)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.eqconfilter,1,nil)
end
function s.tdfilter(c,e,tp)
	return c:IsSetCard(0x257) and c:IsMonster() and c:IsAbleToDeck()
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
function s.spfilter2(c,e,tp,code)
	return c:IsSetCard(0x257) and c:IsMonster() and not c:IsCode(code) and c:IsAbleToHand()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tc=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc then
		Duel.ConfirmCards(1-tp,tc)
		if Duel.SendtoDeck(tc,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetCode())
			if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
				
				Duel.ConfirmCards(1-tp,g)
				--Duel.SendtoHand(c,nil,REASON_EFFECT)
			end
		end
	end
end
