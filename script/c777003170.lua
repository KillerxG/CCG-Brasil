--Elementale Guitarrist of Fire
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Special Summon itself
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)	
	--(2)If flipped: Search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_FLIP)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--(3)Set Itself
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.poscon)
	e3:SetTarget(s.postg)
	e3:SetOperation(s.posop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	c:RegisterEffect(e4)
end
--(1)Special Summon itself
function s.cfilter(c)
	return c:IsMonster() and not c:IsPublic()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,c):GetFirst()
	local flip_chk=g:IsType(TYPE_FLIP) and 1 or 0
	local setcard_chk=g:IsSetCard(0x310) and 1 or 0
	e:SetLabel(setcard_chk,flip_chk)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local setcard_chk,flip_chk=e:GetLabel()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0
		and (flip_chk==1 or setcard_chk==1) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
	Duel.ConfirmCards(1-tp,c)
end
--(2)If flipped: Search
function s.filter2(c,e,tp,mft,sft,code)
	return not c:IsCode(code)
		and ((mft>0 and c:IsMonster() and c:IsSetCard(0x310)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE))
		or (sft>0 and c:IsSpellTrap() and c:IsSetCard(0x310) and c:IsSSetable()))
end
function s.filter(c,e,tp,mft,sft)
	return c:IsAbleToHand()
		and ((c:IsMonster() and c:IsSetCard(0x310)) or (c:IsSpellTrap() and c:IsSetCard(0x310)))
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,c,e,tp,mft,sft,c:GetCode())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local mft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local sft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_HAND) then sft=sft-1 end
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp,mft,sft) end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local mft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local sft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp,mft,sft) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local c1=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,mft,sft)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local c2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,mft,sft,c1:GetFirst():GetCode())
	if c1 and c2 then
		Duel.SendtoHand(c1,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c1)
		if c2:GetFirst():IsMonster() then
			Duel.SpecialSummon(c2,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
			Duel.ConfirmCards(1-tp,c2)
		else
			Duel.SSet(tp,c2)
		end
	end
end
--(3)Set Itself
function s.cfilter1(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(777003130)
end
function s.poscon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end