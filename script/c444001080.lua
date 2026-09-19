-- The Bartender of Vampire Castle
local s, id = GetID()
function s.initial_effect(c)
    -- 1. Revelar da mao se nao controlar monstros e realizar Invocacao-Normal por efeito
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.normcon)
    e1:SetCost(s.normcost)
    e1:SetTarget(s.normtg)
    e1:SetOperation(s.normop)
    c:RegisterEffect(e1)

    -- 2. Adicionar 1 "Vampire" do Deck/GY a mao e realizar Invocacao-Normal
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id + 1)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    -- 3. Retornar do GY para a mao e realizar Invocacao-Normal + Banir ao sair do campo
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, id + 2)
    e3:SetCondition(s.spcon2)
    e3:SetTarget(s.sptg2)
    e3:SetOperation(s.spop2)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3b)
    local e3c = e3:Clone()
    e3c:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e3c)

    -- 4. Ganhar 500 LP sempre que um "Vampire" for Invocado (Apenas 1 Bartender ativa por vez)
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 3))
    e4:SetCategory(CATEGORY_RECOVER)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_SUMMON_SUCCESS)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.lpcon)
    e4:SetOperation(s.lpop)
    c:RegisterEffect(e4)
    local e4b = e4:Clone()
    e4b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e4b)
    local e4c = e4:Clone()
    e4c:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e4c)
end

s.listed_series = {0x8e}

-- Efeito 1: Invocacao-Normal da mao por efeito
function s.normcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0) == 0
end

function s.normcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return not c:IsPublic() end
    Duel.ConfirmCards(1 - tp, c)
    Duel.ShuffleHand(tp)
end

function s.normtg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsSummonable(true, nil) end
    Duel.SetOperationInfo(0, CATEGORY_SUMMON, c, 1, 0, 0)
end

function s.normop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsSummonable(true, nil) then
        Duel.Summon(tp, c, true, nil)
    end
end

-- Efeito 2: Busca e Invocacao-Normal
function s.thfilter(c)
    return c:IsSetCard(0x8e) and c:IsMonster() and c:IsAbleToHand()
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_SUMMON, nil, 0, 0, 0)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.thfilter), tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 and Duel.SendtoHand(g, nil, REASON_EFFECT) > 0 and g:GetFirst():IsLocation(LOCATION_HAND) then
        Duel.ConfirmCards(1 - tp, g)
        local tc = g:GetFirst()
        if tc:IsSummonable(true, nil) then
            Duel.BreakEffect()
            Duel.Summon(tp, tc, true, nil)
        end
    end
end

-- Efeito 3: Retorno do GY -> Mao -> Invocacao-Normal + Redirecionamento de Banimento
function s.cfilter(c, tp)
    return c:IsFaceup() and c:IsControler(tp) and (c:IsSetCard(0x8e) or c:IsRace(RACE_ZOMBIE))
end

function s.spcon2(e, tp, eg, ep, ev, re, r, rp)
    return not Duel.IsDamageStep() and eg:IsExists(s.cfilter, 1, nil, tp)
end

function s.sptg2(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToHand() end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, c, 1, tp, LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_SUMMON, c, 1, 0, 0)
end

function s.spop2(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SendtoHand(c, nil, REASON_EFFECT) > 0 and c:IsLocation(LOCATION_HAND) then
        Duel.ConfirmCards(1 - tp, c)
        if c:IsSummonable(true, nil) then
            Duel.BreakEffect()
            -- Redireciona para banimento ao sair do campo
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetValue(LOCATION_REMOVED)
            e1:SetReset(RESET_EVENT + RESETS_REDIRECT)
            c:RegisterEffect(e1, true)
            Duel.Summon(tp, c, true, nil)
        end
    end
end

-- Efeito 4: Ganho de LP (Evita ativacao/ganho duplicado se houver 2 Bartenders em campo)
function s.lpfilter(c, tp)
    return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x8e)
end

function s.lpcon(e, tp, eg, ep, ev, re, r, rp)
    if not eg:IsExists(s.lpfilter, 1, nil, tp) then return false end
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)
    g = g:Filter(Card.IsCode, nil, id)
    return #g > 0 and g:GetFirst() == e:GetHandler()
end

function s.lpop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_CARD, 0, id)
    Duel.Recover(tp, 500, REASON_EFFECT)
end