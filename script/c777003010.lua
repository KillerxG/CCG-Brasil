-- Hexblade Witch of the Shadows
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Habilita Invocação-Sincro
    c:EnableReviveLimit()
    -- Procedimento: 1 Tuner (incluindo monstros Flip) + 1 ou mais monstros Flip não-Tuner
    Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsType,TYPE_FLIP),1,99,s.exmatfilter)

    -- Efeito 1: Ganho de ATK quando um ou mais monstros Flip são virados para cima
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetDescription(aux.Stringid(id, 0))
    -- Como a carta diz "This card gains", sem "You can", é um Efeito Mandatório (TRIGGER_F)
    e1:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_FLIP)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.atkcon)
    e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)

    -- Efeito 2: Special Summon 1 monstro Flip da mão ou GY em Posição de Defesa com a face para baixo
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, {id, 1})
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    -- Efeito 3: (Efeito Rápido) Mudar posição de 1 monstro seu e destruir 1 carta do oponente
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_POSITION | CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E | TIMING_MAIN_END)
    e3:SetCountLimit(1, {id, 2})
    e3:SetTarget(s.postg)
    e3:SetOperation(s.posop)
    c:RegisterEffect(e3)
end

-- ==========================================================
-- Procedimento de Sincro
-- ==========================================================
function s.exmatfilter(c,scard,sumtype,tp)
	return c:IsType(TYPE_FLIP,scard,sumtype,tp)
end

-- ==========================================================
-- Efeito 1: Ganho de ATK
-- ==========================================================
function s.atkfilter(c)
    return c:IsType(TYPE_FLIP)
end

function s.atkcon(e, tp, eg, ep, ev, re, r, rp)
    -- Verifica se no grupo de monstros virados (eg) há ao menos 1 monstro Flip
    return eg:IsExists(s.atkfilter, 1, nil)
end

function s.atkop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(800)
        e1:SetReset(RESET_EVENT | RESETS_STANDARD | RESET_PHASE | PHASE_END)
        c:RegisterEffect(e1)
    end
end

-- ==========================================================
-- Efeito 2: Special Summon em Posição de Defesa Face-Down
-- ==========================================================
function s.spfilter(c, e, tp)
    return c:IsType(TYPE_FLIP) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEDOWN_DEFENSE)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_HAND | LOCATION_GRAVE, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND | LOCATION_GRAVE)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.spfilter), tp, LOCATION_HAND | LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    if #g > 0 then
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEDOWN_DEFENSE)
        -- Como a carta entra com a face para baixo e pode vir de local privado (Mão), é bom atestar com ConfirmCards
        if g:GetFirst():IsLocation(LOCATION_HAND) then
            Duel.ConfirmCards(1 - tp, g)
        end
    end
end

-- ==========================================================
-- Efeito 3: Mudança de Posição e Destruição (Efeito Rápido)
-- ==========================================================
function s.posfilter(c)
    return c:IsFacedown() and c:IsDefensePos()
end

function s.postg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.posfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.posfilter, tp, LOCATION_MZONE, 0, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_POSCHANGE)
    local g = Duel.SelectTarget(tp, s.posfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_POSITION, g, 1, 0, 0)
    Duel.SetPossibleOperationInfo(0, CATEGORY_DESTROY, nil, 1, 1 - tp, LOCATION_ONFIELD)
end

function s.posop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFacedown() then
        -- Abre o leque de opções para o jogador escolher em qual posição face-up ele quer deixar o monstro
        local pos = Duel.SelectPosition(tp, tc, POS_FACEUP_ATTACK | POS_FACEUP_DEFENSE)
        if Duel.ChangePosition(tc, pos) > 0 then
            local dg = Duel.GetMatchingGroup(nil, tp, 0, LOCATION_ONFIELD, nil)
            
            -- "..and if you do, you can destroy 1 card your opponent controls."
            if #dg > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
                local sg = dg:Select(tp, 1, 1, nil)
                Duel.HintSelection(sg)
                Duel.Destroy(sg, REASON_EFFECT)
            end
        end
    end
end