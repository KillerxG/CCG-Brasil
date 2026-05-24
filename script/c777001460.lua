-- Silver Fangs' Inner Light
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Ativação Padrão da Magia Contínua
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- Efeito 1: Ganhar LP quando cartas vão para o GY (Contínuo/Inerente - Sem Corrente)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_TO_GRAVE)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCondition(s.reccon)
    e1:SetOperation(s.recop)
    c:RegisterEffect(e1)

    -- Efeito 2: Monstros "Silver Fangs" podem atacar diretamente
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_DIRECT_ATTACK)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_MZONE, 0)
    e2:SetCondition(s.dircon)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard, 0x307))
    c:RegisterEffect(e2)

    -- Efeito 3: Dano de ataque direto se torna 1000 (Se não controlar a Kyara)
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_PRE_BATTLE_DAMAGE)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.damcon)
    e3:SetOperation(s.damop)
    c:RegisterEffect(e3)

    -- Efeito 4: Banir do GY para ganhar LP igual ao ATK de 1 monstro
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_RECOVER)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCountLimit(1, id) -- HOPT
    e4:SetCondition(s.gycon)
    e4:SetCost(aux.bfgcost) -- Custo nativo de banir do GY
    e4:SetTarget(s.gytg)
    e4:SetOperation(s.gyop)
    c:RegisterEffect(e4)
end

-- ====================================================================
-- Efeito 1: Recuperar LP (Inerente)
-- ====================================================================
function s.reccon(e, tp, eg, ep, ev, re, r, rp)
    -- Confirma se alguma carta do grupo de cartas enviadas realmente chegou no GY
    return eg:IsExists(Card.IsLocation, 1, nil, LOCATION_GRAVE)
end

function s.recop(e, tp, eg, ep, ev, re, r, rp)
    -- Pisca a carta na tela para indicar a origem do ganho de vida
    Duel.Hint(HINT_CARD, 0, id)
    Duel.Recover(tp, 500, REASON_EFFECT)
end

-- ====================================================================
-- Efeito 2: Atacar Diretamente
-- ====================================================================
function s.dircon(e)
    local tp = e:GetHandlerPlayer()
    return Duel.GetLP(tp) > Duel.GetLP(1 - tp)
end

-- ====================================================================
-- Efeito 3: Mudança de Dano (Sem Kyara)
-- ====================================================================
function s.kyarafilter(c)
    -- Procura o ID 777001320 pelo nome original
    return c:IsFaceup() and c:GetOriginalCode() == 777001320
end

function s.damcon(e, tp, eg, ep, ev, re, r, rp)
    local a = Duel.GetAttacker()
    return ep == 1 - tp 
        and a and a:IsControler(tp) and a:IsSetCard(0x307) 
        and Duel.GetAttackTarget() == nil 
        and Duel.GetLP(tp) > Duel.GetLP(1 - tp)
        and not Duel.IsExistingMatchingCard(s.kyarafilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.damop(e, tp, eg, ep, ev, re, r, rp)
    Duel.ChangeBattleDamage(ep, 1000)
end

-- ====================================================================
-- Efeito 4: Banir do GY para Ganhar Vida
-- ====================================================================
function s.gycon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetLP(tp) < Duel.GetLP(1 - tp)
end

function s.gyfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x307) and c:GetAttack() > 0
end

function s.gytg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.gyfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.gyfilter, tp, LOCATION_MZONE, 0, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g = Duel.SelectTarget(tp, s.gyfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, g:GetFirst():GetAttack())
end

function s.gyop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.Recover(tp, tc:GetAttack(), REASON_EFFECT)
    end
end