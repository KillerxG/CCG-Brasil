-- Rockslash Secret Passage
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Ativação Padrão de Trap Contínua
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- Efeito 1.1: Oponente não pode alvejar monstros "Rockslash" com ataques
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(0, LOCATION_MZONE) -- Restrição aplicada aos monstros do oponente
    e1:SetCondition(s.protcon)
    e1:SetValue(s.prottg)
    c:RegisterEffect(e1)

    -- Efeito 1.2: Oponente não pode alvejar monstros "Rockslash" com efeitos de carta
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_MZONE, 0) -- Proteção aplicada aos seus monstros
    e2:SetCondition(s.protcon)
    e2:SetTarget(s.prottg)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)

    -- Efeito 2: Gatilho de Coluna (Summon e Spell/Trap)
    -- Compartilha o mesmo ID de HOPT para todas as condições de ativação
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.sumcon)
    e3:SetTarget(s.damtg)
    e3:SetOperation(s.damop)
    c:RegisterEffect(e3)
    -- Clones para cobrir Special Summon e Flip Summon
    local e4 = e3:Clone()
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e4)
    local e5 = e3:Clone()
    e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e5)
    
    -- Clone para ativações de Spell/Trap na corrente
    local e6 = e3:Clone()
    e6:SetCode(EVENT_CHAINING)
    e6:SetCondition(s.actcon)
    c:RegisterEffect(e6)

    -- Efeito 3: Banir do GY para Special Summon
    local e7 = Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id, 1))
    e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e7:SetType(EFFECT_TYPE_IGNITION)
    e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e7:SetRange(LOCATION_GRAVE)
    e7:SetCountLimit(1, id)
    e7:SetCost(aux.bfgcost) -- Custo padrão de Banir do GY
    e7:SetTarget(s.sptg)
    e7:SetOperation(s.spop)
    c:RegisterEffect(e7)
end

-- ====================================================================
-- Efeito 1: Proteção de Alvo e Ataque (Condição Haruna)
-- ====================================================================
function s.harunafilter(c)
    -- Procura a "Master of Rockslash - Haruna" pelo ID original
    return c:IsFaceup() and c:GetOriginalCode() == 777002010
end

function s.protcon(e)
    return Duel.IsExistingMatchingCard(s.harunafilter, e:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, nil)
end

function s.prottg(e, c)
    -- Garante que o monstro protegido seja um "Rockslash" virado para cima
    return c:IsFaceup() and c:IsSetCard(0x309)
end

-- ====================================================================
-- Efeito 2: Dano de Coluna
-- ====================================================================
function s.rsfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x309)
end

-- Condição para gatilho de Invocação
function s.sumcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not Duel.IsExistingMatchingCard(s.rsfilter, tp, LOCATION_MZONE, 0, 1, nil) then return false end
    
    -- Puxa o grupo que compõe a coluna geométrica desta Trap
    local col_g = c:GetColumnGroup()
    -- Confere se a carta invocada (eg) é do oponente e caiu na mesma coluna
    return eg:IsExists(function(tc, cg) return tc:IsControler(1 - tp) and cg:IsContains(tc) end, 1, nil, col_g)
end

-- Condição para gatilho de Ativação (Spell/Trap)
function s.actcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not Duel.IsExistingMatchingCard(s.rsfilter, tp, LOCATION_MZONE, 0, 1, nil) then return false end
    
    -- Confirma se a ativação partiu do oponente e se foi uma carta Spell/Trap ligada ao campo
    if rp ~= 1 - tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
    
    local rc = re:GetHandler()
    return c:GetColumnGroup():IsContains(rc)
end

function s.damtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, 500)
end

function s.damop(e, tp, eg, ep, ev, re, r, rp)
    -- A Trap Contínua precisa continuar no campo na resolução para o dano acontecer
    if e:GetHandler():IsRelateToEffect(e) then
        Duel.Damage(1 - tp, 500, REASON_EFFECT)
    end
end

-- ====================================================================
-- Efeito 3: Special Summon do GY (Main Phase)
-- ====================================================================
function s.spfilter(c, e, tp, has_haruna)
    if not c:IsCanBeSpecialSummoned(e, 0, tp, false, false) then return false end
    
    -- Checagem A: O monstro é um "Rockslash" válido
    if c:IsSetCard(0x309) and c:IsType(TYPE_MONSTER) then return true end
    
    -- Checagem B: Opcional extra (Monstro ROCHA genérico se controlar Haruna)
    if has_haruna and c:IsRace(RACE_ROCK) and c:IsType(TYPE_MONSTER) then return true end
    
    return false
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local has_haruna = Duel.IsExistingMatchingCard(s.harunafilter, tp, LOCATION_MZONE, 0, 1, nil)
    
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc, e, tp, has_haruna) end
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingTarget(s.spfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp, has_haruna) end
        
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.spfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp, has_haruna)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
    end
end