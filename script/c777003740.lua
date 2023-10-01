--Weast Royal Dragon Calling
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Search, then you can Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--(2)Grant effect to "Weast Royal Dragon - Irya"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.sendcon)
	e2:SetTarget(s.sendtg)
	e2:SetOperation(s.sendop)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
function s.filter(c)
	return c:IsSetCard(0x288) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.desfilter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsReleasableByEffect(e)
end
function s.ritfilt2(c)
	return c:IsRitualMonster() 
end
function s.fusfilter(c,e,tp)
	return c:IsRitualMonster() and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		if Duel.SendtoHand(g,nil,REASON_EFFECT) then
			Duel.ConfirmCards(1-tp,g)
			if c:IsRelateToEffect(e) and Duel.IsExistingMatchingCard(s.ritfilt2,tp,LOCATION_GRAVE,0,1,nil) 
				and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_MONSTER),tp,LOCATION_MZONE,0,1,e:GetHandler()) 
					and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				local dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,0,nil,e)
				local spg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
					if #dg>0 and #spg>0 then
						Duel.BreakEffect()
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
						local tc=dg:Select(tp,1,1,nil)
						Duel.HintSelection(tc)
							if Duel.Release(tc,REASON_EFFECT)>0 then
								Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
								local sg=spg:Select(tp,1,1,nil):GetFirst()
									if sg then
										if Duel.SpecialSummon(sg,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP) and sg:IsCode(777003710) then 
										local e1=Effect.CreateEffect(c)
										e1:SetType(EFFECT_TYPE_SINGLE)
										e1:SetCode(EFFECT_UPDATE_ATTACK)
										e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
										e1:SetValue(500)
										sg:RegisterEffect(e1)
										end	
									end
							end
					end
			end
		end
	end
end
--(2)Grant effect to "Weast Royal Dragon - Irya"
function s.eftg(e,c)
	return c:IsType(TYPE_EFFECT) and c:IsCode(777003710)
end
function s.sendcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker()==e:GetHandler()
end
function s.sendtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0,LOCATION_ONFIELD)
end
function s.sendop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	Duel.Destroy(g,REASON_EFFECT)
end

