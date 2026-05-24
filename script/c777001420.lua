-- Silver Fangs Lancer
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

    -- Efeito 2: Normal/Special Summon -> Reviver e Ganhar LP
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_RECOVER)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1, id + 1)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
    -- Clona o efeito para a Special Summon
    local e3 = e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    -- Efeito 3: Enviado como material Link -> Comprar carta
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_DRAW)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_BE_MATERIAL)
    e4:SetCountLimit(1, id + 2)
    e4:SetCondition(s.drcon)
    e4:SetTarget(s.drtg)
    e4:SetOperation(s.drop)
    c:RegisterEffect(e4)
end

-- ====================================================================
-- Efeito 1: Material Link da Mão (Idêntico ao Cleric)
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
-- Efeito 2: Reviver do GY e Ganhar LP
-- ====================================================================
function s.spfilter(c, e, tp)
    return c:IsSetCard(0x307) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc, e, tp) end
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingTarget(s.spfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.spfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
    -- Cura projetada
    Duel.SetPossibleOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, 400)
end

function s.kyarafilter(c)
    -- Procura a Kyara pelo ID do nome original
    return c:IsFaceup() and c:GetOriginalCode() == 777001320
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    -- Se reviver com sucesso, checa a Kyara
    if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        if Duel.IsExistingMatchingCard(s.kyarafilter, tp, LOCATION_MZONE, 0, 1, nil) then
            Duel.Recover(tp, 400, REASON_EFFECT)
        end
    end
end

-- ====================================================================
-- Efeito 3: Comprar 1 carta
-- ====================================================================
function s.drcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()
    return c:IsLocation(LOCATION_GRAVE) and r == REASON_LINK and rc:IsSetCard(0x307)
end

function s.drtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDraw(tp, 1) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.drop(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    Duel.Draw(p, d, REASON_EFFECT)
end