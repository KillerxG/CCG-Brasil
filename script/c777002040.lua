--Rockslash Warrior - Bernard
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --(1)Search 1 "Rockslash" card and burn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
--(1)Search 1 "Rockslash" card and burn
function s.thfilter(c)
	return c:IsSetCard(0x309) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.damfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x309)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,1,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		if Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.ShuffleDeck(tp)
			Duel.BreakEffect()
			if Duel.Draw(tp,1,REASON_EFFECT)~=0 then
			local tc=Duel.GetOperatedGroup():GetFirst()
				if tc:IsMonster() then
					Duel.ConfirmCards(1-tp,tc)
					Duel.Damage(1-tp,1000,REASON_EFFECT)
				elseif tc:IsSpellTrap() and Duel.IsExistingMatchingCard(s.damfilter,tp,LOCATION_GRAVE,0,1,nil) then
					Duel.SetTargetPlayer(1-tp)
					Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
					local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
					local d=Duel.GetMatchingGroupCount(s.damfilter,tp,LOCATION_GRAVE,0,nil)*200
					Duel.Damage(p,d,REASON_EFFECT)
				end
			end
		end
	end
end