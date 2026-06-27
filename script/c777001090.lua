-- Phantom Gunners Chaotic Mission
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 0: Você só pode controlar 1 "Phantom Gunners Chaotic Mission"
    c:SetUniqueOnField(1, 0, id)

    -- Ativação da Magia Contínua
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- Efeito 1: Efeito Contínuo (Não gera corrente) -> Enviar 2 cartas do topo
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.millcon)
    e2:SetOperation(s.millop)
    c:RegisterEffect(e2)

    -- Efeito 2: Ignition -> Colocar "Soul Levy" do déqui ou GY virada para cima
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1, id)
    e3:SetCondition(s.placecon)
    e3:SetTarget(s.placetg)
    e3:SetOperation(s.placeop)
    c:RegisterEffect(e3)
end

-- ====================================================================
-- Efeito 1: Gatilho Contínuo (Sem Corrente)
-- ====================================================================
function s.spfilter(c, tp)
    -- Verifica se o monstro Invocado é "Phantom Gunner" e caiu do seu lado do campo
    return c:IsSetCard(0x302) and c:IsControler(tp)
end

function s.millcon(e, tp, eg, ep, ev, re, r, rp)
    -- Dispara a verificação sempre que a invocação for bem sucedida
    return eg:IsExists(s.spfilter, 1, nil, tp)
end

function s.millop(e, tp, eg, ep, ev, re, r, rp)
    -- Aplica o envio das cartas para o GY sem abrir corrente
	Duel.Hint(HINT_CARD,1-tp,id)
    Duel.DiscardDeck(1 - tp, 2, REASON_EFFECT)
end

-- ====================================================================
-- Efeito 2: Colocar "Soul Levy"
-- ====================================================================
function s.killerfilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777000960
end

function s.placecon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.killerfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.slfilter(c)
    -- Código 87844926 pertence à Armadilha "Soul Levy"
    return c:IsCode(87844926) and not c:IsForbidden()
end

function s.placetg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
        and Duel.IsExistingMatchingCard(s.slfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) end
end

function s.placeop(e, tp, eg, ep, ev, re, r, rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp, LOCATION_SZONE) <= 0 then return end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOFIELD)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.slfilter), tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
    local tc = g:GetFirst()
    
    if tc then
        -- Move a Armadilha diretamente para a Zona de Magias/Armadilhas virada para cima
        Duel.MoveToField(tc, tp, tp, LOCATION_SZONE, POS_FACEUP, true)
    end
end