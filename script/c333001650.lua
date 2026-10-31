-- Mr. Friendly Fire
-- Card ID: 333001650
-- Mr. archetype setcode: 0x215b
local s,id=GetID()

function s.initial_effect(c)
	-- Activate: optional Special Summon from hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Optional alternative Normal Summon without Tributing.
	-- EFFECT_SUMMON_PROC offers a separate summon procedure, so the player
	-- can still choose the usual Tribute Summon when desired.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
	e2:SetCondition(s.ntcon)
	e2:SetTarget(aux.FieldSummonProcTg(s.nttg))
	c:RegisterEffect(e2)

	-- Send from field to GY OR banish from GY: search and possibly recover
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SEARCH|CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.fieldcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)

	local e4=e3:Clone()
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCost(s.gycost)
	c:RegisterEffect(e4)
end
local s,id=GetID()
s.listed_card_types={TYPE_GEMINI}
function s.spfilter(c,e,tp)
	return c:IsMonster() and (c:IsType(TYPE_NORMAL) or c:IsType(TYPE_GEMINI))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	end
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if not Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.mrfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x215b)
end

function s.trcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.mrfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- The alternative procedure applies only while a face-up "Mr." is controlled.
-- minc == 0 enforces the tribute-free procedure; standard Tribute Summons
-- remain available as a separate choice in the Normal Summon menu.
function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and s.trcon(e)
		and (c:IsLocation(LOCATION_MZONE)
			or Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0)
end

function s.nttg(e,c)
	return c:IsMonster() and c:IsLevelAbove(5)
		and (c:IsType(TYPE_NORMAL) or c:IsType(TYPE_GEMINI))
end

function s.fieldcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

function s.deckfilter(c)
	return c:IsSetCard(0x215b) and c:IsAbleToHand() and not c:IsCode(id)
end

function s.recoverfilter(c)
	return c:IsSetCard(0x215b) and c:IsAbleToHand() and not c:IsCode(id)
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
end

function s.awakenedfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_GEMINI)
		and c:IsType(TYPE_EFFECT) and c:IsGeminiState()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.deckfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.deckfilter,tp,LOCATION_DECK,0,1,nil) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.deckfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 or Duel.SendtoHand(g,nil,REASON_EFFECT)==0 then return end
	Duel.ConfirmCards(1-tp,g)

	-- Additional recovery only if you currently control an awakened Gemini Effect Monster
	if not Duel.IsExistingMatchingCard(s.awakenedfilter,tp,LOCATION_MZONE,0,1,nil) then return end
	if not Duel.IsExistingMatchingCard(s.recoverfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local rg=Duel.SelectMatchingCard(tp,s.recoverfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
	if #rg>0 and Duel.SendtoHand(rg,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,rg)
	end
end
