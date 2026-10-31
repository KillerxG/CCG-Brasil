-- Mr.'s Mythical Gryphon
-- Card ID 333001670 | Effect Monster, NOT Gemini
local s,id=GetID()
local SET_MR=0x215b

function s.initial_effect(c)
    -- From hand: reveal Gryphon and target a Level 5 "Mr.";
    -- summon matching Xyz and use target + Gryphon as its materials.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,{id,0})
    e1:SetCost(s.handcost)
    e1:SetTarget(s.handtg)
    e1:SetOperation(s.handop)
    c:RegisterEffect(e1)

    -- While this card is an Xyz material, grant a rotation Quick Effect
    -- to its "Mr." Xyz host; SHARE SAME HARD OPT as hand effect.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,0})
    e2:SetCondition(s.xyzcon)
    e2:SetTarget(s.xyztg)
    e2:SetOperation(s.xyzop)
    c:RegisterEffect(e2)
end

s.listed_series={SET_MR}

function s.xyzfilter(c,tc,e,tp)
    return c:IsSetCard(SET_MR) and c:IsType(TYPE_XYZ)
        and c:IsRace(tc:GetOriginalRace())
        and c:IsAttribute(tc:GetOriginalAttribute())
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.handcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_HAND) end
    Duel.ConfirmCards(1-tp,e:GetHandler())
end
function s.handfilter(c,e,tp)
    return c:IsFaceup() and c:IsLevel(5) and c:IsSetCard(SET_MR)
        and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,c,e,tp)
end
function s.handtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE)
        and chkc:IsControler(tp) and s.handfilter(chkc,e,tp) end
    if chk==0 then return Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_XYZ)>0
        and Duel.IsExistingTarget(s.handfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.handfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.handop(e,tp,eg,ep,ev,re,r,rp)
    local gryphon=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not gryphon:IsLocation(LOCATION_HAND) or not tc or not tc:IsFaceup()
        or not tc:IsRelateToEffect(e) or not tc:IsControler(tp) then return end
    local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,tc,e,tp)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local xyz=g:Select(tp,1,1,nil):GetFirst()
    if not xyz then return end
    local mat=Group.FromCards(tc,gryphon)
    xyz:SetMaterial(mat)
    Duel.Overlay(xyz,mat)
    if Duel.SpecialSummon(xyz,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
        xyz:CompleteProcedure()
    end
end

function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
    local host=e:GetHandler()
    return host:IsFaceup() and host:IsType(TYPE_XYZ) and host:IsSetCard(SET_MR)
        and host:GetOverlayGroup():IsExists(Card.IsCode,1,nil,id)
end
function s.targetfilter(c,host,e,tp)
    return c~=host and c:IsFaceup() and c:IsSetCard(SET_MR)
        and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,c,e,tp)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local host=e:GetHandler()
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE)
        and s.targetfilter(chkc,host,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.targetfilter,tp,LOCATION_MZONE,
        0,1,host,host,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.targetfilter,tp,LOCATION_MZONE,0,1,1,host,host,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,host,1,0,0)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
    local host=e:GetHandler()
    if not host:IsFaceup() or not host:IsLocation(LOCATION_MZONE) then return end
    local gryphon=host:GetOverlayGroup():Filter(Card.IsCode,nil,id):GetFirst()
    local tc=Duel.GetFirstTarget()
    if not gryphon or not tc or not tc:IsFaceup()
        or not tc:IsRelateToEffect(e) or not tc:IsControler(tp) then return end
    local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,tc,e,tp)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local xyz=g:Select(tp,1,1,nil):GetFirst()
    if not xyz then return end
    local mat=Group.FromCards(gryphon,tc)
    xyz:SetMaterial(mat)
    Duel.Overlay(xyz,mat)
    if Duel.SpecialSummon(xyz,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)==0 then return end
    xyz:CompleteProcedure()
    if host:IsFaceup() and host:IsLocation(LOCATION_MZONE) then
        Duel.Destroy(host,REASON_EFFECT)
    end
end
