-- Pyroland Guardian Meditation
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Ativação padrão da Magia Contínua com registro de turno
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetOperation(s.actop)
    c:RegisterEffect(e1)

    -- Efeito 1: Adicionar 1 "Pyroland" monstro do Deck à mão, depois enviar as 3 do topo ao GY
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TOHAND | CATEGORY_SEARCH | CATEGORY_DECKDES)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1, {id, 1})
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    -- Efeito 2: Substituição de Destruição (Enviar 3 do topo do Deck em vez disso)
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EFFECT_DESTROY_REPLACE)
    e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1, {id, 2})
    e3:SetTarget(s.reptg)
    e3:SetValue(s.repval)
    e3:SetOperation(s.repop)
    c:RegisterEffect(e3)

    -- Efeito 3: Se enviada do Deck ou Campo ao GY: Comprar 1, enviar 1, depois resgatar para a Mão
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_DRAW | CATEGORY_DECKDES | CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetCountLimit(1, {id, 3})
    e4:SetCondition(s.drcon)
    e4:SetTarget(s.drtg)
    e4:SetOperation(s.drop)
    c:RegisterEffect(e4)
end

-- Lista os arquétipos Pyroland (0x278) e Guardian (0x52) para as conexões de motor
s.listed_series = {0x278, 0x52}

-- ==========================================================
-- Efeito de Registro de Ativação
-- ==========================================================
function s.actop(e, tp, eg, ep, ev, re, r, rp)
    -- Instala uma bandeira que dura até a End Phase identificando que a carta foi ativada neste turno
    e:GetHandler():RegisterFlagEffect(id, RESET_EVENT | RESETS_STANDARD | RESET_PHASE | PHASE_END, 0, 1)
end

-- ==========================================================
-- Efeito 1: Buscar e Enviar 3 para o GY
-- ==========================================================
function s.thcon(e, tp, eg, ep, ev, re, r, rp)
    -- Verifica se a bandeira indicando "ativada este turno" está presente
    return e:GetHandler():GetFlagEffect(id) > 0
end

function s.thfilter(c)
    return c:IsSetCard(0x278) and c:IsMonster() and c:IsAbleToHand()
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then 
        -- Garante que existam no mínimo 4 cartas para comportar a busca de 1 e o descarte de 3
        return Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) >= 4
            and Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil)
            and Duel.IsPlayerCanDiscardDeck(tp, 3)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 0, tp, 3)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    
    if #g > 0 and Duel.SendtoHand(g, nil, REASON_EFFECT) > 0 then
        Duel.ConfirmCards(1 - tp, g)
        Duel.BreakEffect()
        Duel.DiscardDeck(tp, 3, REASON_EFFECT)
    end
end

-- ==========================================================
-- Efeito 2: Substituição de Destruição
-- ==========================================================
function s.repfilter(c, tp)
    return c:IsFaceup() and c:IsSetCard(0x278) and c:IsLocation(LOCATION_MZONE)
        and c:IsControler(tp) and c:IsReason(REASON_BATTLE | REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end

function s.reptg(e, tp, eg, ep, ev, re, r, rp, chk)
    -- Avalia se o Deck possui as 3 cartas e se há monstros válidos para serem salvos
    if chk == 0 then return Duel.IsPlayerCanDiscardDeck(tp, 3)
        and eg:IsExists(s.repfilter, 1, nil, tp) end
    
    -- "96" exibe na tela: "Você deseja usar o efeito de proteção desta carta?"
    if Duel.SelectEffectYesNo(tp, e:GetHandler(), 96) then
        return true
    end
    return false
end

function s.repval(e, c)
    return s.repfilter(c, e:GetHandlerPlayer())
end

function s.repop(e, tp, eg, ep, ev, re, r, rp)
    -- Envia as 3 cartas aplicando a razão oficial de Reposição
    Duel.DiscardDeck(tp, 3, REASON_EFFECT | REASON_REPLACE)
end

-- ==========================================================
-- Efeito 3: Enviada do Deck/Campo ao GY -> Comprar, Enviar e Adicionar à mão
-- ==========================================================
function s.drcon(e, tp, eg, ep, ev, re, r, rp)
    -- Garante que engatilhe caso venha do Deck ou do Campo
    return e:GetHandler():IsPreviousLocation(LOCATION_DECK | LOCATION_ONFIELD)
end

function s.grdfilter(c)
    -- Cruzamento de setcodes: Confirma se o monstro pertence simultaneamente ao set 0x278 e 0x52
    return c:IsFaceup() and c:IsSetCard(0x278) and c:IsSetCard(0x52)
end

function s.drtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then 
        -- Garante que existam no mínimo 2 cartas (1 para a compra e 1 para o envio sequencial)
        return Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) >= 2
            and Duel.IsPlayerCanDraw(tp, 1) and Duel.IsPlayerCanDiscardDeck(tp, 1) 
    end
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
    Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 0, tp, 1)
    Duel.SetPossibleOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
end

function s.drop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.Draw(tp, 1, REASON_EFFECT) > 0 then
        Duel.BreakEffect()
        if Duel.DiscardDeck(tp, 1, REASON_EFFECT) > 0 then
            
            -- "...then, if you control a Pyroland Guardian monster, you can add this card to your hand."
            if c:IsRelateToEffect(e) and Duel.IsExistingMatchingCard(s.grdfilter, tp, LOCATION_MZONE, 0, 1, nil) then
                -- Pergunta opcional para o jogador (cadastrar string 2)
                if Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
                    Duel.BreakEffect()
                    Duel.SendtoHand(c, nil, REASON_EFFECT)
                    Duel.ConfirmCards(1 - tp, c)
                end
            end
        end
    end
end