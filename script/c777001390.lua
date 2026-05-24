-- Silver Fangs Archer
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Extra Material da Mão (Micro Coder Framework)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetRange(LOCATION_HAND)
    e1:SetCode(EFFECT_EXTRA_MATERIAL)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1, 0)
    e1:SetCountLimit(1, id)
    e1:SetOperation(s.extracon)
    e1:SetValue(s.extraval)
    c:RegisterEffect(e1)
    
    if s.flagmap == nil then
        s.flagmap = {}
    end
    if s.flagmap[c] == nil then
        s.flagmap[c] = {}
    end

    -- Efeito 2: Invocação-Especial da mão + Zerar ATK (Kyara)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    -- Efeito 3: Enviado como material Link -> Destruir e Ganhar LP
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_DESTROY + CATEGORY_RECOVER)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetCountLimit(1, id + 2)
    e3:SetCondition(s.descon)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)
end

-- ====================================================================
-- Efeito 1: Material Link da Mão (Padrão Micro Coder)
-- ====================================================================
function s.extrafilter(c, tp)
    return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end

function s.extracon(c, e, tp, sg, mg, lc, og, chk)
    return (sg + mg):Filter(s.extrafilter, nil, e:GetHandlerPlayer()):IsExists(Card.IsSetCard, 1, og, 0x307) and
           sg:FilterCount(s.flagcheck, nil) < 2
end

function s.flagcheck(c)
    return c:GetFlagEffect(id) > 0
end

function s.extraval(chk, summon_type, e, ...)
    local c = e:GetHandler()
    if chk == 0 then
        local tp, sc = ...
        if summon_type ~= SUMMON_TYPE_LINK or not sc:IsSetCard(0x307) or Duel.GetFlagEffect(tp, id) > 0 
           or Duel.GetLP(tp) <= Duel.GetLP(1 - tp) then
            return Group.CreateGroup()
        else
            table.insert(s.flagmap[c], c:RegisterFlagEffect(id, 0, 0, 1))
            return Group.FromCards(c)
        end
    elseif chk == 1 then
        local sg, sc, tp = ...
        if summon_type & SUMMON_TYPE_LINK == SUMMON_TYPE_LINK and #sg > 0 then
            Duel.Hint(HINT_CARD, tp, id)
            Duel.RegisterFlagEffect(tp, id, RESET_PHASE | PHASE_END, 0, 1)
        end
    elseif chk == 2 then
        for _, eff in ipairs(s.flagmap[c]) do
            eff:Reset()
        end
        s.flagmap[c] = {}
    end
end

-- ====================================================================
-- Efeito 2: Special Summon + Zerar ATK
-- ====================================================================
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetFieldGroup(tp, LOCATION_MZONE, 0)
    return #g == 0 or g:FilterCount(function(c) return c:IsFaceup() and c:IsSetCard(0x307) end, nil) == #g
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.kyarafilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777001320
end

-- Filtro adicionado para garantir que o monstro tem ATK > 0
function s.atkfilter(c)
    return c:IsFaceup() and c:GetAttack() > 0
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        if Duel.IsExistingMatchingCard(s.kyarafilter, tp, LOCATION_MZONE, 0, 1, nil) then
            -- Aplica o filtro de ATK > 0 na busca
            local g = Duel.GetMatchingGroup(s.atkfilter, tp, 0, LOCATION_MZONE, nil)
            if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATKDEF)
                local sg = g:Select(tp, 1, 1, nil)
                local tc = sg:GetFirst()
                if tc then
                    local e1 = Effect.CreateEffect(c)
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetCode(EFFECT_SET_ATTACK_FINAL)
                    e1:SetValue(0)
                    e1:SetReset(RESET_EVENT + RESETS_STANDARD)
                    tc:RegisterEffect(e1)
                end
            end
        end
    end
end

-- ====================================================================
-- Efeito 3: Destruir e Ganhar LP (Gatilho de Material Link)
-- ====================================================================
function s.descon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()
    return c:IsLocation(LOCATION_GRAVE) and r == REASON_LINK and rc:IsSetCard(0x307)
end

function s.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1 - tp) end
    if chk == 0 then return Duel.IsExistingTarget(nil, tp, 0, LOCATION_MZONE, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, nil, tp, 0, LOCATION_MZONE, 1, 1, nil)
    
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, g:GetFirst():GetBaseAttack() / 2)
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        local atk = tc:GetBaseAttack()
        if atk < 0 then atk = 0 end
        
        if Duel.Destroy(tc, REASON_EFFECT) > 0 then
            Duel.Recover(tp, math.floor(atk / 2), REASON_EFFECT)
        end
    end
end