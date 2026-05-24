-- Silver Fangs Cleric
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Material Extra da Mão (Micro Coder Framework)
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

    -- Efeito 2: Revelar e Ganhar LP
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_RECOVER)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1, id + 1)
    e2:SetCost(s.lpcost)
    e2:SetTarget(s.lptg)
    e2:SetOperation(s.lpop)
    c:RegisterEffect(e2)

    -- Efeito 3: Buscar do GY + Retornar para a mão (se controlar Kyara)
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetCountLimit(1, id + 2)
    e3:SetCondition(s.thcon)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end

-- ====================================================================
-- Efeito 1: Material Link da Mão
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
-- Efeito 2: Revelar e Ganhar LP
-- ====================================================================
function s.lpcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return not e:GetHandler():IsPublic() end
    Duel.ConfirmCards(1 - tp, e:GetHandler())
end

function s.lptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local ct = Duel.GetFieldGroupCount(tp, LOCATION_HAND, LOCATION_HAND)
    if chk == 0 then return ct > 0 end
    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, ct * 200)
end

function s.lpop(e, tp, eg, ep, ev, re, r, rp)
    local ct = Duel.GetFieldGroupCount(tp, LOCATION_HAND, LOCATION_HAND)
    if ct > 0 then
        Duel.Recover(tp, ct * 200, REASON_EFFECT)
    end
end

-- ====================================================================
-- Efeito 3: Buscar 1 outro "Silver Fangs" do GY e Retornar esta carta
-- ====================================================================
function s.thcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()
    return c:IsLocation(LOCATION_GRAVE) and r == REASON_LINK and rc:IsSetCard(0x307)
end

function s.thfilter(c)
    return c:IsSetCard(0x307) and c:IsAbleToHand()
end

function s.kyarafilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777001320
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) and chkc ~= c end
    if chk == 0 then return Duel.IsExistingTarget(s.thfilter, tp, LOCATION_GRAVE, 0, 1, c) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectTarget(tp, s.thfilter, tp, LOCATION_GRAVE, 0, 1, 1, c)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, 0)
    -- Info possível para a própria carta voltar do GY para a mão
    Duel.SetPossibleOperationInfo(0, CATEGORY_TOHAND, c, 1, tp, LOCATION_GRAVE)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    local c = e:GetHandler()
    
    if tc and tc:IsRelateToEffect(e) then
        if Duel.SendtoHand(tc, nil, REASON_EFFECT) > 0 and tc:IsLocation(LOCATION_HAND) then
            Duel.ConfirmCards(1 - tp, tc)
            
            -- Após adicionar, se Kyara estiver no campo e o Cleric ainda estiver no GY, pergunta
            if c:IsRelateToEffect(e) and Duel.IsExistingMatchingCard(s.kyarafilter, tp, LOCATION_MZONE, 0, 1, nil) then
                if Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
                    Duel.BreakEffect()
                    Duel.SendtoHand(c, nil, REASON_EFFECT)
                    Duel.ConfirmCards(1 - tp, c)
                end
            end
        end
    end
end