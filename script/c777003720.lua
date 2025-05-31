--West Royal Dragon Throne
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Send cards to the GY and Special Summon 1 Dragon or Fiend Ritual Monster 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--(2)Grant effect to "West Royal Dragon - Irya"
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--(2.1)Grant effect to "West Royal Dragon - Irya"
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.indval)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(s.eftg)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
end
s.listed_names={777003710,id}
--(1)Send cards to the GY and Special Summon 1 Dragon or Fiend Ritual Monster 
function s.mmzfilter(c,tp)
    return Duel.GetMZoneCount(tp,c)>0
end
function s.spfilter1(c,e,tp,tgg)
    if not (c:IsRace(RACE_FIEND|RACE_DRAGON) and c:IsRitualMonster() and not c:IsPublic() and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false)) then return end
    local lvl=c:GetLevel()
    return tgg:IsExists(s.mmzfilter,1,c,tp) and tgg:FilterCount(aux.TRUE,c)>=(lvl//4)
end
function s.spfilter(c,e,tp,lv,g)
	return c:IsRitualMonster() and c:IsRace(RACE_FIEND|RACE_DRAGON) and c:IsLevelAbove(4) and c:IsLevelBelow(lv) and not c:IsPublic()
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false) 
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local tgg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_ONFIELD|LOCATION_HAND,0,e:GetHandler())
        return Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp,tgg)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_ONFIELD|LOCATION_HAND)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.rescon(fusc)
	return function(sg,e,tp,mg)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.sinfilter,tp,LOCATION_ONFIELD|LOCATION_HAND,0,e:GetHandler())
	if #sg<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,#sg*4+3,sg):GetFirst()
	sg:RemoveCard(tc)
	if not tc then return end
	Duel.ConfirmCards(1-tp,tc)
	local ct=tc:GetLevel()//4
	local ssg=aux.SelectUnselectGroup(sg,e,tp,ct,ct,s.rescon(tc),1,tp,HINTMSG_TOGRAVE)
	if #ssg==0 then return end
	local fdg=ssg:Filter(aux.AND(Card.IsFacedown,Card.IsOnField),nil)	
	if #fdg>0 then
		Duel.ConfirmCards(1-tp,fdg)
	end
	if Duel.SendtoGrave(ssg,REASON_EFFECT)>0 and ssg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		tc:SetMaterial(nil)
		Duel.BreakEffect()
		if Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)==0 then return end
		tc:CompleteProcedure()
	end
end
--(2)Grant effect to "West Royal Dragon - Irya"
function s.eftg(e,c)
	return c:IsType(TYPE_EFFECT) and c:IsCode(777003710)
end
function s.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end