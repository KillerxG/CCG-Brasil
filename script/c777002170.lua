-- Rockslash Fatal Temptation
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 0: Ativar da Mão se controlar a Haruna
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e0:SetCondition(s.handcon)
    c:RegisterEffect(e0)

    -- Efeito 1: Destruir 1 monstro e causar dano a ambos (Ring of Destruction style)
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DESTROY + CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.actcon)
    e1:SetTarget(s.acttg)
    e1:SetOperation(s.actop)
    c:RegisterEffect(e1)

    -- Efeito 2: Gatilho no GY (Oponente toma dano) -> Banir e causar 1000 de dano
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_DAMAGE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.gycon)
    e2:SetCost(s.gycost)
    e2:SetTarget(s.gytg)
    e2:SetOperation(s.gyop)
    c:RegisterEffect(e2)
end

-- ====================================================================
-- Efeito 0: Condição de Hand Trap
-- ====================================================================
function s.harunafilter(c)
    -- Checa se a "Master of Rockslash - Haruna" está no campo
    return c:IsFaceup() and c:GetOriginalCode() == 777002010
end

function s.handcon(e)
    local tp = e:GetHandlerPlayer()
    return Duel.IsExistingMatchingCard(s.harunafilter, tp, LOCATION_MZONE, 0, 1, nil)
end

-- ====================================================================
-- Efeito 1: Destruição e Dano Mútuo
-- ====================================================================
function s.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x309)
end

function s.actcon(e, tp, eg, ep, ev, re, r, rp)
    -- Condição: Você deve controlar um monstro "Rockslash"
    return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.acttg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1 - tp) end
    if chk == 0 then return Duel.IsExistingTarget(aux.TRUE, tp, 0, LOCATION_MZONE, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, aux.TRUE, tp, 0, LOCATION_MZONE, 1, 1, nil)
    
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
    -- Como a vida pode não sofrer dano se o monstro tiver 0 ATK, deixamos a informação genérica para o sistema
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, PLAYER_ALL, math.floor(g:GetFirst():GetBaseAttack() / 2))
end

function s.actop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    
    if tc and tc:IsRelateToEffect(e) then
        local atk = tc:GetBaseAttack()
        if atk < 0 then atk = 0 end
        
        -- Destrói a carta. Se a destruição for bem sucedida (e não negada/imune), aplica a quebra e o dano.
        if Duel.Destroy(tc, REASON_EFFECT) > 0 then
            Duel.BreakEffect()
            local dam = math.floor(atk / 2)
            -- O sistema de Yu-Gi-Oh! permite que ambos tomem dano na mesma resolução
            Duel.Damage(tp, dam, REASON_EFFECT)
            Duel.Damage(1 - tp, dam, REASON_EFFECT)
        end
    end
end

-- ====================================================================
-- Efeito 2: Engatilhar no GY e Queimar LP
-- ====================================================================
function s.gycon(e, tp, eg, ep, ev, re, r, rp)
    -- O dano ocorreu no oponente (ep == 1 - tp) e a Haruna está no campo
    return ep == 1 - tp and Duel.IsExistingMatchingCard(s.harunafilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.gycost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToRemoveAsCost() end
    Duel.Remove(c, POS_FACEUP, REASON_COST)
end

function s.gytg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, 1000)
end

function s.gyop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Damage(1 - tp, 1000, REASON_EFFECT)
end