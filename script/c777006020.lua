-- Creature-Warden Queen, Sarafaye
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Habilita Invocação-Xyz e define 3 Monstros de Nível 10 como matéria
    c:EnableReviveLimit()
    Xyz.AddProcedure(c, nil, 10, 3)

    -- (Restrições de invocação removidas)

    -- Efeito 1: Não pode ser alvo de cartas do oponente enquanto tiver Ritual como matéria
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.protcon)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)

    -- Efeito 2: Não pode ser destruída por cartas do oponente enquanto tiver Ritual como matéria
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.protcon)
    e2:SetValue(aux.indoval)
    c:RegisterEffect(e2)

    -- Efeito 3: (Efeito Rápido) Desanexar 1 matéria; Oponente não ativa da mão e não adiciona do Deck à Mão
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E | TIMING_MAIN_END)
    e3:SetCountLimit(1, {id, 1})
    e3:SetCondition(s.lockcon)
    e3:SetCost(s.lockcost)
    e3:SetOperation(s.lockop)
    c:RegisterEffect(e3, false, REGISTER_FLAG_DETACH_XMAT)

    -- Efeito 4: Se carta for adicionada do Deck à mão do oponente: Anexar Ritual e Setar "Black and Blue Wave"
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
	e4:SetCategory(CATEGORY_SET)
    e4:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_TO_HAND)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1, {id, 2})
    e4:SetCondition(s.attcon)
    e4:SetTarget(s.atttg)
    e4:SetOperation(s.attop)
    c:RegisterEffect(e4)
end

s.listed_series = {0x251}
s.listed_names = {777005540}

-- ==========================================================
-- Efeitos 1 e 2: Proteção Passiva por Matéria Ritual
-- ==========================================================
function s.protcon(e)
    return e:GetHandler():GetOverlayGroup():IsExists(Card.IsType, 1, nil, TYPE_RITUAL)
end

-- ==========================================================
-- Efeito 3: Travar Mão e Busca (Efeito Rápido)
-- ==========================================================
function s.lockcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsMainPhase()
end

function s.lockcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():CheckRemoveOverlayCard(tp, 1, REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp, 1, 1, REASON_COST)
end

function s.lockop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    -- Trava as ativações da mão
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET | EFFECT_FLAG_CLIENT_HINT)
    e1:SetDescription(aux.Stringid(id, 2))
    e1:SetTargetRange(0, 1)
    e1:SetValue(s.aclimit)
    e1:SetReset(RESET_PHASE | PHASE_END)
    Duel.RegisterEffect(e1, tp)
    
    -- Trava puxar do Deck para a mão
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_TO_HAND)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetTargetRange(0, 1)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsLocation, LOCATION_DECK))
    e2:SetReset(RESET_PHASE | PHASE_END)
    Duel.RegisterEffect(e2, tp)
end

function s.aclimit(e, re, tp)
    return re:GetHandler():IsLocation(LOCATION_HAND)
end

-- ==========================================================
-- Efeito 4: Engatilhar no Search (Anexar e Setar Magia/Armadilha)
-- ==========================================================
function s.thcfilter(c, tp)
    return c:IsControler(1 - tp) and c:IsPreviousLocation(LOCATION_DECK)
end

function s.attcon(e, tp, eg, ep, ev, re, r, rp)
    return not Duel.IsDamageStep() and eg:IsExists(s.thcfilter, 1, nil, tp)
end

function s.matfilter(c)
    return c:IsType(TYPE_RITUAL) and c:IsMonster()
end

function s.setfilter(c)
    return c:IsCode(777005540) and c:IsSSetable()
end

function s.atttg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.matfilter, tp, LOCATION_DECK | LOCATION_GRAVE, 0, 1, nil)
            and e:GetHandler():IsType(TYPE_XYZ)
            and Duel.IsExistingMatchingCard(s.setfilter, tp, LOCATION_DECK | LOCATION_GRAVE, 0, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, nil, 1, tp, 0)
end

function s.attop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_XMATERIAL)
    local mg = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.matfilter), tp, LOCATION_DECK | LOCATION_GRAVE, 0, 1, 1, nil)
    if #mg > 0 then
        Duel.Overlay(c, mg)
        
        if c:GetOverlayGroup():IsContains(mg:GetFirst()) then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
            local sg = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.setfilter), tp, LOCATION_DECK | LOCATION_GRAVE, 0, 1, 1, nil)
            local tc = sg:GetFirst()
            
            if tc and Duel.SSet(tp, tc) > 0 then
                if tc:IsType(TYPE_TRAP) then
                    local e1 = Effect.CreateEffect(c)
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
                    e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
                    e1:SetReset(RESET_EVENT | RESETS_STANDARD)
                    tc:RegisterEffect(e1)
                elseif tc:IsType(TYPE_QUICKPLAY) then
                    local e2 = Effect.CreateEffect(c)
                    e2:SetType(EFFECT_TYPE_SINGLE)
                    e2:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
                    e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
                    e2:SetReset(RESET_EVENT | RESETS_STANDARD)
                    tc:RegisterEffect(e2)
                end
            end
        end
    end
end