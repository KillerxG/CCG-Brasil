-- Celestial Guardian - Grarl
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Special Summon da mão se houver Equip Spell no campo (Efeito de Ignição)
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

    -- Efeito 2: Mudar monstro do oponente para Posição de Defesa (Face-down)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_POSITION)
    e2:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET | EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1, {id, 2})
    e2:SetTarget(s.postg)
    e2:SetOperation(s.posop)
    c:RegisterEffect(e2)

    -- Clone do Efeito 2 para engatilhar também em Special Summons
    local e3 = e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    -- Efeito 3: Negar ativação de efeito de Monstro (Efeito Rápido)
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
function s.eqcfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsSpell()
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    -- Varre ambos os lados do campo procurando por qualquer Magia de Equipamento ativa
    return Duel.IsExistingMatchingCard(s.eqcfilter, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil)
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
-- Efeito 2: Mudar para Defesa com a face para baixo
-- ==========================================================
function s.posfilter(c)
    -- Filtra ignorando Monstros Link e Tokens nativamente
    return c:IsFaceup() and c:IsCanTurnSet()
end

function s.postg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1 - tp) and s.posfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.posfilter, tp, 0, LOCATION_MZONE, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_POSCHANGE)
    local g = Duel.SelectTarget(tp, s.posfilter, tp, 0, LOCATION_MZONE, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_POSITION, g, 1, 0, 0)
end

function s.posop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.ChangePosition(tc, POS_FACEDOWN_DEFENSE)
    end
end

-- ==========================================================
-- Efeito 3: Negar Ativação de Monstro
-- ==========================================================
function s.my_eqfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsSpell()
end

function s.negcon(e, tp, eg, ep, ev, re, r, rp)
    -- Confirma se a carta ativada é do oponente, se é um efeito de Monstro e se você controla um Equipamento
    return rp == 1 - tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
        and Duel.IsExistingMatchingCard(s.my_eqfilter, tp, LOCATION_ONFIELD, 0, 1, nil)
end

function s.negcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    -- Pode banir tanto do campo (MZone) quanto do GY
    if chk == 0 then return c:IsAbleToRemoveAsCost() end
    Duel.Remove(c, POS_FACEUP, REASON_COST)
end

function s.negtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
    -- Se o monstro estiver no campo e puder ser destruído, registra a possibilidade
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0)
    end
end

function s.negop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg, REASON_EFFECT)
    end
end