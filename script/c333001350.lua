--Ancient Cybershark
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER),6,2)
	c:EnableReviveLimit()
    -- E1: Detach 1 to revive WATER Ritual from GY (returns to hand at End Phase)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- E2: Special Summon self from GY by targeting 2 WATER monsters you control
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.xyztg)
    e2:SetOperation(s.xyzop)
    c:RegisterEffect(e2)
end

-------------------------------
-- E1: Special Summon from GY --
-------------------------------
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.filter(c,e,tp)
    return c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_RITUAL)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
        -- Return to hand at End Phase
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetDescription(aux.Stringid(id,2))
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetCountLimit(1)
        e1:SetLabelObject(tc)
        e1:SetCondition(s.retcon)
        e1:SetOperation(s.retop)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end

function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    return tc and tc:IsControler(tp) and tc:IsLocation(LOCATION_MZONE)
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
    Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end

-------------------------------
-- E2: Special Summon self + attach 2 WATER monsters
-------------------------------
function s.xyzfilter(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToChangeControler()
end

function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return false end
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
            and Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,2,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,2,2,nil)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,LOCATION_GRAVE)
end

function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local g=Duel.GetTargetCards(e)
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and #g==2 then
        Duel.BreakEffect()
        Duel.Overlay(c,g)
    end
end
