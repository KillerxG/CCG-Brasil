-- Phantom Gunners Sniper
-- Scripted by Gemini
local s, id = GetID()
Duel.LoadScript("proc_union_mod.lua")
function s.initial_effect(c)
	-- Union Procedure
	aux.AddUnionProcedureMod(c,s.unionfilter,true,true)
    -- Efeito 1: Special Summon Inerente (Da mão) enviando 1 "Phantom Gunners" para o GY
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Efeito 2: Equipada a um "Phantom Gunners" -> Oponente não ativa efeitos no GY
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_ACTIVATE)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(0, 1) -- Afeta o oponente
    e2:SetCondition(s.eqcon)
    e2:SetValue(s.aclimit)
    c:RegisterEffect(e2)

    -- Efeito 3: Enviado do Campo para o GY -> Mill 4, Reviver -> Restrição
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_DECKDES + CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCountLimit(1, id + 1)
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
function s.spfilter(c, tp)
    -- Confere se é um Phantom Gunners e se enviar pro GY libera espaço suficiente
    return c:IsSetCard(0x302) and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp, c) > 0
end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    return Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_ONFIELD, 0, 1, nil, tp)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, c)
    local g = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_ONFIELD, 0, nil, tp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local tc = g:SelectUnselect(nil, tp, false, true, 1, 1)
    if tc then
        e:SetLabelObject(tc)
        return true
    end
    return false
end

function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
    local tc = e:GetLabelObject()
    if tc then
        Duel.SendtoGrave(tc, REASON_COST)
    end
end

-- ====================================================================
-- Efeito 2: Floodgate de Cemitério enquanto equipada
-- ====================================================================
function s.eqcon(e)
    local c = e:GetHandler()
    local ec = c:GetEquipTarget()
    -- Confere se está ativamente equipada e se o monstro alvo é um Phantom Gunners
    return ec and ec:IsSetCard(0x302)
end

function s.aclimit(e, re, tp)
    -- Trava estritamente qualquer ativação que ocorra dentro do Cemitério
    return re:GetActivateLocation() == LOCATION_GRAVE
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
        e1:SetDescription(aux.Stringid(id, 1))
        e1:SetTargetRange(1, 0)
        e1:SetTarget(s.splimit)
        e1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(e1, tp)
    end
end