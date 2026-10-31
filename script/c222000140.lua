-- Prysm Beast Ranger
-- ID: 222000140 | Setcode: 0x100b | Pendulum Effect Monster, Scale 5
local s,id=GetID()
local SET_PRYSM=0x100b
s.listed_series={SET_PRYSM}

function s.initial_effect(c)
    Pendulum.AddProcedure(c)
    -- Pendulum effect: return Ranger to hand, give Prysm Beast monsters
    -- the targeted monster's Level as an alternative Xyz Level.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,{id,0})
    e1:SetTarget(s.pentg)
    e1:SetOperation(s.penop)
    c:RegisterEffect(e1)
    -- Monster effect 1 (hand): bounce a face-up Prysm Beast; Special Summon Ranger.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.moncost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
    -- Monster effect 2 (field): excavate, send, change name.
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,2})
    e3:SetTarget(s.montg)
    e3:SetOperation(s.monop)
    c:RegisterEffect(e3)
end

function s.pentfilter(c)
    return c:IsFaceup() and c:IsMonster() and c:IsSetCard(SET_PRYSM)
        and c:IsLevelAbove(1)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp)
        and s.pentfilter(chkc) end
    if chk==0 then return e:GetHandler():IsAbleToHand()
        and Duel.IsExistingTarget(s.pentfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.pentfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,tp,LOCATION_PZONE)
end
function s.xyzlev(e,c,rc)
    -- Low 16 bits = current Level, high 16 bits = alternative Xyz Level.
    if not rc or not rc:IsAttribute(ATTRIBUTE_WATER) then return c:GetLevel() end
    return c:GetLevel() | (e:GetLabel()<<16)
end
function s.xyzlevfilter(c)
    return c:IsFaceup() and c:IsMonster() and c:IsSetCard(SET_PRYSM)
        and c:IsLevelAbove(0)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or not tc or not tc:IsRelateToEffect(e)
        or not tc:IsFaceup() or not tc:IsLevelAbove(1) then return end
    local lvl=tc:GetLevel()
    if Duel.SendtoHand(c,nil,REASON_EFFECT)==0 then return end
    local ge=Effect.CreateEffect(c)
    ge:SetType(EFFECT_TYPE_FIELD)
    ge:SetCode(EFFECT_XYZ_LEVEL)
    ge:SetTargetRange(LOCATION_MZONE,0)
    ge:SetTarget(s.xyzlevfilter)
    ge:SetValue(s.xyzlev)
    ge:SetLabel(lvl)
    ge:SetReset(RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(ge,tp)
end

function s.costfilter(c)
    return c:IsFaceup() and c:IsMonster() and c:IsSetCard(SET_PRYSM)
        and c:IsAbleToHandAsCost()
end
function s.moncost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SendtoHand(g,nil,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.montg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetMatchingGroupCount(s.faceupprysm,tp,LOCATION_ONFIELD,0,nil)>0
        and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.faceupprysm(c)
    return c:IsFaceup() and c:IsSetCard(SET_PRYSM)
end
function s.sendfilter(c)
    return c:IsMonster() and c:IsSetCard(SET_PRYSM) and c:IsAbleToGrave()
end
function s.monop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local n=Duel.GetMatchingGroupCount(s.faceupprysm,tp,LOCATION_ONFIELD,0,nil)
    n=math.min(n,Duel.GetFieldGroupCount(tp,LOCATION_DECK,0))
    if n==0 then return end
    Duel.ConfirmDecktop(tp,n)
    local top=Duel.GetDecktopGroup(tp,n)
    local valid=top:Filter(s.sendfilter,nil)
    if #valid==0 then
        -- No eligible Prysm Beast Monster excavated; return cards to Deck.
        Duel.ShuffleDeck(tp)
        return
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local chosen=valid:Select(tp,1,1,nil)
    if Duel.SendtoGrave(chosen,REASON_EFFECT)==0 then
        Duel.ShuffleDeck(tp)
        return
    end
    Duel.ShuffleDeck(tp)
    if not c:IsFaceup() or not c:IsLocation(LOCATION_MZONE) then return end
    -- The declared name is limited to the Prysm Beast archetype.
    local code=Duel.AnnounceCard(tp,SET_PRYSM,OPCODE_ISSETCARD)
    local ne=Effect.CreateEffect(c)
    ne:SetType(EFFECT_TYPE_SINGLE)
    ne:SetCode(EFFECT_CHANGE_CODE)
    ne:SetValue(code)
    ne:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
    c:RegisterEffect(ne)
end
