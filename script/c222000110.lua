-- Prysm Beast - Aurora's Sacred Barrier
-- 222000110 | Setcode 0x100b | Normal Trap
local s,id=GetID()
local SET_PRYSM=0x100b
s.listed_series={SET_PRYSM}

function s.initial_effect(c)
	-- Can activate this Trap directly from the hand while controlling
	-- 2+ "Prysm Beast" cards in the Spell & Trap Zone.
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(s.handcon)
	c:RegisterEffect(e0)

	-- When an opponent's monster declares an attack:
	-- Send 1 Prysm Beast card from your S/T Zone to GY as cost;
	-- destroy all opponent Attack Position monsters, then optionally search.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.atkcon)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.prysm(c)
	return c:IsSetCard(SET_PRYSM)
end
function s.handcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.prysm,tp,LOCATION_SZONE,0,2,nil)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	return a and a:IsControler(1-tp)
end
function s.costfilter(c)
	return c:IsSetCard(SET_PRYSM) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_SZONE,0,1,e:GetHandler())
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_SZONE,0,1,1,e:GetHandler())
	Duel.SendtoGrave(g,REASON_COST)
end
function s.destroyfilter(c)
	return c:IsFaceup() and c:IsAttackPos()
end
function s.searchfilter(c)
	return c:IsSetCard(SET_PRYSM) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.destroyfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,1-tp,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.destroyfilter,tp,0,LOCATION_MZONE,nil)
	if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
	if not Duel.IsExistingMatchingCard(s.searchfilter,tp,LOCATION_DECK,0,1,nil) then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=Duel.SelectMatchingCard(tp,s.searchfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #sg>0 and Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,sg)
	end
end
