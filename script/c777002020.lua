-- Rockslash Dragon
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Regra Oficial: Você só pode Invocar esta carta por Invocação-Especial uma vez por turno
    c:SetSPSummonOnce(id)

    -- Efeito 1: Procedimento de Invocação-Especial Inerente (da Mão)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Efeito 2: Dano Contínuo por Special Summon do Oponente (Não inicia corrente)
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_MZONE)
    e2:SetOperation(s.damop1)
    c:RegisterEffect(e2)

    -- Efeito 3: Gatilho de Dano de Efeito -> Queimar baseado no ATK do Monstro no GY
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DAMAGE_STEP)
    e3:SetCode(EVENT_DAMAGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id)
    e3:SetCondition(s.descon)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)
end

-- ====================================================================
-- Filtro Global da Haruna
-- ====================================================================
function s.harunafilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777002010
end

-- ====================================================================
-- Efeito 1: Invocação-Especial por Envio de Cartas (CORRIGIDO)
-- ====================================================================
function s.spfilter(c, ec)
    -- Filtra outras cartas "Rockslash" e proíbe estritamente que a carta selecionada seja ela mesma (c ~= ec)
    return c:IsSetCard(0x309) and c:IsAbleToGraveAsCost() and c ~= ec
end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    -- Passa a própria carta 'c' para dentro do filtro para servir de bloqueio
    local g = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_HAND + LOCATION_ONFIELD, 0, nil, c)
    return aux.SelectUnselectGroup(g, e, tp, 2, 2, aux.ChkfMMZ(1), 0)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp)
    -- Puxa o handler (a própria carta) do evento de forma segura e ignora os parâmetros instáveis da engine
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_HAND + LOCATION_ONFIELD, 0, nil, c)
    local sg = aux.SelectUnselectGroup(g, e, tp, 2, 2, aux.ChkfMMZ(1), 1, tp, HINTMSG_TOGRAVE, nil, nil, true)
    if #sg > 0 then
        sg:KeepAlive()
        e:SetLabelObject(sg)
        return true
    end
    return false
end

function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
    local sg = e:GetLabelObject()
    if not sg then return end
    Duel.SendtoGrave(sg, REASON_COST)
    sg:DeleteGroup()
end

-- ====================================================================
-- Efeito 2: Dano Contínuo por Special Summon
-- ====================================================================
function s.damop1(e, tp, eg, ep, ev, re, r, rp)
    -- Varre o grupo de monstros invocados para ver se pelo menos 1 é do oponente
    if eg:IsExists(Card.IsControler, 1, nil, 1 - tp) then
        -- Sinal visual na tela (a carta "pisca" no canto) para avisar da onde veio o dano
        Duel.Hint(HINT_CARD, 0, id)
        Duel.Damage(1 - tp, 400, REASON_EFFECT)
    end
end

-- ====================================================================
-- Efeito 3: Gatilho de Dano de Efeito (Alvejar no GY)
-- ====================================================================
function s.descon(e, tp, eg, ep, ev, re, r, rp)
    return (r & REASON_EFFECT) ~= 0
end

function s.tgfilter(c)
    -- Deve ser um monstro para podermos puxar o ATK original
    return c:IsType(TYPE_MONSTER)
end

function s.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.tgfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.tgfilter, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g = Duel.SelectTarget(tp, s.tgfilter, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, 1, nil)
    
    local tc = g:GetFirst()
    local atk = tc:GetBaseAttack()
    if atk < 0 then atk = 0 end
    local dam = math.floor(atk / 2)
    
    -- Projeta o dano total se a Haruna já estiver em campo
    if Duel.IsExistingMatchingCard(s.harunafilter, tp, LOCATION_MZONE, 0, 1, nil) then
        dam = atk
    end
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dam)
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        local atk = tc:GetBaseAttack()
        if atk < 0 then atk = 0 end
        local dam = math.floor(atk / 2)
        
        -- Confere a Haruna dinamicamente no momento exato em que o dano for aplicado
        if Duel.IsExistingMatchingCard(s.harunafilter, tp, LOCATION_MZONE, 0, 1, nil) then
            dam = atk
        end
        if dam > 0 then
            Duel.Damage(1 - tp, dam, REASON_EFFECT)
        end
    end
end