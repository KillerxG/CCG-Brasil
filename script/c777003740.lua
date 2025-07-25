--West Royal Dragon Instructions
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
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_REFLECT_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetValue(s.refcon)
	c:RegisterEffect(e2)
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
										if Duel.SpecialSummon(sg,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP) and sg:IsRace(RACE_DRAGON) then 
										local e1=Effect.CreateEffect(c)
										e1:SetType(EFFECT_TYPE_SINGLE)
										e1:SetCode(EFFECT_UPDATE_ATTACK)
										e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
										e1:SetValue(500)
										e1:SetReset(RESET_EVENT+RESETS_STANDARD)
										sg:RegisterEffect(e1)
										end	
									end
									sg:CompleteProcedure()
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
function s.refcon(e,re,val,r,rp,rc)
	return (r&REASON_BATTLE)~=0
end
