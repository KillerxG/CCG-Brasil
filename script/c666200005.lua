--Cheat Code Destruction
--Scripted by Imp
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon/Banish
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.descost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
--Special Summon/Banish
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_CYBERSE) and (c:IsCanBeSpecialSummoned(e,0,tp,false,false) or c:IsAbleToRemove())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
	local g=Duel.GetMatchingGroup(Card.IsType,0,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_LINK)
	local ct=g:GetSum(Card.GetLink)+2
		return ct>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=ct and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsType,0,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_LINK)
	local ct=g:GetSum(Card.GetLink)+2
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	Duel.ConfirmDecktop(tp,ct)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.GetDecktopGroup(tp,ct):Filter(s.spfilter,nil,e,tp)
    if #g>0 then 
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local sg=g:Select(tp,1,1,nil)
	Duel.DisableShuffleCheck()
	if sg:GetFirst():IsCanBeSpecialSummoned(e,0,tp,false,false) and (not sg:GetFirst():IsAbleToRemove() or Duel.SelectYesNo(tp,aux.Stringid(id,3))) then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
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
--Destroy
function s.cfilter(c)
	return c:IsSetCard(0x352) and c:IsMonster() and c:IsAbleToRemoveAsCost()
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	g:AddCard(e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end