-- East Wings Awakening
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Invocação-Ritual
    local e1 = Ritual.AddProcGreater(c, {
        filter = s.ritual_fil,
        location = LOCATION_HAND,
        extrafil = s.extrafil,
        extraop = s.extraop
    })
    
    -- Efeito 2: Efeito no GY (Colocar na Zona S&T e embaralhar no Deck)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_LEAVE_GRAVE | CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetTarget(s.gytg)
    e2:SetOperation(s.gyop)
    c:RegisterEffect(e2)
end

s.listed_series = {0x314}

-- ==========================================================
-- Efeito 1: Lógicas de Invocação e Materiais Extras
-- ==========================================================

function s.ritual_fil(c)
    return c:IsSetCard(0x314) and c:IsRitualMonster()
end

function s.stmatfilter(c)
    return c:IsFaceup() and c:IsOriginalType(TYPE_MONSTER) and c:IsContinuousSpell() and c:IsAbleToGrave()
end

function s.extrafil(e, tp, eg, ep, ev, re, r, rp, chk)
    return Duel.GetMatchingGroup(s.stmatfilter, tp, LOCATION_SZONE, LOCATION_SZONE, nil)
end

function s.extraop(mat, e, tp, eg, ep, ev, re, r, rp, tc)
    -- 1. Isola e envia as cartas da Zona de Magias e Armadilhas ao GY
    local stmat = mat:Filter(Card.IsLocation, nil, LOCATION_SZONE)
    if #stmat > 0 then
        Duel.SendtoGrave(stmat, REASON_EFFECT | REASON_MATERIAL | REASON_RITUAL)
        mat:Sub(stmat) -- Remove elas do grupo base para não serem processadas duas vezes
    end
    
    -- 2. Tributa rigorosamente o restante dos materiais (da Mão e Zona de Monstros)
    if #mat > 0 then
        Duel.ReleaseRitualMaterial(mat)
    end
end

-- ==========================================================
-- Efeito 2: Repescagem e Reciclagem do Cemitério
-- ==========================================================

function s.plfilter(c)
    return c:IsSetCard(0x314) and c:IsMonster() and not c:IsForbidden()
end

function s.gytg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.plfilter(chkc) end
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
            and Duel.IsExistingTarget(s.plfilter, tp, LOCATION_GRAVE, 0, 1, nil)
            and c:IsAbleToDeck()
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOFIELD)
    local g = Duel.SelectTarget(tp, s.plfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, g, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, c, 1, 0, 0)
end

function s.gyop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    
    if tc and tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 then
        if Duel.MoveToField(tc, tp, tp, LOCATION_SZONE, POS_FACEUP, true) then
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CHANGE_TYPE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetValue(TYPE_SPELL | TYPE_CONTINUOUS)
            e1:SetReset(RESET_EVENT | RESETS_STANDARD - RESET_TURN_SET)
            tc:RegisterEffect(e1)
            
            if c:IsRelateToEffect(e) then
                Duel.BreakEffect()
                Duel.SendtoDeck(c, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
            end
        end
    end
end