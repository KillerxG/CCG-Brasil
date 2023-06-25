--Shinigami of Moon - Carmilla
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:AddSetcodesRule(id,true,0x314)--Waifu Arch
	--(1)Sp Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--(2)Sp Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.thdescon)
	c:RegisterEffect(e3)
	--(3)Spirit Return
	local sme,soe=Spirit.AddProcedure(c,EVENT_SPSUMMON_SUCCESS)
	--Mandatory return
	sme:SetCategory(CATEGORY_TOHAND)
	sme:SetTarget(s.mrettg)
	sme:SetOperation(s.retop)
	--Optional return
	soe:SetCategory(CATEGORY_TOHAND)
	soe:SetTarget(s.orettg)
	soe:SetOperation(s.retop)	
	--(4)Search
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id+2)
	e5:SetTarget(s.target)
	e5:SetOperation(s.activate)
	c:RegisterEffect(e5)	
end
--(1)Sp Summon
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsAttribute,1,true,nil,e:GetHandler(),ATTRIBUTE_DARK) end
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsAttribute,1,1,true,nil,e:GetHandler(),ATTRIBUTE_DARK)
	Duel.Release(g,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and ((c:IsLocation(LOCATION_GRAVE) and not eg:IsContains(c)) 
		or (c:IsLocation(LOCATION_HAND))) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
--(2)Sp Summon
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		and	Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then 
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) and Duel.IsPlayerCanDraw(tp,1) then
			Duel.SetTargetPlayer(tp)
			Duel.SetTargetParam(1)
			Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
			local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
			Duel.Draw(p,d,REASON_EFFECT)
		end
	end
end
function s.thdescon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
--(3)Spirit Return
function s.cursefilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSetCard(0x304b) --and c:IsSSetable()
end
function s.mrettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Spirit.MandatoryReturnTarget(e,tp,eg,ep,ev,re,r,rp,1)
end
function s.orettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Spirit.OptionalReturnTarget(e,tp,eg,ep,ev,re,r,rp,0)  end
	Spirit.OptionalReturnTarget(e,tp,eg,ep,ev,re,r,rp,1)
	
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0
		and c:IsLocation(LOCATION_HAND) and Duel.IsExistingMatchingCard(s.cursefilter,tp,LOCATION_DECK,0,1,1,nil) and Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0 then
		local tc=Duel.SelectMatchingCard(tp,s.cursefilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
				if tc then
					Duel.MoveToField(tc,tp,1-tp,LOCATION_SZONE,POS_FACEUP,true)
				end
	end
end
--(4)Search
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x304) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.filter2(c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		local mg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE+LOCATION_HAND,0,e:GetHandler())
		if #mg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			local sg=mg:Select(tp,1,1,nil)
			Duel.Release(sg,REASON_EFFECT)			
		end
	end
end