-- Nightly Ritual of Vampire Castle
local s, id = GetID()

function s.initial_effect(c)
    -- Magia Rapida
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER + TIMING_MAIN_END)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

s.listed_series = {0x8e}

-- Condicao: Apenas durante a Main Phase
function s.condition(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsMainPhase()
end

-- Filtro de materiais validos no campo: seus monstros ou Zumbis do oponente
function s.matfilter(c, tp)
    return c:IsFaceup() and (c:IsControler(tp) or c:IsRace(RACE_ZOMBIE))
end

-- Filtro de alvos do Extra Deck / Mao por localizacao correta
function s.spfilter(c, e, tp, mg)
    if not c:IsSetCard(0x8e) then return false end
    
    -- Synchro (Extra Deck)
    if c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA) and c:IsSynchroSummonable(nil, mg) then return true end
    
    -- Xyz (Extra Deck)
    if c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA) and c:IsXyzSummonable(nil, mg) then return true end
    
   -- Ritual (Mao)
    if c:IsType(TYPE_RITUAL) and c:IsLocation(LOCATION_HAND) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_RITUAL, tp, true, false) then
        local rmat = mg:Filter(Card.HasLevel, nil) -- Proteção contra Xyz/Link
        if rmat:CheckWithSumGreater(Card.GetRitualLevel, c:GetLevel(), c) then 
            return true 
        end
    end
    return false
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    local mg = Duel.GetMatchingGroup(s.matfilter, tp, LOCATION_MZONE, LOCATION_MZONE, nil, tp)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_EXTRA + LOCATION_HAND, 0, 1, nil, e, tp, mg)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA + LOCATION_HAND)
end

function s.activate(e, tp, eg, ep, ev, re, r, rp)
    local mg = Duel.GetMatchingGroup(s.matfilter, tp, LOCATION_MZONE, LOCATION_MZONE, nil, tp)
    local g = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_EXTRA + LOCATION_HAND, 0, nil, e, tp, mg)
    if #g == 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local tc = g:Select(tp, 1, 1, nil):GetFirst()
    if not tc then return end

    local summoned_monster = nil

    if tc:IsType(TYPE_SYNCHRO) then
        Duel.SynchroSummon(tp, tc, nil, mg)
        summoned_monster = tc
    elseif tc:IsType(TYPE_XYZ) then
        Duel.XyzSummon(tp, tc, mg)
        summoned_monster = tc
    elseif tc:IsType(TYPE_RITUAL) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
        local rmat = mg:Filter(Card.HasLevel, nil) -- Proteção contra Xyz/Link
        local mat = rmat:SelectWithSumGreater(tp, Card.GetRitualLevel, tc:GetLevel(), tc)
        tc:SetMaterial(mat)
        Duel.ReleaseRitualMaterial(mat)
        Duel.BreakEffect()
        if Duel.SpecialSummon(tc, SUMMON_TYPE_RITUAL, tp, tp, true, false, POS_FACEUP) > 0 then
            tc:CompleteProcedure()
            summoned_monster = tc
        end
    end

    -- Registra o dano na End Phase caso o monstro continue no seu campo
    if summoned_monster then
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE + PHASE_END)
        e1:SetCountLimit(1)
        e1:SetLabelObject(summoned_monster)
        e1:SetCondition(s.damcon)
        e1:SetOperation(s.damop)
        e1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(e1, tp)
    end
end

-- Condicao e calculo de dano na End Phase
function s.damcon(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetLabelObject()
    return tc and tc:IsLocation(LOCATION_MZONE) and tc:IsControler(tp) and tc:IsFaceup()
end

function s.damop(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetLabelObject()
    if tc and tc:IsLocation(LOCATION_MZONE) and tc:IsControler(tp) and tc:IsFaceup() then
        local val = 0
        if tc:HasLevel() then
            val = tc:GetLevel()
        elseif tc:IsType(TYPE_XYZ) then
            val = tc:GetRank()
        end
        
        if val > 0 then
            Duel.Hint(HINT_CARD, 0, id)
            Duel.Damage(tp, val * 250, REASON_EFFECT)
        end
    end
end