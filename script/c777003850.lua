--West Royal Dragon - Regent Irya
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--(1)Change Name
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(777003710)
	c:RegisterEffect(e1)
	--(2)Negate column
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_ONFIELD)
	e2:SetTarget(s.coltg)
	c:RegisterEffect(e2)
	--(3)Choose that many of your opponent's occupied Main Monster Zones; your opponent must send the monsters in those zones to the GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)	return Duel.IsMainPhase()end)
	e3:SetCost(Cost.Discard(function(c) return c:IsSetCard(0x288) end,nil,1,function(e,tp) return math.min(1,Duel.GetFieldGroupCount(tp,0,LOCATION_MMZONE)) end))
	e3:SetTarget(s.gytg)
	e3:SetOperation(s.gyop)
	e3:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e3)
end
s.listed_names={777003710}
--(2)Disable
function s.coltg(e,c)
	return e:GetHandler():GetColumnGroup():IsContains(c) and c:IsFaceup()
end
--(3)Choose that many of your opponent's occupied Main Monster Zones; your opponent must send the monsters in those zones to the GY
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local mg=Duel.GetFieldGroup(tp,0,LOCATION_MMZONE)
	local filter=0
	for mc in mg:Iter() do
		filter=filter|(1<<(mc:GetSequence()+16))
	end
	local cd=e:GetChainData()
	local cost_discarded_cards_count=#cd.cost_discarded_cards
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local chosen_zones=Duel.SelectFieldZone(tp,cost_discarded_cards_count,0,LOCATION_MZONE,~filter)
	Duel.Hint(HINT_ZONE,tp,chosen_zones)
	cd.chosen_zones=chosen_zones
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local chosen_zones=e:GetChainData().chosen_zones
	local g=Duel.GetMatchingGroup(aux.IsZone,tp,0,LOCATION_MMZONE,nil,chosen_zones,tp)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_RULE,nil,1-tp)
	end
end