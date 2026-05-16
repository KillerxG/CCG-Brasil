-- East Wings Sanctuary
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Ativação Padrão da Magia de Campo
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- Efeito 1: Cartas "East Wings" na sua Zona S&T não podem ser destruídas por efeitos
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_SZONE, 0)
    e2:SetTarget(s.indtg)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- Efeito 2: Colocar 1 monstro do GY do oponente na S&T Zone dele e destruir 1 Magia/Armadilha
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_LEAVE_GRAVE | CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1, {id, 1})
    e3:SetCondition(s.plcon)
    e3:SetTarget(s.pltg)
    e3:SetOperation(s.plop)
    c:RegisterEffect(e3)

    -- Efeito 3: Se um "East Wings" Monster Card é colocado face para cima na S&T Zone -> Comprar 1
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_DRAW)
    e4:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_MOVE)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1, {id, 2})
    e4:SetCondition(s.drcon)
    e4:SetTarget(s.drtg)
    e4:SetOperation(s.drop)
    c:RegisterEffect(e4)
end

s.listed_series = {0x314}

-- ==========================================================
-- Efeito 1: Proteção
-- ==========================================================
function s.indtg(e, c)
    return c:IsFaceup() and c:IsSetCard(0x314)
end

-- ==========================================================
-- Efeito 2: Capturar do GY e Destruir
-- ==========================================================
function s.ritfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x314) and c:IsRitualMonster()
end

function s.plcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.ritfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.pltg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1 - tp) and chkc:IsMonster() end
    -- Verifica se o oponente (1 - tp) tem espaço na retaguarda dele para receber a carta 
    if chk == 0 then return Duel.GetLocationCount(1 - tp, LOCATION_SZONE) > 0
        and Duel.IsExistingTarget(Card.IsMonster, tp, 0, LOCATION_GRAVE, 1, nil) end
        
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g = Duel.SelectTarget(tp, Card.IsMonster, tp, 0, LOCATION_GRAVE, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, g, 1, 0, 0)
end

function s.desfilter(c)
    return c:IsSpellTrap()
end

function s.plop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    -- Confirma se a carta ainda é válida e se o oponente ainda tem o espaço livre após correntes [2]
    if tc and tc:IsRelateToEffect(e) and Duel.GetLocationCount(1 - tp, LOCATION_SZONE) > 0 then
        if Duel.MoveToField(tc, tp, 1 - tp, LOCATION_SZONE, POS_FACEUP, true) then
            local e1 = Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CHANGE_TYPE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetValue(TYPE_SPELL | TYPE_CONTINUOUS)
            e1:SetReset(RESET_EVENT | RESETS_STANDARD - RESET_TURN_SET)
            tc:RegisterEffect(e1)
            
            -- Lógica da destruição opcional
            local dg = Duel.GetMatchingGroup(s.desfilter, tp, 0, LOCATION_ONFIELD, nil)
            if #dg > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
                local sg = dg:Select(tp, 1, 1, nil)
                Duel.HintSelection(sg)
                Duel.Destroy(sg, REASON_EFFECT)
            end
        end
    end
end

-- ==========================================================
-- Efeito 3: Compra por Acomodamento S&T
-- ==========================================================
function s.drawcfilter(c, tp)
    -- Garante que o monstro é do arquétipo, chegou face para cima na S&T e NÃO estava lá antes
    -- (isso evita que mover um monstro de uma zona de magia para outra acione o efeito)
    return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_SZONE)
        and c:IsSetCard(0x314) and c:IsOriginalType(TYPE_MONSTER) 
        and not c:IsPreviousLocation(LOCATION_SZONE)
end

function s.drcon(e, tp, eg, ep, ev, re, r, rp)
    return not Duel.IsDamageStep() and eg:IsExists(s.drawcfilter, 1, nil, tp)
end

function s.drtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDraw(tp, 1) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.drop(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    Duel.Draw(p, d, REASON_EFFECT)
end