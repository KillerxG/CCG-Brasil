--Rockslash Stone Crusher
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Send the top 3 cards from the Deck to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--(2)Can be activated from the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.actcon)
	c:RegisterEffect(e2)
end
--(1)Send the top 3 cards from the Deck to the GY
function s.filter(c)
	return c:IsSetCard(0x309) and c:IsMonster()
end
function s.filter2(c)
	return c:IsMonster() or c:IsSpellTrap()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,3,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardDeck(tp,3,REASON_EFFECT)==0 then return end
	local og=Duel.GetOperatedGroup()
	local ct=og:Filter(s.filter,nil):GetCount()
	local g=Duel.GetMatchingGroup(s.filter2,tp,0,LOCATION_ONFIELD,nil)
	if ct>0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=g:Select(tp,1,math.min(#g,ct),nil)
		Duel.HintSelection(sg,true)
		if #sg>0 then
			Duel.BreakEffect()
			local dam=Duel.Destroy(sg,REASON_EFFECT)
			if dam>0 then
				Duel.BreakEffect()
				Duel.Damage(1-tp,dam*800,REASON_EFFECT)
			end
		end
	end
end
--(2)Can be activated from the hand
function s.actfilter(c)
	return c:IsFaceup() and c:IsCode(777002010)
end
function s.actcon(e)
	return Duel.IsExistingMatchingCard(s.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end