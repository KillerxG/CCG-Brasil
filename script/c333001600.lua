local s, id = GetID()
local SET_MR = 0x215b
local HALL_AWAKENED = 333001640
local POLARITY_AWAKENED = 333001590

function s.initial_effect(c)
    -- 1. Efeito de Ativação (Invocar do Deck)
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOGRAVE + CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- 2. Efeito do Cemitério
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_POSITION + CATEGORY_SEARCH + CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.gycon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.gytg)
    e2:SetOperation(s.gyop)
    c:RegisterEffect(e2)
end
local s,id=GetID()
s.listed_card_types={TYPE_GEMINI}
-- ==========================================
-- Efeito 1: Enviar para o GY e Invocar
-- ==========================================
function s.tgfilter(c, e, tp)
    return (c:IsType(TYPE_NORMAL) or c:IsType(TYPE_GEMINI)) and c:IsAbleToGrave()
        and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil, e, tp, c:GetAttribute())
end
function s.spfilter(c, e, tp, attr)
    return c:IsSetCard(SET_MR) and c:IsAttribute(attr) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingMatchingCard(s.tgfilter, tp, LOCATION_DECK, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_DECK)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g1 = Duel.SelectMatchingCard(tp, s.tgfilter, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
    if #g1 > 0 then
        local tc = g1:GetFirst()
        local attr = tc:GetOriginalAttribute()
        if Duel.SendtoGrave(tc, REASON_EFFECT) > 0 and tc:IsLocation(LOCATION_GRAVE) then
            if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
            local g2 = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil, e, tp, attr)
            if #g2 > 0 then
                Duel.SpecialSummon(g2, 0, tp, tp, false, false, POS_FACEUP)
            end
        end
    end
end

-- ==========================================
-- Efeito 2: Cemitério (Recuperar + Efeito Bônus)
-- ==========================================
function s.cfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_EFFECT)
        and (c:GetFlagEffect(HALL_AWAKENED)>0
            or c:GetFlagEffect(POLARITY_AWAKENED)>0
            or (c:IsType(TYPE_GEMINI) and c:IsGeminiState()))
end
function s.gycon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_MZONE, 0, 1, nil)
end
function s.thfilter(c)
    return c:IsSetCard(SET_MR) and c:IsAbleToHand()
end
function s.gytg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) and chkc ~= e:GetHandler() end
    if chk == 0 then return Duel.IsExistingTarget(s.thfilter, tp, LOCATION_GRAVE, 0, 1, e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectTarget(tp, s.thfilter, tp, LOCATION_GRAVE, 0, 1, 1, e:GetHandler())
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, 0)
end

-- Filtros auxiliares para os efeitos extras
function s.fire_search(c, code)
    return c:IsCode(code) and c:IsAbleToHand()
end
function s.water_sp(c, e, tp)
    if not (c:IsType(TYPE_NORMAL) or c:IsType(TYPE_GEMINI)) or not c:IsCanBeSpecialSummoned(e, 0, tp, false, false) then return false end
    local g = Duel.GetMatchingGroup(s.cfilter, tp, LOCATION_MZONE, 0, nil)
    for gc in aux.Next(g) do
        if gc:GetLevel() == c:GetLevel() then return true end
    end
    return false
end
-- Filtro Corrigido de LUZ
function s.light_neg_filter(c)
    return c:IsFaceup() and not c:IsDisabled() and (c:IsType(TYPE_EFFECT) or (c:GetOriginalType()&TYPE_EFFECT)~=0)
end

