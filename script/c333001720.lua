-- Mr.'s Mood Mistake
-- Card ID: 333001720
-- Intended card type: Continuous Spell (set TYPE_SPELL|TYPE_CONTINUOUS in the .cdb)
local s,id=GetID()
local SET_MR=0x215b

function s.initial_effect(c)
    -- Activate; optionally attach 1 card from your GY to a "Mr." Xyz you control
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetTarget(s.acttg)
    e1:SetOperation(s.actop)
    c:RegisterEffect(e1)
    -- If this card is destroyed, optionally attach a card
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,7))
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetCondition(s.descon)
    e2:SetTarget(s.attachtg)
    e2:SetOperation(s.attachop)
    c:RegisterEffect(e2)

    -- Normal Summon (includes Tribute Summon)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,3))
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.normalcon)
    e3:SetOperation(s.normalop)
    c:RegisterEffect(e3)
    -- Tribute Summon: an additional benefit (no OPT)
    local e4=e3:Clone()
    e4:SetDescription(aux.Stringid(id,4))
    e4:SetCondition(s.tributecon)
    e4:SetOperation(s.tributeop)
    c:RegisterEffect(e4)
    -- Special Summon (including Xyz Summon)
    local e5=e3:Clone()
    e5:SetDescription(aux.Stringid(id,5))
    e5:SetCode(EVENT_SPSUMMON_SUCCESS)
    e5:SetCondition(s.specialcon)
    e5:SetOperation(s.specialop)
    c:RegisterEffect(e5)
    -- Xyz Summon: additional benefit
    local e6=e5:Clone()
    e6:SetDescription(aux.Stringid(id,6))
    e6:SetCondition(s.xyzcon)
    e6:SetOperation(s.xyzop)
    c:RegisterEffect(e6)

    -- You can only control 1 face-up "Mr.'s Mood Mistake"
    c:SetUniqueOnField(1,0,id)
end

function s.mr(c)
    return c:IsSetCard(SET_MR) and c:IsMonster()
end
function s.xyzfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(SET_MR)
end
function s.attachavailable(tp)
    return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
       and Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)>0
end

function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if s.attachavailable(tp) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        e:SetLabel(1)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
        if #g>0 then
            Duel.SetTargetCard(g)
        else
            e:SetLabel(0)
        end
    else
        e:SetLabel(0)
    end
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
    if e:GetLabel()~=1 then return end
    s.doattach(e,tp)
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.xyzfilter(chkc) end
    if chk==0 then return s.attachavailable(tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
    s.doattach(e,tp)
end
function s.doattach(e,tp)
    local xyz=Duel.GetFirstTarget()
    if not xyz or not xyz:IsRelateToEffect(e) or not s.xyzfilter(xyz) then return end
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_GRAVE,0,nil)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local sel=g:Select(tp,1,1,nil)
    if #sel>0 then Duel.Overlay(xyz,sel) end
end

-- Effects granted by this card do not re-trigger its own Special Summons.
function s.fromself(re)
    return re and re:GetHandler() and re:GetHandler():IsCode(id)
end
function s.oursummoned(c,tp)
    return c:IsFaceup() and c:IsControler(tp) and s.mr(c)
end
function s.normalcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.oursummoned,1,nil,tp)
end
function s.tributecheck(c,tp)
    return s.oursummoned(c,tp) and c:IsSummonType(SUMMON_TYPE_TRIBUTE) and c:GetMaterialCount()>0
end
function s.tributecon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.tributecheck,1,nil,tp)
end
function s.specialcon(e,tp,eg,ep,ev,re,r,rp)
    return not s.fromself(re) and eg:IsExists(s.oursummoned,1,nil,tp)
end
function s.xyzcheck(c,tp)
    return s.oursummoned(c,tp) and c:IsType(TYPE_XYZ)
        and c:IsSummonType(SUMMON_TYPE_XYZ)
end
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
    return not s.fromself(re) and eg:IsExists(s.xyzcheck,1,nil,tp)
end

function s.excfilter(c,attr)
    return s.mr(c) and (c:GetAttribute()&attr)==0 and c:IsAbleToHand()
end
function s.normalop(e,tp,eg,ep,ev,re,r,rp)
    local summoned=eg:Filter(s.oursummoned,nil,tp)
    local sc=summoned:GetFirst()
    if not sc then return end
    local ct=math.min(3,Duel.GetFieldGroupCount(tp,LOCATION_DECK,0))
    if ct==0 then return end
    Duel.ConfirmDecktop(tp,ct)
    local top=Duel.GetDecktopGroup(tp,ct)
    local eligible=top:Filter(s.excfilter,nil,sc:GetAttribute())
    if #eligible>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=eligible:Select(tp,1,1,nil)
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
    Duel.ShuffleDeck(tp)
end
function s.tributefilter(c,e,tp)
    return s.mr(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tributeop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local g=Duel.GetMatchingGroup(s.tributefilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,nil,e,tp)
    if #g==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=g:Select(tp,1,1,nil)
    if #sg>0 then Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP) end
end

function s.specialop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.oursummoned,nil,tp)
    for tc in aux.Next(g) do
        if tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(400)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD)
            tc:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_UPDATE_DEFENSE)
            tc:RegisterEffect(e2)
        end
    end
end
function s.xyzmatfilter(c)
    return c:IsSetCard(SET_MR) and c:IsType(TYPE_MONSTER) and
        (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.xyzcheck,nil,tp)
    if #g==0 then return end
    local pool=Duel.GetMatchingGroup(s.xyzmatfilter,tp,
        LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
    if #pool==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local sc=g:Select(tp,1,1,nil):GetFirst()
    if not sc or not sc:IsFaceup() or not sc:IsLocation(LOCATION_MZONE) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local sel=pool:Select(tp,1,1,nil)
    if #sel>0 then Duel.Overlay(sc,sel) end
end
