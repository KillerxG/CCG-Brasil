--Mizuki, Reaper of the Starry Sky
--Scripted by KillerxG
local s,id=GetID()
local RACESWSI=RACE_WARRIOR+RACE_SPELLCASTER+RACE_ILLUSION
function s.initial_effect(c)	
	--(1)Search 1 Level 6 Warrior/Spellcaster/Illusion
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfReveal)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--(2)Special Summon this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(function(e,tp,eg,ep,ev,re) return e:GetHandler():IsReason(REASON_EFFECT) and re and re:IsMonsterEffect() end)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
--(1)Search 1 Level 6 Warrior/Spellcaster/Illusion
function s.thfilter(c)
	return c:IsLevel(6) and c:IsRace(RACESWSI) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		Duel.ShuffleDeck(tp)
		Duel.BreakEffect()
		Duel.ConfirmCards(1-tp,g)
		Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
--(2)Special Summon this card
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		s.announce_filter={TYPE_MONSTER,OPCODE_ISTYPE,TYPE_EXTRA,OPCODE_ISTYPE,OPCODE_NOT,OPCODE_AND}
	local code=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
		e:SetLabel(code)
		--Change Attribute
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_CODE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
		c:RegisterEffect(e1)
		end
	end
end
