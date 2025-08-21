--Fluorescent Dragon
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --Link Summon
	Link.AddProcedure(c,nil,2,2,s.lcheck)
	c:EnableReviveLimit()
	--(1)Foolish
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsLinkSummoned() end)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--(2)Change Name
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.nmtg)
	e2:SetOperation(s.nmop)
	c:RegisterEffect(e2)
end
--Link Summon
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsRace,1,nil,RACE_DRAGON,lc,sumtype,tp)
end
--(1)Foolish
function s.filter(c,tp)
	return c:IsRitualSpell() and c:IsAbleToGrave()
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,c)
end
function s.filter2(c,mc)
	return c:IsRitualMonster() and c:IsAbleToGrave() and s.isfit(c,mc)
end
function s.isfit(c,mc)
	return (mc.fit_monster and c:IsCode(table.unpack(mc.fit_monster))) or mc:ListsCode(c:GetCode())
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK+LOCATION_HAND)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,tp)
	if #g>0 then
		local mg=Duel.GetMatchingGroup((s.filter2),tp,LOCATION_DECK+LOCATION_HAND,0,nil,g:GetFirst())
		if #mg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local sg=mg:Select(tp,1,1,nil)
			g:Merge(sg)
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
--(2)Change Name
function s.nmfilter(c,cd)
	return c:IsFaceup()	and c:IsRitualMonster()
end
function s.nmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local cd=e:GetHandler():GetCode()
	if chkc then return chkc:IsLocation(LOCATION_REMOVED|LOCATION_GRAVE) and chkc:IsControler(tp) and s.nmfilter(chkc,cd) end
	if chk==0 then return Duel.IsExistingTarget(s.nmfilter,tp,LOCATION_REMOVED|LOCATION_GRAVE,0,1,nil,cd) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.nmfilter,tp,LOCATION_REMOVED|LOCATION_GRAVE,0,1,1,nil,cd)
end
function s.nmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc and tc:IsRelateToEffect(e) and (tc:IsLocation(LOCATION_GRAVE) or tc:IsFaceup()) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(tc:GetOriginalCode())
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
	end
end