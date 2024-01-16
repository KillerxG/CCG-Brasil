--Cyberclops  Enforcer
local s,id=GetID()
function s.initial_effect(c)
	Gemini.AddProcedure(c)
	c:EnableCounterPermit(0x311)
	--add counter
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_COUNTER+CATEGORY_SPECIAL_SUMMON)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id)
	e0:SetRange(LOCATION_HAND)
	e0:SetCost(s.cost)
	e0:SetTarget(s.target)
	e0:SetOperation(s.operation)
	c:RegisterEffect(e0)
    --Destroy and get counters
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(Gemini.EffectStatusCondition)
    e1:SetOperation(s.op)
    c:RegisterEffect(e1)
	--Special then equip
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(Gemini.EffectStatusCondition)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptarget)
	e2:SetOperation(s.spactivate)
	c:RegisterEffect(e2)
end
--add counter
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDestructable() end
	Duel.Destroy(c,REASON_COST)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x311) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsCanAddCounter(0x311,4) and chkc:IsLocation(LOCATION_DECK) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:AddCounter(0x311,4)
	end
-- destroy and get counters.
function s.desfilter(c)
    return c:IsSetCard(0x311) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.op(e,tp,eg,ep,ev,re,r,rp,chk)
    if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
    local g=Duel.GetDecktopGroup(tp,3)
    Duel.ConfirmCards(tp,g)
    if g:IsExists(s.desfilter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=g:FilterSelect(tp,s.desfilter,1,1,nil)
        if Duel.Destroy(sg,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE)
		local lv=og:GetFirst():GetLevel()
				e:GetHandler():AddCounter(0x311,lv)
	Duel.ShuffleDeck(tp)
    else Duel.ShuffleDeck(tp) end
end
end
--Special then equip
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x311,2,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,0x311,2,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x311) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.eqfilter(c)
    return c:IsType(TYPE_EQUIP) and c:IsSetCard(0x311b)
end
function s.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and 
		Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spactivate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) then
	local tc=g:GetFirst()
	        local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK,0,1,1,nil,tc,tp)
        if #g>0 then
		            Duel.Equip(tp,g:GetFirst(),tc)
	end
end
end