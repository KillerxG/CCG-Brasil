-- Silver Fangs' Starlight Ascension
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Negar, Curar e Setar (Kyara)
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DISABLE + CATEGORY_RECOVER)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id)
    e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E + TIMING_END_PHASE)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Efeito 2: Banir do GY para ataques extras
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.atkcon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.atktg)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)
end

-- ====================================================================
-- Efeito 1: Negar, Curar e Reciclar (Set)
-- ====================================================================
function s.filter1(c)
    -- O seu alvo: monstro Silver Fangs
    return c:IsFaceup() and c:IsSetCard(0x307)
end

function s.kyarafilter(c)
    -- Procura a Kyara pelo nome original
    return c:IsFaceup() and c:GetOriginalCode() == 777001320
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return false end 
    if chk == 0 then return Duel.IsExistingTarget(s.filter1, tp, LOCATION_MZONE, 0, 1, nil)
        and Duel.IsExistingTarget(aux.disfilter, tp, 0, LOCATION_ONFIELD, 1, nil) end
    
    -- Seleciona o primeiro alvo (Seu monstro)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g1 = Duel.SelectTarget(tp, s.filter1, tp, LOCATION_MZONE, 0, 1, 1, nil)
    e:SetLabelObject(g1:GetFirst())
    
    -- Seleciona o segundo alvo (Carta do oponente)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_NEGATE)
    local g2 = Duel.SelectTarget(tp, aux.disfilter, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
    
    Duel.SetOperationInfo(0, CATEGORY_DISABLE, g2, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, g1:GetFirst():GetAttack())
end

function s.activate(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
    if not g then return end
    
    local tc1 = e:GetLabelObject()
    local tc2 = g:Filter(function(card) return card ~= tc1 end, nil):GetFirst()
    
    -- Bloco de Negação
    if tc2 and tc2:IsFaceup() and tc2:IsRelateToEffect(e) and not tc2:IsDisabled() then
        Duel.NegateRelatedChain(tc2, RESET_TURN_SET)
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc2:RegisterEffect(e1)
        local e2 = Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetValue(RESET_TURN_SET)
        e2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc2:RegisterEffect(e2)
        
        if not tc2:IsImmuneToEffect(e1) and not tc2:IsImmuneToEffect(e2) and tc1 and tc1:IsRelateToEffect(e) and tc1:IsFaceup() then
            -- Recupera o LP
            if Duel.Recover(tp, tc1:GetAttack(), REASON_EFFECT) > 0 then
                
                -- Checa a Kyara e pergunta se quer Setar
                if c:IsRelateToEffect(e) and c:IsCanTurnSet() 
                    and Duel.IsExistingMatchingCard(s.kyarafilter, tp, LOCATION_MZONE, 0, 1, nil) then
                    
                    if Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
                        Duel.BreakEffect()
                        c:CancelToGrave() 
                        Duel.ChangePosition(c, POS_FACEDOWN) 
                        Duel.RaiseEvent(c, EVENT_SSET, e, REASON_EFFECT, tp, tp, 0)
                    end
                end
            end
        end
    end
end

-- ====================================================================
-- Efeito 2: Banir do GY para Ataques Extras
-- ====================================================================
function s.atkcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetLP(tp) > Duel.GetLP(1 - tp)
end

function s.atktg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter1(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.filter1, tp, LOCATION_MZONE, 0, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, s.filter1, tp, LOCATION_MZONE, 0, 1, 1, nil)
end

function s.atkop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    
    local p_lp = Duel.GetLP(tp)
    local o_lp = Duel.GetLP(1 - tp)
    local diff = p_lp > o_lp and (p_lp - o_lp) or 0
    local ct = math.floor(diff / 1000)
    
    if ct > 0 and tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        local e1 = Effect.CreateEffect(e:GetHandler())
        -- O SEGREDO DO HINT VISUAL FICA AQUI:
        e1:SetDescription(aux.Stringid(id, 3))
        e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EXTRA_ATTACK)
        e1:SetValue(ct)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(e1)
    end
end