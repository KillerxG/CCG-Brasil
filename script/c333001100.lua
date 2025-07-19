-- Minomushi Rider
local s,id=GetID()
local MINOMUSHI_WARRIOR_CODE=46864967

function s.initial_effect(c)
    -- (A) Este card é tratado como um Monstro Normal enquanto estiver na sua mão.
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetCode(EFFECT_CHANGE_TYPE)
    e0:SetRange(LOCATION_HAND)
    e0:SetValue(TYPE_MONSTER+TYPE_NORMAL)
    c:RegisterEffect(e0)
    
    -- (1) Se este card for Normal ou Special Summoned:
    -- Adicione 1 "Minomushi Warrior" da sua Deck ou do Cemitério para a sua mão.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    local e1a=e1:Clone()
    e1a:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e1a)
    
    -- (2) Se um monstro do Tipo Rocha for Ritual Summoned:
    -- Você pode banir este card da sua Zona de Cemitério; adicione 1 monstro Normal Rocha da sua Deck para a sua mão,
    -- depois, se esse card adicionado for Summoned neste turno, Special Summon este card da banimento.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.condition2)
    e2:SetCost(s.cost2)
    e2:SetTarget(s.target2)
    e2:SetOperation(s.operation2)
    c:RegisterEffect(e2)
end

-----------------------------------------------------------
-- Efeito (1): Adicionar "Minomushi Warrior" da Deck ou GY para a mão
-----------------------------------------------------------
function s.filter1(c)
    return c:IsCode(MINOMUSHI_WARRIOR_CODE) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-----------------------------------------------------------
-- Efeito (2): Se um Rock monster for Ritual Summoned, ative este efeito
-----------------------------------------------------------
-- Condição: verifica se entre os monstros Summonados há algum Rock que foi Ritual Summoned.
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(function(c) return c:IsRace(RACE_ROCK) and c:IsSummonType(SUMMON_TYPE_RITUAL) end,1,nil)
end
-- Custo: banir este card da Zona de Cemitério.
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- Alvo: adicione 1 monstro Normal do Tipo Rocha da sua Deck para a mão.
function s.filter2(c)
    return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_ROCK) and c:IsAbleToHand()
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- Operação: adicione o card selecionado à mão e registre um efeito temporário
-- para monitorar se ele é Summoned neste turno. Se isso ocorrer, Special Summon este card da banimento.
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil)
    local tc=g:GetFirst()
    if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
        Duel.ConfirmCards(1-tp,tc)
        -- Registra um efeito no card adicionado para identificá-lo durante este turno.
        tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
        -- Cria um efeito contínuo que monitora se o card adicionado é Summoned neste turno.
        local sc=e:GetHandler() -- "Minomushi Rider" que foi banido
        local tbl={ added=tc, rider=sc }
        local ce=Effect.CreateEffect(sc)
        ce:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ce:SetCode(EVENT_SUMMON_SUCCESS)
        ce:SetLabelObject(tbl)
        ce:SetCondition(s.summon_trigger_cond)
        ce:SetOperation(s.summon_trigger_op)
        ce:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(ce,tp)
        local ce2=ce:Clone()
        ce2:SetCode(EVENT_SPSUMMON_SUCCESS)
        Duel.RegisterEffect(ce2,tp)
    end
end

-- Condição para o efeito contínuo: verifica se o card adicionado foi Summoned.
function s.summon_trigger_cond(e,tp,eg,ep,ev,re,r,rp)
    local tbl=e:GetLabelObject()
    if not tbl or not tbl.added then return false end
    return eg:IsContains(tbl.added)
end
-- Operação para o efeito contínuo: se o card adicionado for Summoned, Special Summon "Minomushi Rider" da banimento.
function s.summon_trigger_op(e,tp,eg,ep,ev,re,r,rp)
    local tbl=e:GetLabelObject()
    if tbl and tbl.rider and tbl.rider:IsLocation(LOCATION_REMOVED) and tbl.rider:IsCanBeSpecialSummoned(e,0,tp,false,false) then
        Duel.SpecialSummon(tbl.rider,0,tp,tp,false,false,POS_FACEUP)
    end
    e:Reset()
end