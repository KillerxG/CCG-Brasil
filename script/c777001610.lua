--Draconic War Path
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Banish
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--(2)Banish opponent's Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.rmcon)
	e2:SetCost(s.rmcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
--(1)Banish
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x300) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.destgfilter(c,tp)
	return c:IsSetCard(0x300) and c:IsFaceup()
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttackBelow,c:GetAttack()),tp,0,LOCATION_MZONE,1,nil)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.destgfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.destgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.destgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local dg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAttackBelow,g:GetFirst():GetAttack()),tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,dg,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsAttackBelow,tc:GetAttack()),tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		if Duel.Remove(g,POS_FACEUP,REASON_EFFECT) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,777000680),tp,LOCATION_ONFIELD,0,1,nil)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
				if #g>0 then
					Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
				end
		end			
	end
end
--(2)Banish opponent's Extra Deck
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x300),tp,LOCATION_MZONE,0,1,nil) and aux.exccon(e)
end
function s.costfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsLocation(LOCATION_EXTRA) and c:IsAbleToRemoveAsCost(POS_FACEUP)
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,1-tp,1)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if #g>0 then
		local sg=g:RandomSelect(tp,1)
		if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,777000680),tp,LOCATION_ONFIELD,0,1,nil) 
			and Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				local f=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
					if #f<1 then return end
						Duel.ConfirmCards(tp,f)
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
						local sf=f:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil,tp,POS_FACEDOWN)
							if #sf>0 then
								Duel.Remove(sf,POS_FACEDOWN,REASON_EFFECT)
							end
								Duel.ShuffleExtra(1-tp)
		end
	end
end

