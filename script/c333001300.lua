--Technician of the Team Fins
local s,id=GetID()
function s.initial_effect(c)
    -- E1: Ritual Summon "Team Fins" monsters
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.ritual_target)
    e1:SetOperation(s.ritual_activate)
    c:RegisterEffect(e1)

    -- E2: If a Ritual Monster is sent to GY, retrieve this card + 1 WATER monster
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

-- E1: Ritual Summon procedure
function s.ritual_filter(c,e,tp,m)
    return c:IsSetCard(0x1F1) and c:IsRitualMonster()
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
        and Duel.GetRitualMaterial(tp):CheckWithSumGreater(Card.GetRitualLevel,c:GetLevel(),c)
end
function s.ritual_target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.ritual_filter,tp,LOCATION_HAND,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.ritual_activate(e,tp,eg,ep,ev,re,r,rp)
    local mg=Duel.GetRitualMaterial(tp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tg=Duel.SelectMatchingCard(tp,s.ritual_filter,tp,LOCATION_HAND,0,1,1,nil,e,tp,mg)
    local tc=tg:GetFirst()
    if tc then
        mg:RemoveCard(tc) -- Corrige o erro: remove o ritual do grupo de materiais
        local mat=mg:SelectWithSumGreater(tp,Card.GetRitualLevel,tc:GetLevel(),tc)
        if not mat or #mat==0 then return end
        tc:SetMaterial(mat)
        Duel.ReleaseRitualMaterial(mat)
        Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
        tc:CompleteProcedure()
    end
end

-- E2: Check if a Ritual Monster was sent to GY
function s.cfilter(c,tp)
    return c:IsType(TYPE_RITUAL) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.thfilter(c)
    return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.thfilter(chkc) end
    if chk==0 then
        return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
            and e:GetHandler():IsAbleToHand()
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local c=e:GetHandler()
    if tc and tc:IsRelateToEffect(e) and c:IsRelateToEffect(e) then
        local g=Group.FromCards(c,tc)
        Duel.SendtoHand(g,nil,REASON_EFFECT)
    end
end
