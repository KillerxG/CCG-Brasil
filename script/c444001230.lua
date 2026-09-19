-- The Vampire Castle
local s, id = GetID()

function s.initial_effect(c)
    -- Ativação com busca opcional
    local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Todos os monstros no Campo e GY viram DARK Zombie (exceto Vampire Hunter)
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE + LOCATION_GRAVE, LOCATION_MZONE + LOCATION_GRAVE)
    e2:SetCode(EFFECT_CHANGE_RACE)
    e2:SetTarget(s.typefilter)
    e2:SetValue(RACE_ZOMBIE)
    c:RegisterEffect(e2)
    
    local e3 = e2:Clone()
    e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e3:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(e3)

    -- Substituir custo de LP por envio do Deck para o GY
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS) -- Corrigido: Adicionado CONTINUOUS
    e4:SetCode(EFFECT_LPCOST_REPLACE)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCondition(s.lrcon)
    e4:SetOperation(s.lrop)
    c:RegisterEffect(e4)

    -- Retornar banido pro GY para Comprar 2 no próximo turno
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 1))
    e5:SetCategory(CATEGORY_TOGRAVE)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_FZONE)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e5:SetCountLimit(1)
    e5:SetTarget(s.drawtg)
    e5:SetOperation(s.drawop)
    c:RegisterEffect(e5)
end

s.listed_series = {0x8e}

-- ==========================================
-- EFEITO 1: BUSCA NA ATIVAÇÃO
-- ==========================================
function s.thfilter(c)
    return c:IsSetCard(0x8e) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.activate(e, tp, eg, ep, ev, re, r, rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local g = Duel.GetMatchingGroup(s.thfilter, tp, LOCATION_DECK, 0, nil)
    if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then -- "Deseja adicionar 1 monstro Vampire?"
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local sg = g:Select(tp, 1, 1, nil)
        Duel.SendtoHand(sg, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, sg)
    end
end

-- ==========================================
-- EFEITO 2 & 3: TORNAR DARK ZOMBIE
-- ==========================================
function s.typefilter(e, c)
    -- Ajuste o setcode (0x108e) se o seu "Vampire Hunter" tiver um código diferente no seu CDB.
    return not c:IsSetCard(0x108e) 
end

-- ==========================================
-- EFEITO 4: SUBSTITUIR CUSTO DE LP
-- ==========================================
function s.lrfilter(c)
    return c:IsSetCard(0x8e) and c:IsAbleToGraveAsCost()
end
function s.lrcon(e, tp, eg, ep, ev, re, r, rp)
    if tp ~= ep then return false end
    if not re or not re:IsActivated() then return false end
    local rc = re:GetHandler()
    -- Verifica se quem pede o custo é "Vampire" e se tem carta para enviar pro GY
    return rc:IsSetCard(0x8e) and Duel.IsExistingMatchingCard(s.lrfilter, tp, LOCATION_DECK, 0, 1, nil)
end
function s.lrop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.lrfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoGrave(g, REASON_COST)
    end
end

-- ==========================================
-- EFEITO 5: RETORNAR BANIDO E DRAW 2
-- ==========================================
function s.tdfilter(c)
    return c:IsSetCard(0x8e) and c:IsFaceup() and c:IsAbleToGrave()
end
function s.drawtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.tdfilter, tp, LOCATION_REMOVED, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectTarget(tp, s.tdfilter, tp, LOCATION_REMOVED, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g, 1, 0, 0)
end
function s.drawop(e, tp, eg, ep, ev, re, r, rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc, REASON_EFFECT + REASON_RETURN) > 0 then
        -- Registra a compra dupla na próxima Draw Phase
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_DRAW_COUNT)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1, 0)
        e1:SetValue(2)
        e1:SetReset(RESET_PHASE + PHASE_DRAW + RESET_SELF_TURN, 1)
        Duel.RegisterEffect(e1, tp)
    end
end