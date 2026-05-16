-- Celestial Guardian Ascension
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Invocação-Ritual Personalizada
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON | CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.rittg)
    e1:SetOperation(s.ritop)
    c:RegisterEffect(e1)

    -- Efeito 2: Banir do GY, equipar do Deck e banir todos os monstros do GY
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_REMOVE | CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, {id, 1})
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.eqtg)
    e2:SetOperation(s.eqop)
    c:RegisterEffect(e2)
end

s.listed_series = {0x252}
s.listed_names = {777006120, 34022290}

-- ==========================================================
-- Efeito 1: Lógica de Invocação-Ritual e Restrições
-- ==========================================================
function s.matfilter1(c, tp)
    return c:IsAbleToRemove(tp, POS_FACEUP, REASON_EFFECT | REASON_MATERIAL | REASON_RITUAL) and c:GetLevel() > 0
end

function s.get_ritual_materials(tp)
    local mg = Duel.GetMatchingGroup(s.matfilter1, tp, LOCATION_HAND | LOCATION_MZONE, 0, nil, tp)
    
    local eatos = Duel.GetFirstMatchingCard(function(c) return c:IsFaceup() and c:IsCode(34022290) end, tp, LOCATION_MZONE, 0, nil)
    if eatos then
        local opp_mg = Duel.GetMatchingGroup(s.matfilter1, tp, 0, LOCATION_MZONE, nil, tp)
        local opp_faceup = opp_mg:Filter(Card.IsFaceup, nil)
        mg:Merge(opp_faceup)
    end
    
    local deck_eatos = Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_DECK, 0, nil, 34022290)
    local valid_deck_eatos = deck_eatos:Filter(Card.IsAbleToRemove, nil, tp, POS_FACEUP, REASON_EFFECT | REASON_MATERIAL | REASON_RITUAL)
    mg:Merge(valid_deck_eatos)
    
    return mg
end

function s.check_ritual(sg, e, tp, mg)
    local sum = 0
    local deck_count = 0
    local has_field_eatos = false
    
    for c in aux.Next(sg) do
        if c:IsLocation(LOCATION_DECK) then
            deck_count = deck_count + 1
        end
        if c:IsFaceup() and c:IsCode(34022290) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) then
            has_field_eatos = true
        end
        sum = sum + c:GetLevel()
    end
    
    -- Regra 1: No máximo 1 "Guardian Eatos" extraída do Deck
    if deck_count > 1 then return false end
    
    -- Regra 2: A soma de níveis precisa ser 10 ou mais
    if sum < 10 then return false end
    
    -- Regra 3: Se você controla a "Guardian Eatos", você DEVE incluí-la
    local field_eatos = Duel.GetMatchingGroupCount(function(c) return c:IsFaceup() and c:IsCode(34022290) end, tp, LOCATION_MZONE, 0, nil)
    if field_eatos > 0 and not has_field_eatos then return false end
    
    -- Regra 4: Previne Tributo Excessivo (Impede selecionar cartas a mais do que o necessário)
    for c in aux.Next(sg) do
        if (sum - c:GetLevel()) >= 10 then
            local clone_valid = true
            
            if field_eatos > 0 then
                -- Usa sg:IsExists no lugar de aux.Next para não quebrar a iteração de memória
                local has_eatos2 = sg:IsExists(function(gc)
                    return gc ~= c and gc:IsFaceup() and gc:IsCode(34022290) and gc:IsLocation(LOCATION_MZONE) and gc:IsControler(tp)
                end, 1, nil)
                if not has_eatos2 then clone_valid = false end
            end
            
            if clone_valid then return false end
        end
    end
    return true
end

function s.ritfilter(c, e, tp)
    if not (c:IsCode(777006120) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_RITUAL, tp, false, true)) then return false end
    local mg = s.get_ritual_materials(tp)
    mg:RemoveCard(c)
    return aux.SelectUnselectGroup(mg, e, tp, 1, #mg, s.check_ritual, 0)
end

function s.rittg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.ritfilter, tp, LOCATION_HAND | LOCATION_GRAVE, 0, 1, nil, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND | LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, tp, LOCATION_HAND | LOCATION_MZONE | LOCATION_DECK)
end

function s.ritop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local tg = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.ritfilter), tp, LOCATION_HAND | LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    local tc = tg:GetFirst()
    if tc then
        local mg = s.get_ritual_materials(tp)
        mg:RemoveCard(tc)
        
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
        local mat = aux.SelectUnselectGroup(mg, e, tp, 1, #mg, s.check_ritual, 1, tp, HINTMSG_REMOVE)
        if mat and #mat > 0 then
            tc:SetMaterial(mat)
            if Duel.Remove(mat, POS_FACEUP, REASON_EFFECT | REASON_MATERIAL | REASON_RITUAL) > 0 then
                Duel.BreakEffect()
                Duel.SpecialSummon(tc, SUMMON_TYPE_RITUAL, tp, tp, false, true, POS_FACEUP)
                tc:CompleteProcedure()
            end
        end
    end
end

-- ==========================================================
-- Efeito 2: Efeito do Cemitério e Equipamento
-- ==========================================================
function s.cgtfilter(c, tp)
    return c:IsFaceup() and c:IsSetCard(0x252) and Duel.IsExistingMatchingCard(s.eqspfilter, tp, LOCATION_DECK, 0, 1, nil, c)
end

function s.eqspfilter(c, ec)
    return c:IsType(TYPE_EQUIP) and c:IsSpell() and c:CheckEquipTarget(ec)
end

function s.rmfilter(c)
    return c:IsMonster() and c:IsAbleToRemove()
end

function s.eqtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cgtfilter(chkc, tp) end
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.rmfilter, tp, LOCATION_GRAVE, 0, 1, nil)
           and Duel.IsExistingTarget(s.cgtfilter, tp, LOCATION_MZONE, 0, 1, nil, tp)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g = Duel.SelectTarget(tp, s.cgtfilter, tp, LOCATION_MZONE, 0, 1, 1, nil, tp)
    
    local rg = Duel.GetMatchingGroup(s.rmfilter, tp, LOCATION_GRAVE, 0, nil)
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, rg, #rg, tp, LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_EQUIP, nil, 1, tp, LOCATION_DECK)
end

function s.eqop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    local rg = Duel.GetMatchingGroup(s.rmfilter, tp, LOCATION_GRAVE, 0, nil)
    
    if #rg > 0 and Duel.Remove(rg, POS_FACEUP, REASON_EFFECT) > 0 then
        local og = Duel.GetOperatedGroup()
        local c = e:GetHandler()
        
        for oc in aux.Next(og) do
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CANNOT_TRIGGER)
            e1:SetReset(RESET_EVENT | RESETS_STANDARD)
            oc:RegisterEffect(e1)
        end
        
        if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
            local eqg = Duel.SelectMatchingCard(tp, s.eqspfilter, tp, LOCATION_DECK, 0, 1, 1, nil, tc)
            if #eqg > 0 then
                Duel.Equip(tp, eqg:GetFirst(), tc)
            end
        end
    end
end