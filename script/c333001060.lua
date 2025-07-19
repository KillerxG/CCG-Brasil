--Minomushi Carving
--Script fixed by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --(1)Ritual Summon
	Ritual.AddProcGreater({handler=c,filter=s.ritualfil,lvtype=RITPROC_GREATER,sumpos=POS_FACEUP,location=LOCATION_HAND+LOCATION_GRAVE})
    --(2)Special Summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetRange(LOCATION_HAND)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.ss_condition)
    e2:SetCost(s.ss_cost)
    e2:SetTarget(s.ss_target)
    e2:SetOperation(s.ss_operation)
    c:RegisterEffect(e2)
end
s.listed_names={46864967}
 --(1)Ritual Summon
function s.ritualfil(c)
	return c:IsRace(RACE_ROCK) and c:IsRitualMonster()
end
--(2)Special Summon
function s.ss_condition(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsRace,1,nil,RACE_ROCK)
end
function s.ss_cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsDiscardable() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.ss_filter(c,e,tp)
    return c:IsCode(46864967) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.ss_target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.ss_filter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.ss_filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.ss_filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.ss_operation(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
    if tc and tc:IsRelateToEffect(e) then
        if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then      
            local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,46864967)
            if ct>=2 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				Duel.SendtoHand(c,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,c)
                return
			else
				Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end             
        end
    end
end


