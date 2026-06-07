-- Draconic Defense
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Negar Ataque -> Banir -> Encerrar Battle Phase -> Setar a Trap
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.atkcon)
    e1:SetTarget(s.atktg)
    e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)

    -- Efeito 2: Negar efeito que dê alvo em "Draconic" (Condição bônus: Blaze para banir)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DISABLE + CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.negcon)
    e2:SetCost(aux.bfgcost) -- Custo nativo para banir a si mesma do GY
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)
end

-- ====================================================================
-- Filtros Globais do Arquétipo
-- ====================================================================
function s.draconicfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x300)
end

function s.blazefilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777000680
end

-- ====================================================================
-- Efeito 1: Proteção de Batalha e Reciclagem (Set)
-- ====================================================================
function s.atkcon(e, tp, eg, ep, ev, re, r, rp)
    -- Confere se você tem um "Draconic" em campo no momento do ataque
    return Duel.IsExistingMatchingCard(s.draconicfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.atktg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(1 - tp) and chkc:IsLocation(LOCATION_ONFIELD) end
    if chk == 0 then return Duel.IsExistingTarget(nil, tp, 0, LOCATION_ONFIELD, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectTarget(tp, nil, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, 1, 0, 0)
end

function s.atkop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    
    -- Se o ataque for negado com sucesso, procede para o banimento
    if Duel.NegateAttack() then
        if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc, POS_FACEUP, REASON_EFFECT) > 0 then
            
            -- "then end the Battle Phase,"
            Duel.BreakEffect()
            Duel.SkipPhase(Duel.GetTurnPlayer(), PHASE_BATTLE, RESET_PHASE + PHASE_BATTLE_STEP, 1)
            
            -- "also, after that, Set this card face-down instead of sending it to the GY"
            if c:IsRelateToEffect(e) and c:IsCanTurnSet() then
                Duel.BreakEffect()
                c:CancelToGrave()
                Duel.ChangePosition(c, POS_FACEDOWN)
                Duel.RaiseEvent(c, EVENT_SSET, e, REASON_EFFECT, tp, tp, 0)
            end
        end
    end
end

-- ====================================================================
-- Efeito 2: Negar Alvo no Cemitério
-- ====================================================================
function s.tgfilter(c, tp)
    return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x300)
end

function s.negcon(e, tp, eg, ep, ev, re, r, rp)
    -- "except during the Damage Step"
    if Duel.GetCurrentPhase() == PHASE_DAMAGE or Duel.GetCurrentPhase() == PHASE_DAMAGE_CAL then return false end
    
    -- Verifica se o efeito dá alvo em alguma carta
    if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
    
    -- Puxa as cartas alvejadas e confere se pelo menos uma delas é seu monstro "Draconic"
    local tg = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    return tg and tg:IsExists(s.tgfilter, 1, nil, tp) and Duel.IsChainDisablable(ev)
end

function s.negtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_DISABLE, eg, 1, 0, 0)
end

function s.negop(e, tp, eg, ep, ev, re, r, rp)
    -- Nega o efeito na corrente
    if Duel.NegateEffect(ev) then
        -- Se você controlar o Blaze e a carta negada puder ser afetada, ela é banida
        if Duel.IsExistingMatchingCard(s.blazefilter, tp, LOCATION_MZONE, 0, 1, nil) then
            local rc = re:GetHandler()
            if rc:IsRelateToEffect(re) then
                Duel.BreakEffect()
                Duel.Remove(rc, POS_FACEUP, REASON_EFFECT)
            end
        end
    end
end