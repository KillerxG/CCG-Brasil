-- Prysm Beast Fenrir
-- ID 222000020 | Setcode 0x100b
local s,id=GetID()
local SET_PRYSM=0x100b
s.listed_series={SET_PRYSM}

function s.initial_effect(c)
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_AQUA),3,2)
	c:EnableReviveLimit()

	-- If a monster with a Level is Special Summoned (either player)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

function s.sendfilter(c,lv)
	return c:IsMonster() and c:IsRace(RACE_AQUA) and c:IsLevel(lv)
		and c:IsAbleToGrave()
end
function s.summonedfilter(c,tp)
	return c:IsMonster() and c:GetLevel()>0
		and Duel.IsExistingMatchingCard(s.sendfilter,tp,LOCATION_DECK,0,1,nil,c:GetLevel())
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.summonedfilter,1,nil,tp)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.summonedfilter,1,nil,tp) end
	local g=eg:Filter(s.summonedfilter,nil,tp)
	local tc=g:GetFirst()
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		tc=g:Select(tp,1,1,nil):GetFirst()
	end
	if not tc then return end
	e:SetLabel(tc:GetLevel())
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_SZONE)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_PRYSM) and c:IsOriginalType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	if lv<=0 then return end
	if not Duel.IsExistingMatchingCard(s.sendfilter,tp,LOCATION_DECK,0,1,nil,lv) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.sendfilter,tp,LOCATION_DECK,0,1,1,nil,lv)
	if #g==0 or Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if not Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_SZONE,0,1,nil,e,tp) then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_SZONE,0,1,1,nil,e,tp)
	if #sg>0 then Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP) end
end
