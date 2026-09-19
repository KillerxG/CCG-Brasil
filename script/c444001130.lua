-- Guardians of Vampire Castle
local s, id = GetID()

function s.initial_effect(c)
    -- Ativacao da carta
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- 1. Debuff de ATK/DEF (Metade da diferenca de LP, Nao-acumulativo)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(0, LOCATION_MZONE)
    e1:SetCondition(s.lpcon)
    e1:SetValue(s.lpval)
    c:RegisterEffect(e1)
    
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e1b)

    -- 2a. Pagar 800 LP na declaracao de ataque
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_POSITION)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_ATTACK_ANNOUNCE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.atkcon)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    -- 2b. Pagar 800 LP na ativacao de efeito/carta do oponente
    local e3 = e2:Clone()
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetCondition(s.chaincon)
    c:RegisterEffect(e3)

    -- 3. Invocacao-Sincro ao sair do campo + Roubo de Zombie
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_CONTROL + CATEGORY_REMOVE)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_LEAVE_FIELD)
    e4:SetCountLimit(1, id + 1)
    e4:SetCondition(s.excon)
    e4:SetTarget(s.extg)
    e4:SetOperation(s.exop)
    c:RegisterEffect(e4)
end

s.listed_series = {0x8e}

--------------------------------------------------------------------------------
-- Efeito 1: Debuff de ATK/DEF (Sem acumulo entre multiplas copias)
--------------------------------------------------------------------------------
function s.lpcon(e)
    local tp = e:GetHandlerPlayer()
    if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard, 0x8e), tp, LOCATION_MZONE, 0, 1, nil) then return false end
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_SZONE, 0, nil):Filter(Card.IsCode, nil, id)
    return #g > 0 and g:GetFirst() == e:GetHandler()
end

function s.lpval(e, c)
    local tp = e:GetHandlerPlayer()
    local diff = math.abs(Duel.GetLP(tp) - Duel.GetLP(1 - tp))
    return -math.floor(diff / 2)
end

--------------------------------------------------------------------------------
-- Efeito 2: Reacao no Ataque ou Ativacao de Efeito
--------------------------------------------------------------------------------
function s.atkcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetAttacker():IsControler(1 - tp)
end

function s.chaincon(e, tp, eg, ep, ev, re, r, rp)
    return rp == 1 - tp
end

function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 800) end
    Duel.PayLPCost(tp, 800)
end

function s.spfilter(c, e, tp)
    return c:IsMonster() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
        and (c:IsSetCard(0x8e) or c:IsRace(RACE_ZOMBIE | RACE_ILLUSION | RACE_FIEND))
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE | LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc, e, tp) end
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingTarget(s.spfilter, tp, LOCATION_GRAVE | LOCATION_REMOVED, 0, 1, nil, e, tp) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, aux.NecroValleyFilter(s.spfilter), tp, LOCATION_GRAVE | LOCATION_REMOVED, 0, 1, 1, nil, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, tp, 0)
    Duel.SetPossibleOperationInfo(0, CATEGORY_POSITION, nil, 1, 1 - tp, LOCATION_MZONE)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        local g = Duel.GetMatchingGroup(Card.IsCanChangePosition, tp, 0, LOCATION_MZONE, nil)
        if #g > 0 then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_POSCHANGE)
            local sg = g:Select(tp, 1, 1, nil)
            local sc = sg:GetFirst()
            if sc then
                Duel.HintSelection(sg)
                if Duel.ChangePosition(sc, POS_FACEUP_DEFENSE) > 0 or sc:IsPosition(POS_FACEUP_DEFENSE) then
                    local e1 = Effect.CreateEffect(e:GetHandler())
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetCode(EFFECT_CHANGE_RACE)
                    e1:SetValue(RACE_ZOMBIE)
                    e1:SetReset(RESET_EVENT + RESETS_STANDARD)
                    sc:RegisterEffect(e1)
                end
            end
        end
    end
end

--------------------------------------------------------------------------------
-- Efeito 3: Invocacao-Sincro (Materiais do Campo e Cemiterio)
--------------------------------------------------------------------------------
function s.excon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and rp == 1 - tp
end

function s.mfilter(c, sc)
    return c:IsMonster() and c:HasLevel() and c:IsCanBeSynchroMaterial(sc)
        and (c:IsLocation(LOCATION_MZONE) or (c:IsLocation(LOCATION_GRAVE) and c:IsAbleToRemove()))
end

function s.rescon(sc)
    return function(sg, e, tp, mg)
        return sg:IsExists(Card.IsType, 1, nil, TYPE_TUNER) and sg:GetSum(Card.GetLevel) == sc:GetLevel()
    end
end

function s.synfilter(c, e, tp)
    if not (c:IsSetCard(0x8e) and c:IsType(TYPE_SYNCHRO) and c:HasLevel()) then return false end
    if c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp, tp, nil, c) <= 0 then return false end
    if c:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return false end
    if not c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false, false) then return false end
    
    local mg = Duel.GetMatchingGroup(s.mfilter, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, nil, c)
    return aux.SelectUnselectGroup(mg, e, tp, 2, #mg, s.rescon(c), 0)
end

function s.extg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.synfilter, tp, LOCATION_EXTRA | LOCATION_GRAVE, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA | LOCATION_GRAVE)
    Duel.SetPossibleOperationInfo(0, CATEGORY_CONTROL, nil, 1, 1 - tp, LOCATION_MZONE)
end

function s.exop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.synfilter, tp, LOCATION_EXTRA | LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    local sc = g:GetFirst()
    if not sc then return end

    local mg = Duel.GetMatchingGroup(s.mfilter, tp, LOCATION_MZONE | LOCATION_GRAVE, 0, nil, sc)
    local matg = aux.SelectUnselectGroup(mg, e, tp, 2, #mg, s.rescon(sc), 1, tp, HINTMSG_SMATERIAL)

    if #matg > 0 then
        sc:SetMaterial(matg)
        
        local g_mzone = matg:Filter(Card.IsLocation, nil, LOCATION_MZONE)
        local g_grave = matg:Filter(Card.IsLocation, nil, LOCATION_GRAVE)
        
        if #g_mzone > 0 then
            Duel.SendtoGrave(g_mzone, REASON_EFFECT + REASON_MATERIAL + REASON_SYNCHRO)
        end
        if #g_grave > 0 then
            Duel.Remove(g_grave, POS_FACEUP, REASON_EFFECT + REASON_MATERIAL + REASON_SYNCHRO)
        end
        
        if Duel.SpecialSummon(sc, SUMMON_TYPE_SYNCHRO, tp, tp, false, false, POS_FACEUP) > 0 then
            sc:CompleteProcedure()

            -- Roubo opcional de 1 monstro Zombie do oponente
            local cg = Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsRace, RACE_ZOMBIE), tp, 0, LOCATION_MZONE, nil):Filter(Card.IsControlerCanBeChanged, nil)
            if #cg > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONTROL)
                local sg = cg:Select(tp, 1, 1, nil)
                Duel.HintSelection(sg)
                Duel.GetControl(sg, tp)
            end
        end
    end
end