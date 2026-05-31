-- Master of Rockslash - Haruna
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Carta Nomi (Não pode ser Normal Summoned/Set)
    c:EnableReviveLimit()
    -- Limite oficial da Boss: Você só pode Invocar por Invocação-Especial a Haruna uma vez por turno
    c:SetSPSummonOnce(id)

    -- Efeito 1: Condição de Invocação-Especial
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    -- Efeito 2: Proteção - Indestrutível por efeitos que não dêem alvo nela
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetValue(s.indval)
    c:RegisterEffect(e2)

    -- Efeito 3: Dano de Batalha de monstros "Rockslash" vira Dano de Efeito (Vassal Rule)
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_BATTLE_DAMAGE_TO_EFFECT)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_MZONE, 0) -- Afeta o seu campo
    e3:SetTarget(s.bdtg)
    c:RegisterEffect(e3)

    -- Efeito 4: Gatilho - Monstro enviado para o GY do oponente -> 500 Dano
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_DAMAGE)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F) -- Gatilho Mandatório (Sem "You can")
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.damcon)
    e4:SetTarget(s.damtg)
    e4:SetOperation(s.damop)
    c:RegisterEffect(e4)

    -- Efeito 5: Quick Effect - Destruir e causar 600 Dano
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 1))
    e5:SetCategory(CATEGORY_DESTROY + CATEGORY_DAMAGE)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_MZONE)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e5:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E + TIMING_END_PHASE)
    e5:SetCountLimit(1, id) -- HOPT do Quick Effect
    e5:SetTarget(s.destg)
    e5:SetOperation(s.desop)
    c:RegisterEffect(e5)
end

-- ====================================================================
-- Efeito 1: Condição de Invocação-Especial (3 Nomes Diferentes)
-- ====================================================================
function s.spfilter(c)
    return c:IsSetCard(0x309) and c:IsType(TYPE_MONSTER) and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE))
end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    -- Pega todos os "Rockslash" válidos no Campo e Cemitério
    local g = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, nil)
    
    -- Checa se há espaço na mesa e se há pelo menos 3 códigos (nomes) originais diferentes no grupo
    return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and g:GetClassCount(Card.GetCode) >= 3
end

-- ====================================================================
-- Efeito 2: Proteção Contra Destruição Sem Alvo
-- ====================================================================
function s.indval(e, re, rp)
    -- Se o efeito que ativou NÃO possuir a flag de dar alvo, a Haruna é indestrutível (retorna true)
    if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
    -- Se tiver a flag de dar alvo, checa se a Haruna está entre as cartas escolhidas na Corrente
    local g = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
    return not g or not g:IsContains(e:GetHandler())
end

-- ====================================================================
-- Efeito 3: Converter Dano de Batalha -> Dano de Efeito
-- ====================================================================
function s.bdtg(e, c)
    -- Aplica a conversão apenas para monstros "Rockslash"
    return c:IsSetCard(0x309)
end

-- ====================================================================
-- Efeito 4: Gatilho de Envio pro GY do Oponente
-- ====================================================================
function s.cfilter(c, tp)
    -- Verifica se a carta que foi pro GY é monstro e está sob controle do oponente
    return c:IsType(TYPE_MONSTER) and c:IsControler(1 - tp)
end

function s.damcon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.cfilter, 1, nil, tp)
end

function s.damtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, 500)
end

function s.damop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Damage(1 - tp, 500, REASON_EFFECT)
end

-- ====================================================================
-- Efeito 5: Quick Effect (Destruir e Queimar)
-- ====================================================================
function s.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(1 - tp) and chkc:IsLocation(LOCATION_ONFIELD) end
    if chk == 0 then return Duel.IsExistingTarget(nil, tp, 0, LOCATION_ONFIELD, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, nil, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
    
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, 600)
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    -- Se a destruição tiver sucesso, aciona o dano de efeito
    if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc, REASON_EFFECT) > 0 then
        Duel.Damage(1 - tp, 600, REASON_EFFECT)
    end
end