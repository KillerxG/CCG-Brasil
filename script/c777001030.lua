-- Phantom Gunners Assassin
-- Scripted by Gemini
local s, id = GetID()
Duel.LoadScript("proc_union_mod.lua")
function s.initial_effect(c)
	-- Union Procedure
	aux.AddUnionProcedureMod(c,s.unionfilter,true,true)
    -- Efeito 1: Ignition -> Equipar 1 Union do déqui/GY e destruir 1 carta
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_EQUIP + CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.eqtg)
    e1:SetOperation(s.eqop)
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
-- Efeito 1: Equipar Union e Destruir
-- ====================================================================
function s.eqfilter(c, tp)
    -- Confere se é um monstro Union do arquétipo e se pode ser colocado na S/T Zone
    return c:IsSetCard(0x302) and c:IsType(TYPE_UNION) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end

function s.eqtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
        and Duel.IsExistingMatchingCard(s.eqfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, tp) end
    Duel.SetOperationInfo(0, CATEGORY_EQUIP, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
    -- Destruição opcional não alveja, então apenas declaramos a possibilidade para o sistema
    Duel.SetPossibleOperationInfo(0, CATEGORY_DESTROY, nil, 1, 1 - tp, LOCATION_ONFIELD)
end

function s.eqlimit(e, c)
    return c == e:GetLabelObject()
end

function s.eqop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    -- Se o monstro não estiver mais em campo virado pra cima ou faltar espaço, cancela
    if Duel.GetLocationCount(tp, LOCATION_SZONE) <= 0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
    -- O NecroValleyFilter garante que a carta possa ser puxada do GY mesmo se o Necrovalley estiver ativo (pois vai se equipar a você)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.eqfilter), tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil, tp)
    local eqc = g:GetFirst()
    
    if eqc and Duel.Equip(tp, eqc, c) then
        -- Registra o limite do equipamento
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetValue(s.eqlimit)
        e1:SetLabelObject(c)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD)
        eqc:RegisterEffect(e1)
        
        -- Garante a mecânica nativa de monstro Union
        local e2 = Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e2:SetCode(EFFECT_UNION_STATUS)
        e2:SetReset(RESET_EVENT + RESETS_STANDARD)
        eqc:RegisterEffect(e2)
        
        if aux.SetUnionState then
            aux.SetUnionState(eqc)
        end
        
        -- "and if you do, you can destroy 1 card your opponent controls"
        local dg = Duel.GetMatchingGroup(nil, tp, 0, LOCATION_ONFIELD, nil)
        if #dg > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
            local sg = dg:Select(tp, 1, 1, nil)
            Duel.HintSelection(sg) -- Pisca o alvo escolhido na tela do oponente
            Duel.Destroy(sg, REASON_EFFECT)
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