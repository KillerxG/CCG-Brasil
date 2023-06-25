--Draconic Witch - Zero
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:AddSetcodesRule(id,true,0x314)--Waifu Arch
    --(1)Search "Draconic"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	e1:SetLabel(0)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetLabel(0)
	c:RegisterEffect(e2)
	--(2)Increase ATK of "Draconic" monsters
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
	--(3)Type Dragon
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_ADD_RACE)
	e4:SetCondition(s.con)
	e4:SetValue(RACE_DRAGON)
	c:RegisterEffect(e4)
end
--(1)Search "Draconic"
function s.spfilter1(c,e,tp,check)
	return c:IsSetCard(0x300) and not c:IsCode(id) and c:IsAbleToHand()
		and (check==0 or Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_EXTRA,0,1,c,e,tp))
end
function s.banfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and (c:IsAbleToRemoveAsCost() or c:IsAbleToRemove()) 
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp,0)
	local b=Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp,1)
	if chk==0 then return (a or b) end
	if b and Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_EXTRA,0,1,nil) ---- banish
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local g=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_EXTRA,0,1,1,nil) ---- banish
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp,0) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,e:GetLabel()+1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT) and e:GetLabel()~=1 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.ConfirmCards(1-tp,g)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or e:GetLabel()~=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g2=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if #g2>0 then
			Duel.BreakEffect() 
			Duel.Remove(g2,POS_FACEUP,REASON_EFFECT)
		end
	end
end
--(2)Send to GY or Deck
function s.cfilter(c,tp)
	return c:IsRace(RACE_DRAGON)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.tgfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and (c:IsRace(RACE_DRAGON) or c:IsSetCard(0x300)) and (c:IsAbleToDeck() or c:IsAbleToGrave())
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,sg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)	
	else
		Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
	end
end
--(3)Type Dragon
function s.con(e)
	return e:GetHandler():IsLocation(LOCATION_GRAVE+LOCATION_MZONE)
end