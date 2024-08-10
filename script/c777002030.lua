--Weast Royal Dragon - Young Irya
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --Link Summon
	Link.AddProcedure(c,nil,2,2,s.lcheck)
	--(1)Name becomes "Weast Royal Dragon - Irya" while on the field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetCondition(s.nmcon)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(777003710)
	c:RegisterEffect(e1)
	--(2)Foolish
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end
--Link Summon
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsRace,1,nil,RACE_DRAGON,lc,sumtype,tp)
end
--(1)Name becomes "Weast Royal Dragon - Irya" while on the field
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(777003710)
end
function s.nmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
end
--(2)Foolish
function s.filter(c,tp)
	return c:IsSpell() and c:IsAbleToGrave()
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,c)
end
function s.filter2(c,mc)
	return c:IsRitualMonster() and c:IsAbleToGrave() and s.isfit(c,mc)
end
function s.isfit(c,mc)
	return (mc.fit_monster and c:IsCode(table.unpack(mc.fit_monster))) or mc:ListsCode(c:GetCode())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK+LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
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