--Cheat Code Creation
--Scripted by Imp
local s,id=GetID()
function s.initial_effect(c)
	--Search/Banish
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id)
	e0:SetTarget(s.tgtg)
	e0:SetOperation(s.tgop)
	c:RegisterEffect(e0)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
--Search/Banish
function s.tgfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_CYBERSE) and (c:IsAbleToHand() or c:IsAbleToRemove())
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
	local g=Duel.GetMatchingGroup(Card.IsType,0,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_LINK)
	local ct=g:GetSum(Card.GetLink)+2
		return ct>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=ct
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsType,0,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_LINK)
	local ct=g:GetSum(Card.GetLink)+2
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	Duel.ConfirmDecktop(tp,ct)
	local g=Duel.GetDecktopGroup(tp,ct):Filter(s.tgfilter,nil,e,tp)
    if #g>0 then 
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local sg=g:Select(tp,1,1,nil)
	Duel.DisableShuffleCheck()
	if sg:GetFirst():IsAbleToHand() and (not sg:GetFirst():IsAbleToRemove() or Duel.SelectYesNo(tp,aux.Stringid(id,3))) then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleHand(tp)
		else
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
    end
	ct=ct-1
	if ct>0 then
		Duel.MoveToDeckBottom(ct,tp)
		Duel.SortDeckbottom(tp,tp,ct)
	end
end
--Special Summon
function s.cfilter(c)
	return c:IsSetCard(0x352) and c:IsMonster() and c:IsAbleToRemoveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	g:AddCard(e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,666199995,0x352,TYPES_TOKEN,800,600,2,RACE_CYBERSE,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,666199995,0x352,TYPES_TOKEN,800,600,2,RACE_CYBERSE,ATTRIBUTE_DARK) then
		local token=Duel.CreateToken(tp,666199995)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end