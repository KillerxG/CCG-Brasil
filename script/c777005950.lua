--Duality Ritual
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Send cards to the GY and Special Summon 1 DARK or LIGHT Ritual Monster 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--(2)Add this card from GY to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.SelfBanish)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)	
end
--(1)Send cards to the GY and Special Summon 1 DARK or LIGHT Ritual Monster 
function s.mmzfilter(c,tp)
    return Duel.GetMZoneCount(tp,c)>0
end
function s.spfilter1(c,e,tp,tgg)
    if not (c:IsAttribute(ATTRIBUTE_DARK|ATTRIBUTE_LIGHT) and c:IsRitualMonster() and not c:IsPublic() and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false)) then return end
    local lvl=c:GetLevel()
    return tgg:IsExists(s.mmzfilter,1,c,tp) and tgg:FilterCount(aux.TRUE,c)>=(lvl//4)
end
function s.spfilter(c,e,tp,lv,g)
	return c:IsRitualMonster() and c:IsAttribute(ATTRIBUTE_DARK|ATTRIBUTE_LIGHT) and c:IsLevelAbove(4) and c:IsLevelBelow(lv) and not c:IsPublic()
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
--(2)Add this card from GY to hand
function s.thcfilter(c,tp)
	return c:IsReason(REASON_BATTLE|REASON_EFFECT) and c:IsRitualMonster()
		and c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.thcfilter,1,nil,tp)
end
function s.thfilter(c,e)
	return c:IsRitualMonster() and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.thfilter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return #g>0 end
	local tg=aux.SelectUnselectGroup(g,e,tp,1,2,aux.dncheck,1,tp,HINTMSG_ATOHAND)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,#tg,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end