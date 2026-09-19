local s,id=GetID()
local ID_EMPRESS = 444001010

function s.initial_effect(c)
-- 1. Não pode ser destruída em batalha
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_SINGLE)
e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
e1:SetValue(1)
c:RegisterEffect(e1)

-- 2. Você não sofre dano de batalha
local e2=Effect.CreateEffect(c)
e2:SetType(EFFECT_TYPE_SINGLE)
e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
e2:SetValue(1)
c:RegisterEffect(e2)

-- 3. Busca uma carta vampire no Summon (Normal ou Special)
local e3=Effect.CreateEffect(c)
e3:SetDescription(aux.Stringid(id,0))
e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
e3:SetCode(EVENT_SUMMON_SUCCESS)
e3:SetProperty(EFFECT_FLAG_DELAY)
e3:SetCountLimit(1,id)
e3:SetCost(s.thcost1)
e3:SetTarget(s.thtg1)
e3:SetOperation(s.thop1)
c:RegisterEffect(e3)
-- Clona o efeito para ativação também em Special Summon
local e4=e3:Clone()
e4:SetCode(EVENT_SPSUMMON_SUCCESS)
c:RegisterEffect(e4)

-- 4. Ignition Effect: Enviar para buscar Zumbi
local e5=Effect.CreateEffect(c)
e5:SetDescription(aux.Stringid(id,1))
e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
e5:SetType(EFFECT_TYPE_IGNITION)
e5:SetRange(LOCATION_MZONE)
e5:SetCountLimit(1,id+1)
e5:SetCost(s.thcost2)
e5:SetTarget(s.thtg2)
e5:SetOperation(s.thop2)
c:RegisterEffect(e5)

-- 5. Trigger Effect: Se destruída, invoca Empress
local e6=Effect.CreateEffect(c)
e6:SetDescription(aux.Stringid(id,2))
e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
e6:SetCode(EVENT_DESTROYED)
e6:SetProperty(EFFECT_FLAG_DELAY)
e6:SetCountLimit(1,id+2)
e6:SetCondition(s.spcon)
e6:SetTarget(s.sptg)
e6:SetOperation(s.spop)
c:RegisterEffect(e6)
end

-- ==========================================
-- EFEITO 1: BUSCAR MAGIA OU ARMADILHA
-- ==========================================
function s.thcost1(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return Duel.CheckLPCost(tp,500) end
    Duel.PayLPCost(tp,500)
end

function s.thfilter1(c)
    return c:IsSetCard(0x8e) and c:IsAbleToHand()
end

function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.thop1(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    -- aux.NecroValleyFilter previne que o efeito tente puxar algo do cemitério caso o Necrovalley esteja em campo
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter1),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- ==========================================
-- EFEITO 2: BUSCAR ZUMBI (MANDAR PARA O GY)
-- ==========================================
function s.costfilter(c)
    return c:IsSetCard(0x8e) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost()
end

function s.thcost2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end

function s.thfilter2(c)
    return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- ==========================================
-- EFEITO 3: INVOCAR VAMPIRE EMPRESS
-- ==========================================
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    -- Como a carta tem EVENT_DESTROYED, o próprio gatilho já é a condição
    return true
end

function s.spfilter(c,e,tp)
    return c:IsCode(ID_EMPRESS) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
