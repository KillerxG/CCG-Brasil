-- Prysm Beast Princess
-- 222000130 | WATER/Aqua | Level 4 | Pendulum Scale 2
local s,id=GetID()
local SET_PRYSM=0x100b
s.listed_series={SET_PRYSM}

function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	-- Pendulum: replace destruction of your "Prysm Beast" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.reptg)
	e1:SetValue(s.repval)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)

	-- Monster: if a Prysm Beast Monster Card is placed in your S/T Zone,
	-- Special Summon this card from hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_MOVE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	-- Monster: return this card to hand; search a Prysm Beast monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

function s.prysmm(c)
	return c:IsMonster() and c:IsSetCard(SET_PRYSM)
end
function s.repfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
		and c:IsSetCard(SET_PRYSM) and c:IsMonster()
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT))
		and not c:IsReason(REASON_REPLACE)
end
function s.sendfilter(c)
	return c:IsSetCard(SET_PRYSM) and c:IsMonster()
		and c:IsAbleToGrave()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return eg:IsExists(s.repfilter,1,nil,tp)
			and Duel.IsExistingMatchingCard(s.sendfilter,tp,
				LOCATION_HAND|LOCATION_MZONE,0,1,e:GetHandler())
	end
	return Duel.SelectYesNo(tp,aux.Stringid(id,3))
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.sendfilter,tp,LOCATION_HAND|LOCATION_MZONE,
		0,e:GetHandler())
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:Select(tp,1,1,nil)
	if #sg>0 then Duel.SendtoGrave(sg,REASON_EFFECT|REASON_REPLACE) end
end

-- A monster CARD may be treated as a Spell when in the Spell/Trap Zone.
function s.placedfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_SZONE)
		and c:IsSetCard(SET_PRYSM) and c:IsOriginalType(TYPE_MONSTER)
		and not c:IsPreviousLocation(LOCATION_SZONE)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.placedfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.thfilter(c)
	return c:IsSetCard(SET_PRYSM) and c:IsMonster()
		and c:IsAbleToHand()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHandAsCost() end
	Duel.SendtoHand(e:GetHandler(),nil,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,
		LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
	end
end
