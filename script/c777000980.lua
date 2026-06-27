-- Phantom Gunners Enforcer - Kanna
-- Scripted by Gemini
local s, id = GetID()
Duel.LoadScript("proc_union_mod.lua")
function s.initial_effect(c)
	-- Union Procedure
	aux.AddUnionProcedureMod(c,s.unionfilter,true,true)
    -- Efeito 1: Special Summon Inerente (Da mão)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    -- OATH restringe estritamente a "1x por turno por este método"
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    -- Efeito 2: Equipada -> Se o oponente enviar carta do déqui para o GY -> Mill 4
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DECKDES)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.millcon)
    e2:SetTarget(s.milltg)
    e2:SetOperation(s.millop)
    c:RegisterEffect(e2)

    -- Efeito 3: Enviada do Campo para o GY -> Mill 4, Reviver -> Restrição
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_DECKDES + CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCountLimit(1, id + 2)
    e3:SetCondition(s.gycon)
    e3:SetTarget(s.gytg)
    e3:SetOperation(s.gyop)
    c:RegisterEffect(e3)
end
-- Union Procedure
function s.unionfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- ====================================================================
-- Efeito 1: Invocação-Especial da Mão
-- ====================================================================
function s.nonpgfilter(c)
    -- Verifica se existe algum monstro na sua MZone que NÃO SEJA um Phantom Gunners Face-up
    -- (Cartas baixadas/face-down também impedem a invocação, já que não revelam o arquétipo)
    return not (c:IsFaceup() and c:IsSetCard(0x302))
end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return false end
    
    local m_count = Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0)
    -- Permite se você não controlar monstros OU se todos forem Phantom Gunners
    if m_count == 0 then return true end
    return not Duel.IsExistingMatchingCard(s.nonpgfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

-- ====================================================================
-- Efeito 2: Mill 4 enquanto Equipada
-- ====================================================================
function s.millcfilter(c, tp)
    -- Confere se a carta caiu no Cemitério vinda diretamente do déqui do oponente
    return c:IsPreviousLocation(LOCATION_DECK) and c:IsPreviousControler(1 - tp)
end

function s.millcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
	local ec = c:GetEquipTarget()
    -- Confere se esta carta está ativamente equipada a um monstro e se o gatilho ocorreu
    return ec and ec:IsSetCard(0x302) and eg:IsExists(s.millcfilter, 1, nil, tp)
end

function s.milltg(e, tp, eg, ep, ev, re, r, rp, chk)
    -- Exige que o oponente tenha pelo menos 4 cartas no déqui para o efeito ser legal
    if chk == 0 then return Duel.GetFieldGroupCount(tp, 0, LOCATION_DECK) >= 4 end
    Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 0, 1 - tp, 4)
end

function s.millop(e, tp, eg, ep, ev, re, r, rp)
    Duel.DiscardDeck(1 - tp, 4, REASON_EFFECT)
end

-- ====================================================================
-- Efeito 3: Mill 4, Reviver e Trava do Extra Deck
-- ====================================================================
function s.gycon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end

function s.gytg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then 
        return Duel.GetFieldGroupCount(tp, 0, LOCATION_DECK) >= 4
            and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) 
    end
    Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 0, 1 - tp, 4)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.killerfilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777000960
end

function s.splimit(e, c, sump, sumtype, sumpos, targetp, se)
    return c:IsLocation(LOCATION_EXTRA) and not (c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_WARRIOR))
end

function s.gyop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    
    local ct = Duel.DiscardDeck(1 - tp, 4, REASON_EFFECT)
    local og = Duel.GetOperatedGroup()
    
    if ct > 0 and og:FilterCount(Card.IsLocation, nil, LOCATION_GRAVE) == 4 then
        if c:IsRelateToEffect(e) then
            Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
        end
    end
    
    if not Duel.IsExistingMatchingCard(s.killerfilter, tp, LOCATION_MZONE, 0, 1, nil) then
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
        e1:SetDescription(aux.Stringid(id, 2))
        e1:SetTargetRange(1, 0)
        e1:SetTarget(s.splimit)
        e1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(e1, tp)
    end
end