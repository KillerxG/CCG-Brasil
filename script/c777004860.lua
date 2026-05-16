-- East Wing Fighter
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Descartar para colocar 1 monstro "East Wings" do Deck na S&T Zone como Magia Contínua
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCost(s.plcost)
    e1:SetTarget(s.pltg)
    e1:SetOperation(s.plop)
    c:RegisterEffect(e1)

    -- Efeito 2: Se enviada da Zona de Magias e Armadilhas para o Cemitério -> Destruir 1 carta do oponente
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DESTROY)
    -- EFFECT_FLAG_DELAY garante que o "If" (Se) não perca o timing caso ela seja enviada no meio de uma Chain [1]
    e2:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET | EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end

s.listed_series = {0x314}
s.listed_names = {id}

-- ==========================================================
-- Efeito 1: Descartar como custo e Colocar na Zona S&T
-- ==========================================================
function s.plcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsDiscardable() end
    Duel.SendtoGrave(c, REASON_COST | REASON_DISCARD)
end

function s.plfilter(c)
    return c:IsSetCard(0x314) and c:IsMonster() and not c:IsCode(id) and not c:IsForbidden()
end

function s.pltg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
            and Duel.IsExistingMatchingCard(s.plfilter, tp, LOCATION_DECK, 0, 1, nil)
    end
end

function s.plop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_SZONE) <= 0 then return end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOFIELD)
    local g = Duel.SelectMatchingCard(tp, s.plfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    local tc = g:GetFirst()
    
    -- Utiliza a função moderna para alocar perfeitamente do Deck para a zona [2]
    if tc and Duel.MoveToField(tc, tp, tp, LOCATION_SZONE, POS_FACEUP, true) then
        -- O EDOPro exige forçar o tipo Magia Contínua após o acoplamento para consolidar as propriedades
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_TYPE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetValue(TYPE_SPELL | TYPE_CONTINUOUS)
        e1:SetReset(RESET_EVENT | RESETS_STANDARD - RESET_TURN_SET)
        tc:RegisterEffect(e1)
    end
end

-- ==========================================================
-- Efeito 2: Destruir ao ser enviada da S&T para o GY
-- ==========================================================
function s.descon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    -- Checa se a localidade imediatamente anterior à chegada ao GY era a S&T Zone 
    return c:IsPreviousLocation(LOCATION_SZONE)
end

function s.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(1 - tp) and chkc:IsOnField() end
    if chk == 0 then return Duel.IsExistingTarget(nil, tp, 0, LOCATION_ONFIELD, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    -- O nil serve perfeitamente aqui como filtro para "qualquer carta"
    local g = Duel.SelectTarget(tp, nil, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc, REASON_EFFECT)
    end
end