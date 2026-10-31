-- Prysm Beast Zirconia
-- ID 222000010 | Rank 4 | 2 Level 4 Aqua monsters
local s,id=GetID()
local SET_PRYSM=0x100b
s.listed_series={SET_PRYSM}

function s.initial_effect(c)
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_AQUA),4,2)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.faceupst(c)
	return c:IsFaceup()
end
function s.prysm(c)
	return c:IsSetCard(SET_PRYSM)
end
function s.gyfilter(c)
	return s.prysm(c) and c:IsAbleToGrave()
end
function s.handfilter(c)
	return s.prysm(c) and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
	return s.prysm(c) and c:IsMonster()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.selectone(tp,g,filter,...)
	local eligible=g:Filter(filter,nil,...)
	if #eligible==0 then return nil end
	local selected=eligible:Select(tp,1,1,nil)
	return selected:GetFirst()
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=math.min(3,Duel.GetFieldGroupCount(tp,LOCATION_DECK,0))
	if ct==0 then return end
	-- The Field Zone counts if the card is face-up; face-down cards do not.
	local tier=Duel.GetMatchingGroupCount(s.faceupst,tp,LOCATION_SZONE,0,nil)
	Duel.ConfirmDecktop(tp,ct)
	local excavated=Duel.GetDecktopGroup(tp,ct)
	-- All steps can resolve; each chosen excavated card can be used only once.
	if tier>=1 then
		local tc=s.selectone(tp,excavated,s.gyfilter)
		if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 then
			excavated:RemoveCard(tc)
		end
	end
	if tier>=2 then
		local tc=s.selectone(tp,excavated,s.handfilter)
		if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,tc)
			excavated:RemoveCard(tc)
		end
	end
	if tier>=3 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local tc=s.selectone(tp,excavated,s.spfilter,e,tp)
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
			excavated:RemoveCard(tc)
		end
	end
	Duel.ShuffleDeck(tp)
end
