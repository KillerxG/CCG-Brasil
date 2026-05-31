-- Rockslash Golem
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Special Summon do GY
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Efeito 2: Gatilho de Dano de Efeito -> Destruir 1 Monstro do Oponente
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DAMAGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)

    -- Efeito 3: Destruído por Batalha -> Causar Dano (Metade ou Total)
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BATTLE_DESTROYED)
    e3:SetCountLimit(1, id + 2)
    e3:SetTarget(s.damtg)
    e3:SetOperation(s.damop)
    c:RegisterEffect(e3)
end

-- ====================================================================
-- Filtro Global da Haruna
-- ====================================================================
function s.harunafilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777002010
end

-- ====================================================================
-- Efeito 1: Special Summon do GY (Com Restrição de Banir)
-- ====================================================================
function s.rsfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x309)
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.rsfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT + RESETS_REDIRECT)
        e1:SetValue(LOCATION_REMOVED)
        c:RegisterEffect(e1, true)
		-- "but banish it when it leaves the field"
		local e2 = Effect.CreateEffect(c)
		e2:SetDescription(3300) -- String universal do sistema
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT) -- Adicionado o Client Hint
		e2:SetReset(RESET_EVENT + RESETS_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e2, true)
    end
end

-- ====================================================================
-- Efeito 2: Gatilho de Dano de Efeito (Destruir Monstro)
-- ====================================================================
function s.descon(e, tp, eg, ep, ev, re, r, rp)
    return (r & REASON_EFFECT) ~= 0
end

function s.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1 - tp) end
    if chk == 0 then return Duel.IsExistingTarget(nil, tp, 0, LOCATION_MZONE, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, nil, tp, 0, LOCATION_MZONE, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc, REASON_EFFECT)
    end
end

-- ====================================================================
-- Efeito 3: Dano ao ser Destruído em Batalha (Dinâmico)
-- ====================================================================
function s.damtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    local c = e:GetHandler()
    local atk = c:GetBaseAttack()
    if atk < 0 then atk = 0 end
    
    local dam = math.floor(atk / 2)
    -- Projeta o dano total se a Haruna já estiver no campo
    if Duel.IsExistingMatchingCard(s.harunafilter, tp, LOCATION_MZONE, 0, 1, nil) then
        dam = atk
    end
    
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dam)
end

function s.damop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local atk = c:GetBaseAttack()
    if atk < 0 then atk = 0 end
    
    local dam = math.floor(atk / 2)
    -- Checa a Haruna na resolução exata do efeito para aplicar o dano total
    if Duel.IsExistingMatchingCard(s.harunafilter, tp, LOCATION_MZONE, 0, 1, nil) then
        dam = atk
    end
    
    if dam > 0 then
        Duel.Damage(1 - tp, dam, REASON_EFFECT)
    end
end