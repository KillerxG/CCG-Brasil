--Cyberclops Avatar
local s,id=GetID()
function s.initial_effect(c)
	Gemini.AddProcedure(c)
	c:EnableCounterPermit(0x311)
		--Xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x311),8,2)
	---xyz alternative
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCode(EFFECT_TYPE_IGNITION)
	e0:SetCost(s.cost)
	e0:SetTarget(s.sptarget)
	e0:SetOperation(s.spactivate)
	c:RegisterEffect(e0)
	--material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--attach 2
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DESTROYED)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.scost)
    e2:SetTarget(s.actarget)
    e2:SetOperation(s.op)
    c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
end
--alternative summon
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x311,16,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,0x311,16,REASON_COST)
end
function s.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spactivate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local c=e:GetHandler()
		Duel.SpecialSummon(c,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
end
--add material normal summoned
function s.filter2(c)
    return c:IsSetCard(0x311b) and c:IsType(TYPE_SPELL)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,8,0,0x311)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
if e:GetHandler():AddCounter(0x311,8) then
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,2,nil)
	if #g>0 then
		Duel.Overlay(e:GetHandler(),g)
        end
    end
end
-- add material by counter
function s.scost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x311,1,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,0x311,1,REASON_COST)
end
function s.acxfilter(c,e,tp)
	return c:IsSetCard(0x311b) and c:IsControler(tp) --and c:IsLocation(LOCATION_GRAVE)
end
function s.actarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return eg:IsContains(chkc) and s.acxfilter(chkc,e,tp) end
	if chk==0 then return eg:IsExists(s.acxfilter,1,nil,e,tp) end
	local g=eg:FilterSelect(tp,s.acxfilter,1,1,nil,e,tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
 local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    local sg=g:Filter(Card.IsRelateToEffect,nil,e)
        if #sg>0 then 
            Duel.Overlay(e:GetHandler(),sg)
end
end
--sp summon, normal summon, eqp and placee counter
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.spnorfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x311) and not c:IsType(TYPE_RITUAL)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return  Duel.IsExistingMatchingCard(s.spnorfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK+LOCATION_GRAVE)
end
function s.eqfilter(c)
    return c:IsType(TYPE_EQUIP) and c:IsType(TYPE_SPELL) and c:IsSetCard(0x311b)
end
function s.acfilter(c)
    return c:IsSetCard(0x311) and c:IsFaceup()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spnorfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) then
	local tc=g:GetFirst()
	if Duel.Summon(tp,tc,true,nil)~=0 and
	 Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and
		Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and 
		Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				        local ag=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,tc,tp)
        if #ag>0 then
		local tx=ag:GetFirst()
            if Duel.Equip(tp,tx,tc) then
local og=Duel.GetMatchingGroup(s.acfilter,tp,LOCATION_MZONE,0,nil)
	local tc=og:GetFirst()
	for tc in aux.Next(og) do
		tc:AddCounter(0x311,1)
    Duel.RDComplete()
			end
	end
end
end
end
end