--NPC Hack
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--(1)Activate
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)
end
--(1)Activate
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--Restart
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetRange(0x5f)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp) return Duel.GetTurnCount()==1 end)
	e1:SetOperation(s.restartop)
	Duel.RegisterEffect(e1,tp)
	--Destiny Draw
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PREDRAW)
	e2:SetRange(0x5f)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_DECK,0,1,nil,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) and Duel.GetLP(tp)<=3000 end)
	e2:SetOperation(s.excavop)
	Duel.RegisterEffect(e2,tp)
	--Swap cards
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(0x5f)
	e3:SetCountLimit(1)
	e3:SetCondition(s.thcon)
	e3:SetOperation(s.thop)
	Duel.RegisterEffect(e3,tp)
end
--Restart
function s.restartop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_CARD,tp,id)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if #g==0 then return end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	Duel.ShuffleDeck(tp)
	Duel.BreakEffect()
	Duel.Draw(tp,#g,REASON_EFFECT)
end
--Destiny Draw
function s.excavop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	Duel.Hint(HINT_CARD,tp,id)
	local tc=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_DECK,0,1,1,nil,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP):GetFirst()
	if tc then
		Duel.ShuffleDeck(tp)
		Duel.MoveSequence(tc,0)
		Duel.ConfirmDecktop(tp,1)
	end
end
--Swap cards
function s.thfilter(c)
	return c:IsAbleToHand()
end
function s.thcon(e)
	local tp=e:GetHandlerPlayer()
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local f=Duel.SelectMatchingCard(tp,Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoDeck(f,nil,SEQ_DECKSHUFFLE,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.drfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		--Duel.ConfirmCards(1-tp,g)
	end
end