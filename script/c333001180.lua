--Noctavius Sanctuary
local s,id=GetID()

function s.initial_effect(c)
    -- Efeito 1: Seleciona 2 Winged Beast com mesmo Nível, destrói 1 e adiciona o outro à mão
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target1)
    e1:SetOperation(s.activate1)
    c:RegisterEffect(e1)

    -- Efeito 2: Se controlar "Noctavius", invoca 1 Zumbi do GY no campo do oponente e adiciona esta carta à mão
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

-- 🔹 Efeito 1

function s.wbfilter(c)
    return c:IsRace(RACE_WINGEDBEAST) and c:IsLevelAbove(1) and c:IsAbleToHand()
end

function s.samelevelpairfilter(g)
    return g:GetClassCount(Card.GetLevel)==1
end

function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local g=Duel.GetMatchingGroup(s.wbfilter,tp,LOCATION_DECK,0,nil)
        return aux.SelectUnselectGroup(g,e,tp,2,2,s.samelevelpairfilter,0)
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.activate1(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.wbfilter,tp,LOCATION_DECK,0,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
    local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.samelevelpairfilter,1,tp,HINTMSG_SELECT)
    if not sg or #sg<2 then return end
    Duel.ConfirmCards(1-tp,sg)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local dg=sg:Select(tp,1,1,nil)
    local tg=sg-dg
    if #dg>0 then
        Duel.Destroy(dg,REASON_EFFECT)
    end
    if #tg>0 then
        Duel.SendtoHand(tg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tg)
    end
end

-- 🔹 Efeito 2

function s.noctaviusfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x758) -- Altere o SetCode se usar outro
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.noctaviusfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.zombiefilter(c,e,tp)
    return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,1-tp,false,false,POS_FACEUP)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.zombiefilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
            and e:GetHandler():IsAbleToHand()
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.zombiefilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,1-tp,1-tp,false,false,POS_FACEUP)
    end
    if c:IsRelateToEffect(e) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
    end
end
