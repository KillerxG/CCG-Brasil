-- Silver Fangs Blader - Arnold
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Invocação-Link: 2+ Monstros de Efeito, incluindo 1 "Silver Fangs"
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsType, TYPE_EFFECT), 2, 4, s.lcheck)
    c:EnableReviveLimit()

    -- Efeito 1: Usar monstro do oponente como Material (Underworld Goddess Style)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_EXTRA_MATERIAL)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_SET_AVAILABLE)
    e1:SetTargetRange(1, 1) -- Afeta o próprio campo e o campo do oponente
    e1:SetOperation(s.extracon)
    e1:SetValue(s.extraval)
    c:RegisterEffect(e1)

    -- Efeito 2: Indestrutível em Batalha
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetCondition(s.lpcon)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- Efeito 3: Oponente só pode atacar o "Silver Fangs" de maior ATK
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(0, LOCATION_MZONE) -- Aplica a restrição aos monstros do oponente
    e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e3:SetCondition(s.lpcon)
    e3:SetValue(s.atktarget)
    c:RegisterEffect(e3)

    -- Efeito 4: Quick Effect de Destruição + Cura
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_DESTROY + CATEGORY_RECOVER)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E + TIMING_END_PHASE)
    e4:SetCountLimit(1, id)
    e4:SetTarget(s.destg)
    e4:SetOperation(s.desop)
    c:RegisterEffect(e4)
end

-- ====================================================================
-- Requisitos de Invocação-Link
-- ====================================================================
function s.lcheck(g, lc, sumtype, tp)
    return g:IsExists(Card.IsSetCard, 1, nil, 0x307, lc, sumtype, tp)
end

-- ====================================================================
-- Efeito 1: Material Extra do Oponente
-- ====================================================================
function s.extracon(c, e, tp, sg, mg, lc, og, chk)
    -- Limite de 1 monstro do oponente
    return sg:FilterCount(Card.IsControler, nil, 1 - tp) <= 1
end

function s.extraval(chk, summon_type, e, ...)
    local c = e:GetHandler()
    if chk == 0 then
        local tp, sc = ...
        if summon_type ~= SUMMON_TYPE_LINK or sc ~= c or Duel.GetLP(tp) <= Duel.GetLP(1 - tp) then
            return Group.CreateGroup()
        else
            return Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil)
        end
    elseif chk == 1 then
    elseif chk == 2 then
    end
end

-- ====================================================================
-- Efeito 2 e 3: Condição de LP e Trava de Batalha
-- ====================================================================
function s.lpcon(e)
    local tp = e:GetHandlerPlayer()
    return Duel.GetLP(tp) > Duel.GetLP(1 - tp)
end

function s.atktarget(e, c)
    local tp = e:GetHandlerPlayer()
    -- Filtra todos os "Silver Fangs" virados para cima que você controla
    local g = Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard, 0x307), tp, LOCATION_MZONE, 0, nil)
    if #g == 0 then return false end
    
    -- Destaca os monstros que dividem o valor máximo de ATK (Cobre a regra do empate)
    local maxG = g:GetMaxGroup(Card.GetAttack)
    
    -- Se o monstro alvejado 'c' NÃO estiver no grupo de maior ATK, a restrição bloqueia (retorna true)
    return not maxG:IsContains(c)
end

-- ====================================================================
-- Efeito 4: Destruir e Recuperar LP
-- ====================================================================
function s.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(1 - tp) and chkc:IsLocation(LOCATION_ONFIELD) end
    if chk == 0 then return Duel.IsExistingTarget(aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
    
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
    -- A cura usa "PossibleInfo" porque depende da presença da Kyara
    Duel.SetPossibleOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, Duel.GetFieldGroupCount(tp, 0, LOCATION_GRAVE) * 400)
end

function s.kyarafilter(c)
    -- Procura o ID 777001320 pelo nome original
    return c:IsFaceup() and c:GetOriginalCode() == 777001320
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    
    if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc, REASON_EFFECT) > 0 then
        -- Após destruir, checa se a Kyara está na mesa
        if Duel.IsExistingMatchingCard(s.kyarafilter, tp, LOCATION_MZONE, 0, 1, nil) then
            -- Conta o Cemitério do oponente (incluindo a carta que acabou de cair lá, se for o caso)
            local ct = Duel.GetFieldGroupCount(tp, 0, LOCATION_GRAVE)
            if ct > 0 then
                Duel.Recover(tp, ct * 400, REASON_EFFECT)
            end
        end
    end
end