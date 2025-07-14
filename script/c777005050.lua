--Moon Blessing
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--(1)Ritual Summon
	local e1=Ritual.CreateProc(c,RITPROC_GREATER,aux.FilterBoolFunction(Card.IsRace,RACE_INSECT),nil,nil,s.extrafil,nil,aux.FilterBoolFunction(Card.IsType,TYPE_MONSTER))
	local tg=e1:GetTarget()
	e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk,...)
					if chk==0 then
						if Duel.IsExistingMatchingCard(aux.FaceupFilter(s.condfilter),tp,LOCATION_MZONE,0,1,nil) then
							e:SetLabel(1)
						else
							e:SetLabel(0)
						end
					end
					if chk==1 and e:GetLabel()==1 then
						Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
					end
					return tg(e,tp,eg,ep,ev,re,r,rp,chk,...)
				end)
	local op=e1:GetOperation()
	e1:SetOperation(function(e,...)
						local ret=op(e,...)
						if e:GetLabel()==1 then
							e:SetLabel(0)
						end
						return ret
					end)
	c:RegisterEffect(e1)
	--(2)Special Summon 1 "Butterfly Lady - Tsukiko" monster from your GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={777005040}
function s.condfilter(c)
	return c:IsRace(RACE_INSECT) or c:IsRitualMonster()
end
function s.mfilter(c)
	return not Duel.IsPlayerAffectedByEffect(c:GetControler(),CARD_SPIRIT_ELIMINATION)
		and (c:IsRace(RACE_INSECT) or c:IsRitualMonster()) and c:IsLevelAbove(1) and c:IsAbleToRemove()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	if e:GetLabel()==1 then
		return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil)
	end
end
--(2)Special Summon 1 "Butterfly Lady - Tsukiko" monster from your GY
function s.spfilter(c,e,tp)
	return c:IsCode(777005040) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end