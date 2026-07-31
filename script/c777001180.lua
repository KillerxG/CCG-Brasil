-- Timerx Pharmacist
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Retornado ao déqui -> Special Summon
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EVENT_TO_DECK)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Efeito 2: Special Summoned do déqui -> Alvejar, Revelar e Copiar Nome
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.namecon)
    e2:SetTarget(s.nametg)
    e2:SetOperation(s.nameop)
    c:RegisterEffect(e2)

    -- Efeito 3: No Cemitério + Controlar Chronos -> Fusion Summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_FUSION_SUMMON + CATEGORY_TODECK)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, id + 2)
    e3:SetCondition(s.fuscon)
    e3:SetTarget(s.fustg)
    e3:SetOperation(s.fusop)
    c:RegisterEffect(e3)
end

-- ====================================================================
-- Efeito 1: Retornado ao déqui -> Special Summon
-- ====================================================================
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
    end
end

-- ====================================================================
-- Efeito 2: Invocado do déqui -> Alvejar e Substituir Fusão Visualmente
-- ====================================================================
function s.namecon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end

function s.cfilter(c)
    if not c:IsType(TYPE_FUSION) or type(c.material) ~= "table" then return false end
    for _, code in ipairs(c.material) do
        if type(code) == "number" then return true end
    end
    return false
end

function s.nametg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    -- Target 1 monster on the field
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
    if chk == 0 then return Duel.IsExistingTarget(Card.IsFaceup, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil)
        and Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_EXTRA, 0, 1, nil) end
        
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, Card.IsFaceup, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil)
end

function s.nameop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    
    -- Revela a Fusão do Extra Deck na resolução
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local g = Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_EXTRA, 0, 1, 1, nil)
    
    if #g > 0 then
        Duel.ConfirmCards(1 - tp, g)
        local fc = g:GetFirst()
        
        -- Garante que o alvo continua virado para cima
        if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
            local check = {}
            local codes = {}
            
            for _, code in ipairs(fc.material) do
                if type(code) == "number" and not check[code] then
                    table.insert(codes, code)
                    check[code] = true
                end
            end
            
            if #codes > 0 then
                local sel_code = codes[1]
                
                -- Se houver mais de um material específico, usa o menu visual de Tokens!
                if #codes > 1 then
                    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CODE)
                    local cg = Group.CreateGroup()
                    for _, code in ipairs(codes) do
                        local token = Duel.CreateToken(tp, code)
                        cg:AddCard(token)
                    end
                    local sel_card = cg:Select(tp, 1, 1, nil):GetFirst()
                    sel_code = sel_card:GetCode()
                end
                
                -- Aplica o nome ao alvo
                local e1 = Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e1:SetCode(EFFECT_CHANGE_CODE)
                e1:SetValue(sel_code)
                e1:SetReset(RESET_EVENT + RESETS_STANDARD)
                tc:RegisterEffect(e1)
            end
        end
    end
    
    -- Trava do Extra Deck para o resto do turno
    local e2 = Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    e2:SetDescription(aux.Stringid(id, 3))
    e2:SetTargetRange(1, 0)
    e2:SetTarget(s.splimit)
    e2:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(e2, tp)
end

function s.splimit(e, c, sump, sumtype, sumpos, targetp, se)
    return c:IsLocation(LOCATION_EXTRA) and not (c:IsType(TYPE_FUSION) or c:IsRace(RACE_PSYCHIC))
end

-- ====================================================================
-- Efeito 3: Invocação-Fusão puxando materiais do Cemitério para o déqui
-- ====================================================================
function s.chronosfilter(c)
    return c:IsFaceup() and c:GetOriginalCodeRule() == 777000640
end

function s.fuscon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.chronosfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.matfilter(c)
    -- Exige que a carta possa ser um material de fusão e possa voltar ao déqui
    return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end

function s.fusfilter(c, e, tp)
    -- Verifica se o monstro pode ser invocado e se há materiais válidos no GY
    return c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_FUSION, tp, false, false)
        and c:CheckFusionMaterial(Duel.GetMatchingGroup(s.matfilter, tp, LOCATION_GRAVE, 0, nil), nil, tp)
end

function s.fustg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.fusfilter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_GRAVE)
end

function s.fusop(e, tp, eg, ep, ev, re, r, rp)
    -- Puxa estritamente os materiais disponíveis no Cemitério
    local mg = Duel.GetMatchingGroup(s.matfilter, tp, LOCATION_GRAVE, 0, nil)
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local tg = Duel.SelectMatchingCard(tp, s.fusfilter, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp)
    local tc = tg:GetFirst()
    
    if tc then
        -- O jogador seleciona exatamente as peças necessárias
        local mat = Duel.SelectFusionMaterial(tp, tc, mg, nil, tp)
        tc:SetMaterial(mat)
        
        -- Embaralha os materiais selecionados no déqui
        Duel.SendtoDeck(mat, nil, SEQ_DECKSHUFFLE, REASON_EFFECT + REASON_MATERIAL + REASON_FUSION)
        Duel.BreakEffect()
        
        -- Invoca a Fusão perfeitamente
        Duel.SpecialSummon(tc, SUMMON_TYPE_FUSION, tp, tp, false, false, POS_FACEUP)
        tc:CompleteProcedure()
    end
end