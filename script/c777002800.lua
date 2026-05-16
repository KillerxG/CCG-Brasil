-- Pyroland Calamity Beats
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Adicionar 1 "Pyroland" e enviar 3 cartas do topo do Deck ao GY
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND | CATEGORY_SEARCH | CATEGORY_DECKDES)
    e1:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1, {id, 1})
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    
    -- Clone para a Invocação-Especial
    local e2 = e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)

    -- Efeito 2: Special Summon se for enviado do Deck para o GY
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCountLimit(1, {id, 2})
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

s.listed_series = {0x278}
s.listed_names = {id}

-- ==========================================================
-- Efeito 1: Busca e Envio (Mill) do Topo
-- ==========================================================
function s.thfilter(c)
    return c:IsSetCard(0x278) and c:IsAbleToHand() and not c:IsCode(id)
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then 
        -- Atesta que o jogador tem o limite mínimo absoluto para a resolução inteira (1 para a mão + 3 para o GY)
        return Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) >= 4
            and Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil)
            and Duel.IsPlayerCanDiscardDeck(tp, 3) 
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 0, tp, 3)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    
    -- O delimitador "then" exige que a adição seja concretizada antes de enviarmos as cartas do topo
    if #g > 0 and Duel.SendtoHand(g, nil, REASON_EFFECT) > 0 then
        Duel.ConfirmCards(1 - tp, g)
        Duel.BreakEffect()
        Duel.DiscardDeck(tp, 3, REASON_EFFECT)
    end
end

-- ==========================================================
-- Efeito 2: Invocação a partir do Deck
-- ==========================================================
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    -- Confirma se a localização imediatamente anterior à chegada do monstro ao GY era o Deck
    return c:IsPreviousLocation(LOCATION_DECK)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        -- Aplica a penalidade de banimento quando a carta deixar o campo
        local e1 = Effect.CreateEffect(c)
        e1:SetDescription(3300) -- Código do cliente (Client Hint) que avisa "Banish when it leaves the field"
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE | EFFECT_FLAG_CLIENT_HINT)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetValue(LOCATION_REMOVED)
        e1:SetReset(RESET_EVENT | RESETS_REDIRECT)
        c:RegisterEffect(e1, true)
    end
end