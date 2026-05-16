-- Cute Shinob Beast - Monkey
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Busca 1 "Cute Shinob" do Deck e opcionalmente 1 "Polymerization" do Deck/GY
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND | CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1, {id, 1})
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    
    -- Clone para Invocação-Especial (compartilhando o mesmo HOPT)
    local e2 = e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)

    -- Efeito 2: Se enviado para o GY como material de Fusão/Link, invocar na próxima Standby Phase
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetCountLimit(1, {id, 2})
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

s.listed_series = {0x267}
s.listed_names = {id, 24094653} -- Registra Polymerization

-- ==========================================================
-- Efeito 1: Busca do Monstro e da Polymerization
-- ==========================================================
function s.thfilter(c)
    return c:IsSetCard(0x267) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.polyfilter(c)
    return c:IsCode(24094653) and c:IsAbleToHand()
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    
    -- "then you can add"
    if #g > 0 and Duel.SendtoHand(g, nil, REASON_EFFECT) > 0 then
        Duel.ConfirmCards(1 - tp, g)
        
        -- Aplica filtro NecroValley para lidar de forma legal com buscas no cemitério
        local pg = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.polyfilter), tp, LOCATION_DECK | LOCATION_GRAVE, 0, nil)
        if #pg > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
            local spg = pg:Select(tp, 1, 1, nil)
            Duel.SendtoHand(spg, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, spg)
        end
    end
end

-- ==========================================================
-- Efeito 2: Gatilho no GY e Invocação Adiada (Delayed Summon)
-- ==========================================================
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()
    -- Confirma que foi material para Fusão/Link e o destino é do arquétipo
    return c:IsLocation(LOCATION_GRAVE) and r & (REASON_FUSION | REASON_LINK) ~= 0 
        and rc and rc:IsSetCard(0x267)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    -- A Special Summon não ocorre agora, então o OperationInfo não engloba ela de imediato
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        -- Cria a "bomba relógio" na forma de um Efeito Contínuo no campo que vai checar a Standby
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE | PHASE_STANDBY)
        e1:SetCountLimit(1)
        e1:SetLabelObject(c)
        e1:SetCondition(s.standbycon)
        e1:SetOperation(s.standbyop)
        
        -- Determina quantos turnos ele precisa aguardar: 
        -- Se for usado de material bem no meio da SUA Standby Phase, a "próxima" será apenas no próximo turno (2). 
        -- Caso contrário, será no fim da rodada/começo do seu turno atual (1).
        local reset_count = (Duel.GetTurnPlayer() == tp and Duel.GetCurrentPhase() == PHASE_STANDBY) and 2 or 1
        e1:SetReset(RESET_PHASE | PHASE_STANDBY | RESET_SELF_TURN, reset_count)
        
        Duel.RegisterEffect(e1, tp)
    end
end

-- Rotinas da Invocação Adiada
function s.standbycon(e, tp, eg, ep, ev, re, r, rp)
    -- Garante que só seja engatilhado na SUA Standby Phase 
    return Duel.GetTurnPlayer() == tp
end

function s.standbyop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetLabelObject()
    if c:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) then
        
        Duel.Hint(HINT_CARD, 0, id) -- Exibe visualmente a carta brilhando quando a Standby chegar
        if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
            -- Prende uma "algema" que a banirá quando sair de campo
            local e1 = Effect.CreateEffect(c)
            e1:SetDescription(3300) -- String sistêmica: "Banish when it leaves the field"
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE | EFFECT_FLAG_CLIENT_HINT)
            e1:SetReset(RESET_EVENT | RESETS_REDIRECT)
            e1:SetValue(LOCATION_REMOVED)
            c:RegisterEffect(e1, true)
        end
    end
    -- Descarta o efeito depois de cumprir seu papel, não importa o que aconteça
    e:Reset() 
end