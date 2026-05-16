-- Creature-Warden, Sarafaye
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Efeito 1: Se comprada (exceto na Draw Phase), revelar para buscar a Magia de Ritual
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND | CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_TO_HAND)
    e1:SetCondition(s.srchcon)
    e1:SetCost(s.srchcost)
    e1:SetTarget(s.srchtg)
    e1:SetOperation(s.srchop)
    c:RegisterEffect(e1)

    -- Efeito 2: Olhar as 4 cartas do topo do Deck e colocá-las no topo em qualquer ordem
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.sorttg)
    e2:SetOperation(s.sortop)
    c:RegisterEffect(e2)

    -- Efeito 3: (Efeito Rápido) Carta aleatória da mão do oponente para o fundo do Deck, ele compra 1, e trava SS da Mão
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_TODECK | CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E | TIMING_MAIN_END)
    e3:SetCountLimit(1, {id, 1})
    e3:SetTarget(s.decktg)
    e3:SetOperation(s.deckop)
    c:RegisterEffect(e3)

    -- Efeito 4: Se o oponente adicionar carta do Deck para a mão, você pode comprar 1 carta
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 3))
    e4:SetCategory(CATEGORY_DRAW)
    e4:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_TO_HAND)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.drawcon)
    e4:SetTarget(s.drawtg)
    e4:SetOperation(s.drawop)
    c:RegisterEffect(e4)
	
	-- Efeito 5: Seu oponente não pode dar alvo nessa carta
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
end

s.listed_series = {0x251}
s.listed_names = {777006080}

-- ==========================================================
-- Efeito 1: Buscar Convocation ao Ser Comprado
-- ==========================================================
function s.srchcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    -- Lê as propriedades do Handler em vez de indexar um Event Group
    return c:IsReason(REASON_DRAW) and c:IsPreviousLocation(LOCATION_DECK) and Duel.GetCurrentPhase() ~= PHASE_DRAW
end

function s.srchcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    -- Confirma se a carta ainda é privada na mão para exibi-la como custo
    if chk == 0 then return not c:IsPublic() end
    Duel.ConfirmCards(1 - tp, c)
end

function s.thfilter(c)
    return c:IsCode(777006080) and c:IsAbleToHand()
end

function s.srchtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK | LOCATION_GRAVE, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK | LOCATION_GRAVE)
end

function s.srchop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.thfilter), tp, LOCATION_DECK | LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

-- ==========================================================
-- Efeito 2: Olhar o Topo do Deck e Organizar
-- ==========================================================
function s.sorttg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) >= 4 end
end

function s.sortop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) >= 4 then
        Duel.SortDecktop(tp, tp, 4)
    end
end

-- ==========================================================
-- Efeito 3: Efeito Rápido (Descarte para o fundo, Oponente Compra, Trava SS da Mão)
-- ==========================================================
function s.decktg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetFieldGroupCount(tp, 0, LOCATION_HAND) > 0
        and Duel.IsPlayerCanDraw(1 - tp, 1) end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, 1 - tp, LOCATION_HAND)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, 1 - tp, 1)
end

function s.sumlimit(e, c)
    return c:IsLocation(LOCATION_HAND)
end

function s.deckop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetFieldGroup(tp, 0, LOCATION_HAND)
    if #g == 0 then return end
    
    local sg = g:RandomSelect(tp, 1)
    if Duel.SendtoDeck(sg, nil, SEQ_DECKBOTTOM, REASON_EFFECT) > 0 then
        if Duel.Draw(1 - tp, 1, REASON_EFFECT) > 0 then
            local e1 = Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET | EFFECT_FLAG_CLIENT_HINT)
            e1:SetDescription(aux.Stringid(id, 4))
            e1:SetTargetRange(0, 1)
            e1:SetTarget(s.sumlimit)
            e1:SetReset(RESET_PHASE | PHASE_END)
            Duel.RegisterEffect(e1, tp)
        end
    end
end

-- ==========================================================
-- Efeito 4: Comprar ao oponente buscar (Add from Deck to Hand)
-- ==========================================================
function s.cfilter(c, tp)
    return c:IsControler(1 - tp) and c:IsPreviousLocation(LOCATION_DECK)
end

function s.drawcon(e, tp, eg, ep, ev, re, r, rp)
    return not Duel.IsDamageStep() and eg:IsExists(s.cfilter, 1, nil, tp)
end

function s.drawtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDraw(tp, 1) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.drawop(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    Duel.Draw(p, d, REASON_EFFECT)
end