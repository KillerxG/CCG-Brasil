--Leader of Phantom Gunners - Killer
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	--(1)Special Summon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.FALSE)
	c:RegisterEffect(e0)
	--(2)Special Summon itself from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--(3)Unaffected
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(s.unfilter)
    c:RegisterEffect(e3)
	--(4)Destroy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
	--(5)Deck Out
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_DECKDES)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.ddcon)
	e5:SetTarget(s.ddtg)
	e5:SetOperation(s.ddop)
	c:RegisterEffect(e5)
end
--(2)Special Summon itself from the hand
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsMonster,Card.IsSetCard),tp,LOCATION_GRAVE+LOCATION_MZONE,0,nil,0x302)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>=3 and g:GetClassCount(Card.GetCode)>=3
end
--(3)Unaffected
function s.unfilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
--(4)Destroy
function s.filter(c,tp)
	return c:IsFaceup() and c:IsMonster() 
		and (c:GetLink()>0 or c:GetLevel()>0 or c:GetRank()>0)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tc=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,tp):GetFirst()
	local ct=tc:GetLevel()
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,ct)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,Duel.GetDecktopGroup(1-tp,ct),ct,tp,LOCATION_DECK)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		local ct=tc:GetLevel()
				if tc:IsType(TYPE_XYZ) then
					ct=tc:GetOriginalRank()
					end
						if tc:IsType(TYPE_LINK) then
							ct=tc:GetLink()
		end
		if ct>0 and Duel.IsPlayerCanDiscardDeck(1-tp,ct) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			Duel.DiscardDeck(1-tp,ct,REASON_EFFECT)
		end
	end
end
--(5)Deck Out
function s.ddcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc~=c
		and rc:IsSetCard(0x302) and rc:IsControler(tp)
end
function s.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,5)
end
function s.ddop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(1-tp,5,REASON_EFFECT)
end