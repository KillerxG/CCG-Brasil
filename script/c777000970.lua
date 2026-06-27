-- Phantom Gunners Quartermaster - Richard
-- Scripted by Gemini
local s, id = GetID()
Duel.LoadScript("proc_union_mod.lua")
function s.initial_effect(c)
	-- Union Procedure
	aux.AddUnionProcedureMod(c,s.unionfilter,true,true)
    -- Efeito 1: Enviar 1 outro Union para o GY -> Special Summon do déqui (+ Equipar bônus)
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Efeito 2: Enviado do Campo para o GY -> Mill 2 do déqui, Reviver -> Restrição
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DECKDES + CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.gycon)
    e2:SetTarget(s.gytg)
    e2:SetOperation(s.gyop)
    c:RegisterEffect(e2)
end
-- Union Procedure
function s.unionfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- ====================================================================
-- Efeito 1: Custo, Invocação e Equipar Condicional
-- ====================================================================
function s.cfilter(c, e, tp)
    -- Checa se é Union (na MZone) ou originalmente Union (se estiver equipado na SZone)
    return (c:IsType(TYPE_UNION) or c:IsOriginalType(TYPE_UNION)) and c ~= e:GetHandler()
        and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp, c) > 0
end

function s.spfilter(c, e, tp)
    return c:IsType(TYPE_UNION) and c:IsSetCard(0x302) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_ONFIELD, 0, 1, nil, e, tp) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_ONFIELD, 0, 1, 1, nil, e, tp)
    Duel.SendtoGrave(g, REASON_COST)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_DECK, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
    Duel.SetPossibleOperationInfo(0, CATEGORY_EQUIP, nil, 1, tp, LOCATION_DECK)
end

function s.edfilter(c)
    -- Verifica se foi Invocado do Extra Deck
    return c:IsFaceup() and c:IsSummonLocation(LOCATION_EXTRA)
end

function s.eqfilter(c, tp)
    return c:IsSetCard(0x302) and c:IsType(TYPE_UNION) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end

function s.eqlimit(e, c)
    return c == e:GetLabelObject()
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
    
    if #g > 0 and Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        -- Verifica a condição para ativar o efeito bônus "then"
        if Duel.IsExistingMatchingCard(s.edfilter, tp, 0, LOCATION_MZONE, 1, nil) then
            if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
                and Duel.IsExistingMatchingCard(s.eqfilter, tp, LOCATION_DECK, 0, 1, nil, tp) then
                
                if Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
                    Duel.BreakEffect()
                    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
                    local eqg = Duel.SelectMatchingCard(tp, s.eqfilter, tp, LOCATION_DECK, 0, 1, 1, nil, tp)
                    local eqc = eqg:GetFirst()
                    
                    if eqc and Duel.Equip(tp, eqc, c) then
                        -- Registra os limites e o status nativo de Union
                        local e1 = Effect.CreateEffect(c)
                        e1:SetType(EFFECT_TYPE_SINGLE)
                        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                        e1:SetCode(EFFECT_EQUIP_LIMIT)
                        e1:SetValue(s.eqlimit)
                        e1:SetLabelObject(c)
                        e1:SetReset(RESET_EVENT + RESETS_STANDARD)
                        eqc:RegisterEffect(e1)
                        
                        local e2 = Effect.CreateEffect(c)
                        e2:SetType(EFFECT_TYPE_SINGLE)
                        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                        e2:SetCode(EFFECT_UNION_STATUS)
                        e2:SetReset(RESET_EVENT + RESETS_STANDARD)
                        eqc:RegisterEffect(e2)
                        
                        if aux.SetUnionState then
                            aux.SetUnionState(eqc)
                        end
                    end
                end
            end
        end
    end
end

-- ====================================================================
-- Efeito 2: Mill, Reviver e Trava do Extra Deck
-- ====================================================================
function s.gycon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end

function s.gytg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then 
        return Duel.GetFieldGroupCount(tp, 0, LOCATION_DECK) >= 2
            and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) 
    end
    Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 0, 1 - tp, 2)
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
    
    local ct = Duel.DiscardDeck(1 - tp, 2, REASON_EFFECT)
    local og = Duel.GetOperatedGroup()
    
    if ct > 0 and og:FilterCount(Card.IsLocation, nil, LOCATION_GRAVE) == 2 then
        if c:IsRelateToEffect(e) then
            Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
        end
    end
    
    if not Duel.IsExistingMatchingCard(s.killerfilter, tp, LOCATION_MZONE, 0, 1, nil) then
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
        e1:SetDescription(aux.Stringid(id, 3))
        e1:SetTargetRange(1, 0)
        e1:SetTarget(s.splimit)
        e1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(e1, tp)
    end
end