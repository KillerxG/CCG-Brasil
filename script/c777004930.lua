--Everlasting Soul Encyclopedia
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--(1)Place up to 2 "Majin Reaper" Continuous Traps
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.plcost)
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)
	--(2)Return 2 cards on the field, including 1 Continuous Trap card, to the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(aux.exccon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.retthtg)
	e2:SetOperation(s.retthop)
	c:RegisterEffect(e2)
end
--(1)Place up to 2 "Majin Reaper" Continuous Traps 
function s.plrevfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsLevel(10)
end
function s.plcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.plrevfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.plrevfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	Duel.ConfirmCards(1-tp,g)
	e:SetLabel(g:IsCode(777004920) and 1 or 0)
end
function s.plfilter(c)
	return c:IsSetCard(0x258) and c:IsContinuousTrap() and not c:IsForbidden()
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil) end
		if e:GetLabel()==0 then
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(2000)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,2000)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,eg,1,0,0)
		end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	local g=Duel.GetMatchingGroup(s.plfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil)
	if #g==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,math.min(ft,2),aux.dncheck,1,tp,HINTMSG_TOFIELD)
	if #sg==0 then return end
	for tc in sg:Iter() do
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
	if e:GetLabel()==0 then
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Damage(p,d,REASON_EFFECT)
	end
	
end
--(2)Return 2 cards on the field, including 1 Continuous Trap card, to the hand
function s.argstrapfilter(c,tp)
	return c:IsContinuousTrap() and c:IsControler(tp) and c:IsFaceup()
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(s.argstrapfilter,1,nil,tp)
end
function s.retthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local rg=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
	if chk==0 then return #rg>=2 and aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,0) end
	local g=aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,1,tp,HINTMSG_RTOHAND)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,tp,0)
end
function s.retthop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end