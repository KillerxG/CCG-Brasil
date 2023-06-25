--Phantom Gunners Final Battle
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--(1)Deck Out
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(s.pctop)
	c:RegisterEffect(e2)
	--(2)Set Soul Levy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
--(1)Deck Out
function s.pctfilter(c,tp)
  return c:IsFaceup() and c:IsSetCard(0x302) and c:GetSummonPlayer()==tp
end
function s.pctop(e,tp,eg,ep,ev,re,r,rp)
  local ct=eg:FilterCount(s.pctfilter,nil,tp)
  if ct>0 and Duel.IsPlayerCanDiscardDeck(1-tp,2)then
    Duel.Hint(HINT_CARD,0,id)
	Duel.DiscardDeck(1-tp,2,REASON_EFFECT)
  end
end
--(2)Set Soul Levy
function s.filter(c)
	return c:IsCode(87844926) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.SSet(tp,tc)
	end
end