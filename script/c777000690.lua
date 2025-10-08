--Draconic Witch - Zero
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --(1)Special Summon itself from the hand if a Dragon monster is banished
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_REMOVE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--(2)Shuffle 1 banished card into the Deck, and banish or negate a monster's effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_REMOVE+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)	
	--(3)Negate banishment
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.discon)
	e3:SetOperation(function(e,tp,eg,ep,ev) Duel.NegateEffect(ev) end)
	c:RegisterEffect(e3)
end
--(1)Special Summon itself from the hand if a Dragon monster is banished
function s.spcfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsRace(RACE_DRAGON) and not c:IsType(TYPE_TOKEN)
		and (not c:IsPreviousLocation(LOCATION_ONFIELD) or c:GetPreviousRaceOnField()&RACE_DRAGON>0)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spcfilter,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
--(2)Shuffle 1 banished card into the Deck, and banish or negate a monster's effect
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsMonsterEffect()
end
function s.drfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAbleToDeck()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.drfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.drfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tc=Duel.SelectTarget(tp,s.drfilter,tp,LOCATION_REMOVED,0,1,1,nil):GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tc,1,0,0)
	local rc=re:GetHandler()
	if tc:GetOwner()==tp and rc:IsAbleToRemove() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,tp,0)
	elseif tc:GetOwner()==1-tp then
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,eg,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK|LOCATION_EXTRA)) then return end
	if tc:IsLocation(LOCATION_DECK) and re:GetHandler():IsRelateToEffect(re) then
		Duel.BreakEffect()
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	elseif tc:IsLocation(LOCATION_EXTRA) then
		Duel.BreakEffect()
		Duel.NegateEffect(ev)
	end
end
--(3)Negate banishment
function s.disfilter(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(777000680)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return rp==1-tp and loc==LOCATION_REMOVED and Duel.IsExistingMatchingCard(s.disfilter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,nil)
end