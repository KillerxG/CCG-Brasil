-- Diabell, The Corrupt Goddess
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- ===============================================
    -- REGRAS E PROCEDIMENTO DE FUSÃO
    -- ===============================================
    c:EnableReviveLimit()
    Fusion.AddProcMix(c, true, true, s.matfilter1, s.matfilter2)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	
    -- ===============================================
    -- EFEITO 1: COPIAR NOME E EFEITOS 
    -- ===============================================
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET | EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.cpycon)
    e1:SetTarget(s.cpytg)
    e1:SetOperation(s.cpyop)
    c:RegisterEffect(e1)

    -- ===============================================
    -- EFEITO 2: BAIXAR MAGIA/ARMADILHA "SINFUL SPOILS"
    -- ===============================================
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
	e2:SetCategory(CATEGORY_SET)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1) -- "Once per turn" genérico (Soft Once Per Turn)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)

    -- ===============================================
    -- EFEITO 3: REVIVER DO CEMITÉRIO
    -- ===============================================
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCountLimit(1, id) -- Restrição estrita pelo ID (Hard Once Per Turn)
    e3:SetCondition(s.spcon)
    e3:SetCost(s.spcost)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

-- Filtros Básicos de Material de Fusão
function s.matfilter1(c)
    return c:IsSetCard(SET_DIABELL) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.matfilter2(c)
    return c:IsSetCard(SET_DIABELL) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
function s.matfil(c,tp)
	return c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_SZONE) or aux.SpElimFilter(c,false,true))
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(s.matfil,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,nil,tp)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST|REASON_MATERIAL)
end
-- ===============================================
-- LÓGICA DA INVOCAÇÃO DE CONTATO
-- ===============================================
function s.sprfilter(c)
    return c:IsSetCard(SET_DIABELL) and c:IsType(TYPE_MONSTER) 
        and (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK)) 
        and c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end

function s.rescon(sg, e, tp, mg)
    return Duel.GetLocationCountFromEx(tp, tp, sg, e:GetHandler()) > 0
        and sg:IsExists(s.matfilter1, 1, nil)
        and sg:IsExists(s.matfilter2, 1, nil)
end

function s.sprcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    local g = Duel.GetMatchingGroup(s.sprfilter, tp, LOCATION_MZONE | LOCATION_GRAVE, 0, nil)
    return aux.SelectUnselectGroup(g, e, tp, 2, 2, s.rescon, 0)
end

function s.sprtg(e, tp, eg, ep, ev, re, r, rp, chk, c)
    local g = Duel.GetMatchingGroup(s.sprfilter, tp, LOCATION_MZONE | LOCATION_GRAVE, 0, nil)
    local sg = aux.SelectUnselectGroup(g, e, tp, 2, 2, s.rescon, 1, tp, HINTMSG_REMOVE)
    if sg then
        sg:KeepAlive()
        e:SetLabelObject(sg)
        return true
    end
    return false
end

function s.sprop(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end
    Duel.Remove(g, POS_FACEUP, REASON_COST | REASON_MATERIAL | REASON_FUSION)
    c:SetMaterial(g)
    g:DeleteGroup()
end

-- ===============================================
-- LÓGICA DO EFEITO 1 (COPIAR "DIABELL" BANIDA)
-- ===============================================
function s.cpycon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end

function s.cpyfilter(c)
    -- Deve estar Faceup para podermos atestar que a carta possui o SetCode "Diabell"
    return c:IsFaceup() and c:IsSetCard(SET_DIABELL) and c:IsType(TYPE_MONSTER)
end

function s.cpytg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.cpyfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.cpyfilter, tp, LOCATION_REMOVED, 0, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, s.cpyfilter, tp, LOCATION_REMOVED, 0, 1, 1, nil)
end

function s.cpyop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and c:IsRelateToEffect(e) and c:IsFaceup() then
        local code = tc:GetOriginalCode()
        
        -- 1. Substitui o Nome da carta
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetCode(EFFECT_CHANGE_CODE)
        e1:SetValue(code)
        e1:SetReset(RESET_EVENT | RESETS_STANDARD)
        c:RegisterEffect(e1)
        
        -- 2. Absorve os Efeitos originais da carta escolhida
        c:CopyEffect(code, RESET_EVENT | RESETS_STANDARD, 1)
    end
end

-- ===============================================
-- LÓGICA DO EFEITO 2 (BAIXAR SINFUL SPOILS)
-- ===============================================
function s.setfilter(c)
    return c:IsSetCard(SET_SINFUL_SPOILS) and c:IsType(TYPE_SPELL | TYPE_TRAP) and c:IsSSetable()
end

function s.settg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.setfilter, tp, LOCATION_DECK | LOCATION_GRAVE, 0, 1, nil) end
end

function s.setop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.setfilter), tp, LOCATION_DECK | LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SSet(tp, g)
    end
end

-- ===============================================
-- LÓGICA DO EFEITO 3 (REVIVER DO GY)
-- ===============================================
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end

function s.spcostfilter(c)
    return c:IsSetCard(SET_SINFUL_SPOILS) and c:IsType(TYPE_SPELL | TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end

function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.spcostfilter, tp, LOCATION_GRAVE, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, s.spcostfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    Duel.Remove(g, POS_FACEUP, REASON_COST)
end

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