function s.gyop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc, nil, REASON_EFFECT) > 0 then
        Duel.ConfirmCards(1-tp, tc)
        
        -- Verifica os atributos dos Geminis no campo
        local att = 0
        local geminis = Duel.GetMatchingGroup(s.cfilter, tp, LOCATION_MZONE, 0, nil)
        for gc in aux.Next(geminis) do
            att = bit.bor(att, gc:GetAttribute())
        end
        
        -- Checa se as condições dos efeitos extras podem ser resolvidas
        local b1 = bit.band(att, ATTRIBUTE_EARTH) ~= 0 and Duel.IsExistingMatchingCard(Card.IsCanTurnSet, tp, 0, LOCATION_MZONE, 1, nil)
        local b2 = bit.band(att, ATTRIBUTE_FIRE) ~= 0 and Duel.IsExistingMatchingCard(s.fire_search, tp, LOCATION_DECK, 0, 1, nil, tc:GetCode())
        local b3 = bit.band(att, ATTRIBUTE_WATER) ~= 0 and Duel.IsExistingMatchingCard(s.water_sp, tp, LOCATION_DECK, 0, 1, nil, e, tp)
        local b4 = bit.band(att, ATTRIBUTE_LIGHT) ~= 0 and Duel.IsExistingMatchingCard(s.light_neg_filter, tp, 0, LOCATION_MZONE, 1, nil)
        
        if (b1 or b2 or b3 or b4) and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
            local ops = {}
            local opval = {}
            local off = 1
            if b1 then ops[off] = aux.Stringid(id, 1) opval[off] = 1 off = off + 1 end
            if b2 then ops[off] = aux.Stringid(id, 2) opval[off] = 2 off = off + 1 end
            if b3 then ops[off] = aux.Stringid(id, 3) opval[off] = 3 off = off + 1 end
            if b4 then ops[off] = aux.Stringid(id, 4) opval[off] = 4 off = off + 1 end
            
            local op = Duel.SelectOption(tp, table.unpack(ops))
            local sel = opval[op + 1]
            
            if sel == 1 then
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_POSCHANGE)
                local sg = Duel.SelectMatchingCard(tp, Card.IsCanTurnSet, tp, 0, LOCATION_MZONE, 1, 1, nil)
                if #sg > 0 then Duel.ChangePosition(sg, POS_FACEDOWN_DEFENSE) end
                
            elseif sel == 2 then
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
                local sg = Duel.SelectMatchingCard(tp, s.fire_search, tp, LOCATION_DECK, 0, 1, 1, nil, tc:GetCode())
                if #sg > 0 then
                    Duel.SendtoHand(sg, nil, REASON_EFFECT)
                    Duel.ConfirmCards(1-tp, sg)
                end
                
            elseif sel == 3 then
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
                local sg = Duel.SelectMatchingCard(tp, s.water_sp, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
                if #sg > 0 then Duel.SpecialSummon(sg, 0, tp, tp, false, false, POS_FACEUP) end
                
            elseif sel == 4 then
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
                local sg = Duel.SelectMatchingCard(tp, s.light_neg_filter, tp, 0, LOCATION_MZONE, 1, 1, nil)
                local sc = sg:Select(tp, 1, 1, nil):GetFirst()
                if sc then
                    local code = sc:GetOriginalCodeRule()
                    local c = e:GetHandler()
                    
                    -- Nega na transição e no Campo/Cemitério
                    local e1 = Effect.CreateEffect(c)
                    e1:SetType(EFFECT_TYPE_FIELD)
                    e1:SetCode(EFFECT_DISABLE)
                    e1:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
                    e1:SetTarget(s.distg)
                    e1:SetLabel(code)
                    e1:SetReset(RESET_PHASE + PHASE_END)
                    Duel.RegisterEffect(e1, tp)
                    
                    local e2 = Effect.CreateEffect(c)
                    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
                    e2:SetCode(EVENT_CHAIN_SOLVING)
                    e2:SetCondition(s.discon)
                    e2:SetOperation(s.disop)
                    e2:SetLabel(code)
                    e2:SetReset(RESET_PHASE + PHASE_END)
                    Duel.RegisterEffect(e2, tp)
                end
            end
        end
    end
end

-- Lógica para o efeito de LUZ negar
function s.distg(e, c)
    return c:GetOriginalCodeRule() == e:GetLabel()
end
function s.discon(e, tp, eg, ep, ev, re, r, rp)
    return re:GetHandler():GetOriginalCodeRule() == e:GetLabel()
end
function s.disop(e, tp, eg, ep, ev, re, r, rp)
    Duel.NegateEffect(ev)
end