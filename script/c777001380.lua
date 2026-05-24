-- Silver Fangs Knight - Oliver
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

    -- Efeito 2: Normal/Special Summon -> Ganhar LP + Destruir S/T (Sem alvo)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_RECOVER + CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1, id + 1)
    e2:SetTarget(s.sumtg)
    e2:SetOperation(s.sumop)
    c:RegisterEffect(e2)
    local e3 = e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    -- Efeito 3: Enviado como material Link -> Enviar do Deck pro GY (Foolish Burial)
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_TOGRAVE)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_BE_MATERIAL)
    e4:SetCountLimit(1, id + 2)
    e4:SetCondition(s.tgcon)
    e4:SetTarget(s.tgtg)
    e4:SetOperation(s.tgop)
    c:RegisterEffect(e4)
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
-- Efeito 2: Ganhar LP e (opcional) Destruir S/T (Sem Alvo)
-- ====================================================================
function s.kyarafilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777001320
end

function s.stfilter(c)
    return c:IsType(TYPE_SPELL + TYPE_TRAP)
end

function s.sumtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, 800)
    -- Possível destruição (não dá alvo, então não passamos a carta específica aqui)
    Duel.SetPossibleOperationInfo(0, CATEGORY_DESTROY, nil, 1, 1 - tp, LOCATION_ONFIELD)
end

function s.sumop(e, tp, eg, ep, ev, re, r, rp)
    -- Primeiro, o ganho de vida (Obrigatório)
    if Duel.Recover(tp, 800, REASON_EFFECT) > 0 then
        -- Depois, checa a Kyara e os possíveis alvos para destruição
        local g = Duel.GetMatchingGroup(s.stfilter, tp, 0, LOCATION_ONFIELD, nil)
        if Duel.IsExistingMatchingCard(s.kyarafilter, tp, LOCATION_MZONE, 0, 1, nil) and #g > 0 then
            -- Pergunta se o jogador quer destruir
            if Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
                local sg = g:Select(tp, 1, 1, nil)
                Duel.HintSelection(sg)
                Duel.Destroy(sg, REASON_EFFECT)
            end
        end
    end
end

-- ====================================================================
-- Efeito 3: Enviar do Deck pro GY (Gatilho de Material Link)
-- ====================================================================
function s.tgcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()
    return c:IsLocation(LOCATION_GRAVE) and r == REASON_LINK and rc:IsSetCard(0x307)
end

function s.tgfilter(c)
    return c:IsSetCard(0x307) and c:IsAbleToGrave()
end

function s.tgtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.tgfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
end

function s.tgop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.tgfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoGrave(g, REASON_EFFECT)
    end
end