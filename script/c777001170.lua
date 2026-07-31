-- Timerx Bio-Engineer - Nathan
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)

    -- Efeito 1: Se retornar ao déqui -> Special Summon
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EVENT_TO_DECK)
	e2:SetCountLimit(1, id)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    -- Efeito 2: Se Special Summoned do déqui -> Revelar Fusão e trocar nome
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1, id+1)
    e3:SetCondition(s.drcon)
    e3:SetCost(s.namecost)
    e3:SetOperation(s.nameop)
    c:RegisterEffect(e3)

    -- Efeito 3: No Cemitério (Ignition) -> Embaralhar no déqui
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_TODECK)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1, id+2)
    e4:SetCondition(s.tdcon)
    e4:SetTarget(s.tdtg)
    e4:SetOperation(s.tdop)
    c:RegisterEffect(e4)
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
-- Efeito 2: Se Special Summoned do déqui -> Revelar Fusão e trocar nome
-- ====================================================================
function s.drcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
function s.cfilter(c)
    if not c:IsType(TYPE_FUSION) or type(c.material) ~= "table" then return false end
    for _, code in ipairs(c.material) do
        if type(code) == "number" then return true end
    end
    return false
end

function s.namecost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_EXTRA, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local g = Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_EXTRA, 0, 1, 1, nil)
    Duel.ConfirmCards(1 - tp, g)
    e:SetLabelObject(g:GetFirst())
end

function s.nameop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = e:GetLabelObject()
    
    if tc and c:IsRelateToEffect(e) and c:IsFaceup() then
        local check = {}
        local codes = {}
        
        for _, code in ipairs(tc.material) do
            if type(code) == "number" and not check[code] then
                table.insert(codes, code)
                check[code] = true
            end
        end
        
        if #codes > 0 then
            local sel_code = codes[1]
            
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
            
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetCode(EFFECT_CHANGE_CODE)
            e1:SetValue(sel_code)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD)
            c:RegisterEffect(e1)
        end
    end
    
    local e2 = Effect.CreateEffect(c)
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
-- Efeito 3: No Cemitério -> Embaralhar
-- ====================================================================
function s.chronosfilter(c)
    return c:IsFaceup() and c:GetOriginalCodeRule() == 777000640
end

function s.tdcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.chronosfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.tdtg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToDeck() end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, c, 1, 0, 0)
end

function s.tdop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoDeck(c, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
    end
end