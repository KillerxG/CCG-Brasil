--Thunder Force Unicorn
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Material
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_THUNDER),4,2)
	c:EnableReviveLimit()
	--(1)Attach Material
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.tgcond)
	e1:SetTarget(s.atttg)
	e1:SetOperation(s.attop)
	c:RegisterEffect(e1)
	--(2)Set 1 "Thunder Force" S/T
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)	
end
--(1)Attach Material
function s.tgcond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.attfilter(c,e)
	return c:IsSetCard(0x301) and not c:IsImmuneToEffect(e)
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.attfilter,tp,LOCATION_DECK,0,1,nil,e)
		and e:GetHandler():IsType(TYPE_XYZ) end
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,s.attfilter,tp,LOCATION_DECK,0,1,1,nil,e)
	local tc=g:GetFirst()
	if tc then
		local og=tc:GetOverlayGroup()
		if #og>0 then
			Duel.SendtoGrave(og,REASON_RULE)
		end
		Duel.Overlay(c,Group.FromCards(tc))
	end
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 then
		Duel.ShuffleDeck(tp)
	end
end
--(2)Set 1 "Thunder Force" S/T
function s.setfilter(c)
	return c:IsSetCard(0x301) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.SSet(tp,tc)>0 and Duel.GetLP(tp)<=2000 and c:IsFaceup()
		and c:IsRelateToEffect(e) then
		Duel.BreakEffect()
	end
end