--Midfielder of the Team Fins
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
    -- E1: On Ritual Summon - send WATER from hand, then SS based on type
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- E2: If sent to GY by effect - add 1 WATER Ritual from Deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end
s.listed_names={333001300}
-- E1: Ritual Summon condition
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end

-- E1: Cost filter (WATER from hand)
function s.costfilter(c,e,tp)
    return c:IsAttribute(ATTRIBUTE_WATER) and c:IsMonster()
        and (
            (not c:IsRitualMonster() and Duel.IsExistingMatchingCard(s.normalfilter,tp,LOCATION_DECK,0,1,nil,c:GetLevel(),e,tp)) or
            (c:IsRitualMonster() and Duel.IsExistingMatchingCard(s.ritualfilter,tp,LOCATION_DECK,0,1,nil,e,tp))
        )
end

-- If sent non-ritual: summon WATER of same Level
function s.normalfilter(c,lv,e,tp)
    return c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevel(lv)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- If sent ritual: summon Team Fins Ritual (as Ritual Summon)
function s.ritualfilter(c,e,tp)
    return c:IsSetCard(0x1f1) and c:IsRitualMonster()
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    local sc=g:GetFirst()
    if not sc then return end
    local lv=sc:GetLevel()
    local was_ritual=sc:IsRitualMonster()
    if Duel.SendtoGrave(sc,REASON_EFFECT)>0 then
        if was_ritual then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local rg=Duel.SelectMatchingCard(tp,s.ritualfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
            local rc=rg:GetFirst()
            if rc then
                Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
                rc:CompleteProcedure()
            end
        else
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local ng=Duel.SelectMatchingCard(tp,s.normalfilter,tp,LOCATION_DECK,0,1,1,nil,lv,e,tp)
            if #ng>0 then
                Duel.SpecialSummon(ng,0,tp,tp,false,false,POS_FACEUP)
            end
        end
    end
end

-- E2: Trigger condition
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_EFFECT)
end

function s.thfilter(c)
    return c:IsAttribute(ATTRIBUTE_WATER) and c:IsRitualMonster() and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
