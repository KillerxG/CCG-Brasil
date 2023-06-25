--Phantom Gunners Intense Battle
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--(1)Destroy Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--(2)Mill when destroyed
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+1)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.mlcon)
	e3:SetTarget(s.mltg)
	e3:SetOperation(s.mlop)
	c:RegisterEffect(e3)
end
--(1)Destroy Deck
function s.filter(c)
	return c:IsSetCard(0x302) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return ct>0 and Duel.IsPlayerCanDiscardDeck(1-tp,ct) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,ct)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local ct=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_MZONE,0,nil)
	if ct>0 then
		Duel.DiscardDeck(1-tp,ct,REASON_EFFECT)
	end
end
--(2)Mill when destroyed
function s.filter(c)
	return c:IsSetCard(0x302) and c:IsType(TYPE_MONSTER)
end
function s.mlcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousControler(tp)
end
function s.mltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil):GetClassCount(Card.GetCode)
	if chk==0 then return ct>0 and Duel.IsPlayerCanDiscardDeck(1-tp,ct) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,ct)
end
function s.mlop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil):GetClassCount(Card.GetCode)
	if ct>0 and Duel.IsPlayerCanDiscardDeck(1-tp,ct) then 
		Duel.DiscardDeck(1-tp,ct,REASON_EFFECT)
	end
end