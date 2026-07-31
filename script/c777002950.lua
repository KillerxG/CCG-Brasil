-- Shinigami Madness
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Ativação
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
    c:RegisterEffect(e0)

    -- Efeito 1: Gatilho Mandatório -> Invocar do Déqui Principal -> Negar 1 monstro
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.mdcon)
    e1:SetTarget(s.mdtg)
    e1:SetOperation(s.mdop)
    c:RegisterEffect(e1)

    -- Efeito 2: Gatilho Mandatório -> Invocar do Extra Deck -> Voltar 1 para a Mão
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.excon)
    e2:SetTarget(s.extg)
    e2:SetOperation(s.exop)
    c:RegisterEffect(e2)

    -- Efeito 3: Gatilho Mandatório na End Phase -> Oponente (Você) pode comprar 1 carta
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_PHASE + PHASE_END)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1, id + 2)
    e3:SetCondition(s.epcon)
    e3:SetTarget(s.eptg)
    e3:SetOperation(s.epop)
    c:RegisterEffect(e3)
	
	-- Efeito Rápido/Ignição na Mão: Revelar e Colocar no Oponente
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 5))
    e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
    e4:SetRange(LOCATION_HAND)
    e4:SetCountLimit(1, id)
    e4:SetCondition(s.placecon)
    e4:SetCost(s.placecost)
    e4:SetTarget(s.placetg)
    e4:SetOperation(s.placeop)
    c:RegisterEffect(e4)
end

-- ====================================================================
-- Efeito 1: Punição de Invocação do Main Deck
-- ====================================================================
function s.mdfilter(c, tp)
    return c:IsSummonPlayer(tp) and c:IsPreviousLocation(LOCATION_DECK)
end

function s.mdcon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.mdfilter, 1, nil, tp)
end

function s.mdtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    -- Atualizado com a função nativa Card.IsNegatable()
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsNegatable() end
    -- "chk == 0 then return true" informa ao motor que é um efeito mandatório
    if chk == 0 then return true end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local g = Duel.SelectTarget(tp, Card.IsNegatable, tp, LOCATION_MZONE, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_DISABLE, g, 1, 0, 0)
end

function s.mdop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    -- Confere se a carta ainda pode ser negada no momento da resolução
    if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsNegatable() then
        Duel.NegateRelatedChain(tc, RESET_TURN_SET)
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(e1)
        local e2 = Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetValue(RESET_TURN_SET)
        e2:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(e2)
    end
end

-- ====================================================================
-- Efeito 2: Punição de Invocação do Extra Deck
-- ====================================================================
function s.exfilter(c, tp)
    return c:IsSummonPlayer(tp) and c:IsPreviousLocation(LOCATION_EXTRA)
end

function s.excon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.exfilter, 1, nil, tp)
end

function s.extg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
    if chk == 0 then return true end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RTOHAND)
    local g = Duel.SelectTarget(tp, Card.IsAbleToHand, tp, LOCATION_MZONE, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, 0)
end

function s.exop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc, nil, REASON_EFFECT)
    end
end

-- ====================================================================
-- Efeito 3: Compra do Oponente (Condicionada ao Lord of Shinigamis)
-- ====================================================================
function s.bossfilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777001120
end

function s.epcon(e, tp, eg, ep, ev, re, r, rp)
    -- Verifica se é a End Phase do controlador da Armadilha e se o Oponente tem o Boss
    return Duel.GetTurnPlayer() == tp and Duel.IsExistingMatchingCard(s.bossfilter, tp, 0, LOCATION_MZONE, 1, nil)
end

function s.eptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, 1 - tp, 1)
end

function s.epop(e, tp, eg, ep, ev, re, r, rp)
    -- "Your opponent can draw 1 card" (O oponente ganha a opção)
    if Duel.IsPlayerCanDraw(1 - tp, 1) and Duel.SelectYesNo(1 - tp, aux.Stringid(id, 3)) then
        Duel.Draw(1 - tp, 1, REASON_EFFECT)
    end
end

-- ====================================================================
-- Efeito na Mão: Revelar e Colocar na Zona do Oponente
-- ====================================================================
function s.bossfilter(c)
    -- Confere se você controla o Lorde
    return c:IsFaceup() and c:GetOriginalCode() == 777001120
end

function s.placecon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.bossfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.placecost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    -- Confere se a carta não está pública (revelada por outro efeito) e revela como Custo
    if chk == 0 then return not c:IsPublic() end
    Duel.ConfirmCards(1 - tp, c)
end

function s.placetg(e, tp, eg, ep, ev, re, r, rp, chk)
    -- O único alvo necessário é ter espaço na Zona de S/T do oponente
    if chk == 0 then return Duel.GetLocationCount(1 - tp, LOCATION_SZONE) > 0 end
end

function s.placeop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    
    -- Coloca a carta diretamente virada para cima na zona do inimigo (1 - tp)
    if Duel.GetLocationCount(1 - tp, LOCATION_SZONE) > 0 then
        Duel.MoveToField(c, tp, 1 - tp, LOCATION_SZONE, POS_FACEUP, true)
    end
end