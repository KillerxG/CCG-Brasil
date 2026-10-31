-- Prysm Beast - Call of the Aurora
-- ID 222000120 | Normal Spell | Prysm Beast setcode 0x100b
local s,id=GetID()
local SET_PRYSM=0x100b

-- Set this to the actual ID of "Aurora Dragon" in your .cdb.
-- The second effect cannot find the intended monster until this is set.
local AURORA_DRAGON_ID=222000000

s.listed_series={SET_PRYSM}

function s.initial_effect(c)
	-- Reveal 3 Aqua monsters with different names; random one to hand,
	-- Special Summon one of the remaining two, and send the last to GY.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)

	-- GY: banish this card; Xyz Summon Aurora Dragon from the Extra Deck.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,0}) -- shared HOPT with first effect
	e2:SetCost(s.xyzcost)
	e2:SetTarget(s.xyztg)
	e2:SetOperation(s.xyzop)
	c:RegisterEffect(e2)
end

function s.aquafilter(c,e,tp)
	return c:IsRace(RACE_AQUA) and c:IsMonster()
		and c:IsAbleToHand() and c:IsAbleToGrave()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.namescheck(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)==#sg
end

function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		local g=Duel.GetMatchingGroup(s.aquafilter,tp,LOCATION_DECK,0,nil,e,tp)
		return aux.SelectUnselectGroup(g,e,tp,3,3,s.namescheck,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.actop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.GetMatchingGroup(s.aquafilter,tp,LOCATION_DECK,0,nil,e,tp)
	local selected=aux.SelectUnselectGroup(g,e,tp,3,3,s.namescheck,1,tp,HINTMSG_CONFIRM)
	if not selected or #selected~=3 then return end
	Duel.ConfirmCards(1-tp,selected)
	local all={}
	for tc in aux.Next(selected) do all[#all+1]=tc end
	local random_index=Duel.GetRandomNumber(1,3)
	local handcard=all[random_index]
	local remain=Group.CreateGroup()
	for i,tc in ipairs(all) do
		if i~=random_index then remain:AddCard(tc) end
	end
	if Duel.SendtoHand(handcard,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,handcard)
	end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
		Duel.SendtoGrave(remain,REASON_EFFECT)
		return
	end
	local can_sp=remain:Filter(function(c)
		return c:IsLocation(LOCATION_DECK)
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end,nil)
	if #can_sp==0 then
		Duel.SendtoGrave(remain,REASON_EFFECT)
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sp=can_sp:Select(tp,1,1,nil)
	local gy=remain:Clone()
	gy:Sub(sp)
	if #sp>0 then Duel.SpecialSummon(sp,0,tp,tp,false,false,POS_FACEUP) end
	if #gy>0 then Duel.SendtoGrave(gy,REASON_EFFECT) end
end

function s.banishfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_PRYSM) and c:IsFaceup()
end

function s.aurorafilter(c,e,tp)
	return AURORA_DRAGON_ID~=0 and c:IsCode(AURORA_DRAGON_ID)
		and c:IsType(TYPE_XYZ)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end

function s.xyzcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.banishfilter,tp,LOCATION_REMOVED,0,2,nil)
			and Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_XYZ)>0
			and Duel.IsExistingMatchingCard(s.aurorafilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_XYZ)<=0 then return end
	local extra=Duel.GetMatchingGroup(s.aurorafilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if #extra==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local xyz=extra:Select(tp,1,1,nil):GetFirst()
	if not xyz then return end
	if Duel.SpecialSummon(xyz,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)==0 then return end
	xyz:CompleteProcedure()
	local banished=Duel.GetMatchingGroup(s.banishfilter,tp,LOCATION_REMOVED,0,nil)
	if #banished==0 then return end
	-- "any number" includes 0; selecting no cards leaves no materials.
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local mats=banished:Select(tp,0,#banished,nil)
	if #mats>0 then Duel.Overlay(xyz,mats) end
end
