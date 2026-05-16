--Cyberclops Factory
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x311)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
	--atkup
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x311))
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e3)
	 --Add counter
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetRange(LOCATION_FZONE)
	e4:SetTarget(s.actarget)
    e4:SetOperation(s.acop)
    c:RegisterEffect(e4)
	--Special Summon From Hand
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1,id)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
end
s.listed_card_types={TYPE_GEMINI}
--atk/def up
function s.atkval(e,c)
    return Duel.GetCounter(0,1,1,0x311)*100
end
--gain counter
function s.acfilter(c,tp)
    return c:IsRace(RACE_MACHINE) and c:IsControler(tp)
end
function s.counfilter(c)
    return c:IsSetCard(0x311) and c:IsFaceup()
end
function s.acxfilter(c,e,tp)
	return c:IsType(TYPE_GEMINI) and c:IsControler(tp) --and c:IsLocation(LOCATION_GRAVE)
end
function s.actarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return  eg:IsExists(s.acxfilter,1,nil,e,tp) end
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
    local d2=eg:FilterCount(s.acfilter,nil,tp)*1
local g=Duel.GetMatchingGroup(s.counfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		tc:AddCounter(0x311,d2)
    Duel.RDComplete()
end
end
--special summon
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_GEMINI) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:HasLevel() and Duel.IsCanRemoveCounter(tp,1,0,0x311,c:GetLevel(),REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	local lvt={}
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local tlv=tc:GetLevel()
		lvt[tlv]=tlv
	end
	local pc=1
	for i=1,12 do
		if lvt[i] then lvt[i]=nil lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	Duel.RemoveCounter(tp,1,0,0x311,lv,REASON_COST)
	e:SetLabel(lv)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.sfilter(c,lv,e,tp)
	return c:IsType(TYPE_GEMINI) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:GetLevel()==lv
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil,lv,e,tp)
	if g:GetCount()>0 then
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
end