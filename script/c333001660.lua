-- Mr.'s Mythical Bird
-- Card ID 333001660; Effect Monster (not Gemini) in .cdb.
local s,id=GetID()
local SET_MR=0x215b

function s.initial_effect(c)
    -- Send this card to the GY; summon a "Mr." from Deck.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,{id,0})
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Once per turn: attach a matching Mr. from your GY,
    -- then attach this Bird from your GY.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_LEAVE_GRAVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.ovtg)
    e2:SetOperation(s.ovop)
    c:RegisterEffect(e2)
end

function s.xyzfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(SET_MR)
end
function s.ovfilter(c,attr,bird)
    return c~=bird and c:IsMonster() and c:IsSetCard(SET_MR)
        and c:IsAttribute(attr)
end
function s.xyzvalid(c,tp,bird)
    return s.xyzfilter(c) and Duel.IsExistingMatchingCard(
        s.ovfilter,tp,LOCATION_GRAVE,0,1,nil,c:GetAttribute(),bird)
end
function s.ovtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local bird=e:GetHandler()
    if chkc then return false end
    if chk==0 then
        return bird:IsLocation(LOCATION_GRAVE)
            and Duel.IsExistingMatchingCard(s.xyzvalid,tp,LOCATION_MZONE,0,1,nil,tp,bird)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local xyz=Duel.SelectMatchingCard(tp,s.xyzvalid,tp,LOCATION_MZONE,0,1,1,nil,tp,bird):GetFirst()
    if not xyz then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local g=Duel.SelectMatchingCard(tp,s.ovfilter,tp,LOCATION_GRAVE,0,1,1,nil,xyz:GetAttribute(),bird)
    local tc=g:GetFirst()
    if not tc then return end
    Duel.SetTargetCard(Group.FromCards(xyz,tc))
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,Group.FromCards(tc,bird),2,tp,LOCATION_GRAVE)
end
function s.ovop(e,tp,eg,ep,ev,re,r,rp)
    local bird=e:GetHandler()
    local pair=Duel.GetTargetCards(e)
    if not pair then return end
    local xyz=pair:Filter(s.xyzfilter,nil):GetFirst()
    local chosen=pair:Filter(function(c) return c:IsLocation(LOCATION_GRAVE) end,nil):GetFirst()
    if not xyz or not chosen or not xyz:IsLocation(LOCATION_MZONE)
        or not xyz:IsControler(tp) or not chosen:IsLocation(LOCATION_GRAVE)
        or not chosen:IsAttribute(xyz:GetAttribute()) then return end
    Duel.Overlay(xyz,Group.FromCards(chosen))
    if bird:IsLocation(LOCATION_GRAVE) and xyz:IsFaceup()
        and xyz:IsLocation(LOCATION_MZONE) then
        Duel.Overlay(xyz,Group.FromCards(bird))
    end
end

function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_MR) and c:IsMonster()
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToGraveAsCost() end
    Duel.SendtoGrave(c,REASON_COST)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

-- The double-material permission applies only to the specifically summoned
-- original Normal monster and only to Xyz with matching original Type/Attribute.
function s.doublemat(e,xyz)
    local tc=e:GetHandler()
    return xyz and xyz:IsType(TYPE_XYZ)
        and xyz:GetOriginalRace()==tc:GetOriginalRace()
        and xyz:GetOriginalAttribute()==tc:GetOriginalAttribute()
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if not tc or Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end

    -- If the target is printed Gemini, awaken it using the engine's Gemini state.
    if tc:IsType(TYPE_GEMINI) and not tc:IsGeminiState() then
        tc:EnableGeminiState()
    end

    -- Originally Normal monsters temporarily gain the Effect/Gemini types.
    -- Important: this does not invent effects absent from the target's script.
    if tc:IsOriginalType(TYPE_NORMAL) then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_ADD_TYPE)
        e1:SetValue(TYPE_EFFECT|TYPE_GEMINI)
        e1:SetReset(RESET_EVENT|RESETS_STANDARD)
        tc:RegisterEffect(e1)
        if not tc:IsGeminiState() then tc:EnableGeminiState() end

        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DOUBLE_XYZ_MATERIAL)
        e2:SetValue(1)
        e2:SetOperation(s.doublemat)
        e2:SetReset(RESET_EVENT|RESETS_STANDARD)
        tc:RegisterEffect(e2)
    end
end
