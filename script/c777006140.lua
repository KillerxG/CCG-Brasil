-- Celestial Guardian - Kay'est
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Special Summon da mão (Efeito de Ignição)
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Efeito 2: Adicionar à mão 1 carta "Celestial Guardian" ou Equip Spell banida
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET | EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1, {id, 2})
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
    
    local e3 = e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    -- Efeito 3: Negar ativação de Magia (Efeito Rápido)
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_NEGATE | CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_CHAINING)
    e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP | EFFECT_FLAG_DAMAGE_CAL)
    e4:SetRange(LOCATION_MZONE | LOCATION_GRAVE)
    e4:SetCountLimit(1, {id, 3})
    e4:SetCondition(s.negcon)
    e4:SetCost(s.negcost)
    e4:SetTarget(s.negtg)
    e4:SetOperation(s.negop)
    c:RegisterEffect(e4)
end

s.listed_series = {0x252}
s.listed_names = {id}

-- ==========================================================
-- Efeito 1: Invocação da Mão
-- ==========================================================
function s.eqfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsSpell()
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    -- Verifica se qualquer jogador possui uma Magia de Equipamento no campo
    return Duel.IsExistingMatchingCard(s.eqfilter, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
    end
end

-- ==========================================================
-- Efeito 2: Buscar carta banida (Removed)
-- ==========================================================
function s.thfilter(c)
    -- Aceita cartas do arquétipo ou qualquer Magia de Equipamento
    return c:IsFaceup() and (c:IsSetCard(0x252) or (c:IsType(TYPE_EQUIP) and c:IsSpell())) and c:IsAbleToHand()
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.thfilter, tp, LOCATION_REMOVED, 0, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectTarget(tp, s.thfilter, tp, LOCATION_REMOVED, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, 0)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, tc)
    end
end

-- ==========================================================
-- Efeito 3: Negar Ativação de Magia
-- ==========================================================
function s.my_eqfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsSpell()
end

function s.negcon(e, tp, eg, ep, ev, re, r, rp)
    -- Confirma se a carta ativada é do oponente, se é do tipo Magia (Spell) e se o jogador controla um Equipamento
    return rp == 1 - tp and re:IsActiveType(TYPE_SPELL) and Duel.IsChainNegatable(ev)
        and Duel.IsExistingMatchingCard(s.my_eqfilter, tp, LOCATION_ONFIELD, 0, 1, nil)
end

function s.negcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    -- Custo genérico de banimento para poder operar em duas áreas diferentes da arena
    if chk == 0 then return c:IsAbleToRemoveAsCost() end
    Duel.Remove(c, POS_FACEUP, REASON_COST)
end

function s.negtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
    -- Se o objeto no tabuleiro for passível de destruição, atestamos a informação formalmente
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0)
    end
end

function s.negop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg, REASON_EFFECT)
    end
end