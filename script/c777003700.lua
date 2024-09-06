--Royal Angel - Bianka
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,2,s.lcheck)
	Card.Alias(c,id)
	--(1)Foolish Rituals
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--(2)Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	--(3)When Switch
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_CONTROL_CHANGED)
	e3:SetCountLimit(1,id+2)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
s.listed_names={777003740,id}
--Link Summon procedure
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsRace,1,nil,RACE_FAIRY,lc,sumtype,tp)
end
--(1)Foolish Rituals
function s.tgcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.filter(c,tp)
	return c:IsRitualMonster() and c:IsAbleToGrave()
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil,c)
end
function s.filter2(c,mc)
	return c:IsRitualSpell() and c:IsAbleToGrave() and s.isfit(c,mc)
end
function s.isfit(c,mc)
	return (mc.fit_monster and c:IsCode(table.unpack(mc.fit_monster))) or mc:ListsCode(c:GetCode())
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,tp) 
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 then
		local mg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_DECK,0,nil,g:GetFirst())
		if #mg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local sg=mg:Select(tp,1,1,nil)
			g:Merge(sg)
			if Duel.SendtoGrave(g,REASON_EFFECT) then
				local c=e:GetHandler()
				Duel.GetControl(c,1-tp)
			end
			--Duel.ConfirmCards(1-tp,g)
		end
	end
end
--(2)Destroy
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return ep~=tp and eg:GetFirst():IsLocation(LOCATION_MZONE) end
	eg:GetFirst():CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
--(3)When Switch
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end 
end
function s.lkfilter(c,e,tp)
	return c:IsLink(2) and c:IsAttackBelow(1400) and c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p=e:GetHandler():GetOwner()
	local g=Duel.GetMatchingGroup(s.lkfilter,p,LOCATION_EXTRA,0,nil,e,p)
	if #g>0 and Duel.SelectYesNo(p,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(p,1,1,nil)
		Duel.BreakEffect()
		Duel.SpecialSummon(sg,SUMMON_TYPE_LINK,p,p,false,false,POS_FACEUP)		
	end
end