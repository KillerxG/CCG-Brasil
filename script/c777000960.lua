-- Leader of Phantom Gunners - Killer
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
	-- "You can only Special Summon 'Leader of Phantom Gunners - Killer(s)' once per turn."
    c:SetSPSummonOnce(id)
    -- Restrição absoluta: "Cannot be Normal Summoned/Set. Must be Special Summoned..."
    c:EnableReviveLimit()
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(e0)    

    -- Efeito 1: Special Summon Inerente (Da mão) 
    -- Tendo 3+ "Phantom Gunners" originais monstros com nomes diferentes (Campo/GY)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    -- Efeito 2: Imune a efeitos de Magia/Armadilha
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(s.efilter)
    c:RegisterEffect(e2)

    -- Efeito 3: Gatilho -> Se efeito de outro "Phantom Gunners" for ativado -> Mill 4 (Soft OPT)
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_DECKDES)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.millcon)
    e3:SetTarget(s.milltg)
    e3:SetOperation(s.millop)
    c:RegisterEffect(e3)

    -- Efeito 4: Quick Effect -> Mill 4 por cada 1000 ATK do alvo (Hard OPT)
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_DECKDES)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E + TIMING_MAIN_END)
    e4:SetCountLimit(1, id + 1)
    e4:SetTarget(s.atktg)
    e4:SetOperation(s.atkop)
    c:RegisterEffect(e4)
end

-- ====================================================================
-- Efeito 1: Condição de Invocação-Especial da Mão
-- ====================================================================
function s.spcfilter(c)
    -- Checa se pertence ao arquétipo, se a essência original é Monstro e se está visível para a engine
    return c:IsSetCard(0x302) and c:IsOriginalType(TYPE_MONSTER) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return false end
    
    local g = Duel.GetMatchingGroup(s.spcfilter, tp, LOCATION_ONFIELD + LOCATION_GRAVE, 0, nil)
    -- GetClassCount avalia nativamente quantos nomes diferentes estão no bolo da variável "g"
    return g:GetClassCount(Card.GetOriginalCode) >= 3
end

-- ====================================================================
-- Efeito 2: Imunidade a S/T
-- ====================================================================
function s.efilter(e, te)
    return te:IsActiveType(TYPE_SPELL + TYPE_TRAP)
end

-- ====================================================================
-- Efeito 3: Mill 4 Passivo (Reagindo a outro Phantom Gunners)
-- ====================================================================
function s.millcon(e, tp, eg, ep, ev, re, r, rp)
    local rc = re:GetHandler()
    -- Garante que o efeito veio do seu lado, que é efeito de monstro, do arquétipo e não é o próprio Killer
    return rp == tp and re:IsActiveType(TYPE_MONSTER) and rc:IsSetCard(0x302) and rc ~= e:GetHandler()
end

function s.milltg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetFieldGroupCount(tp, 0, LOCATION_DECK) >= 4 end
    Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 0, 1 - tp, 4)
end

function s.millop(e, tp, eg, ep, ev, re, r, rp)
    Duel.DiscardDeck(1 - tp, 4, REASON_EFFECT)
end

-- ====================================================================
-- Efeito 4: Quick Effect (Mill Escalonado via ATK)
-- ====================================================================
function s.atkfilter(c)
    -- Exige que o alvo tenha pelo menos 1000 ATK para o efeito ser ativável
    return c:IsFaceup() and c:GetAttack() >= 1000
end

function s.atktg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1 - tp) and s.atkfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.atkfilter, tp, 0, LOCATION_MZONE, 1, nil)
        and Duel.GetFieldGroupCount(tp, 0, LOCATION_DECK) > 0 end 
        
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g = Duel.SelectTarget(tp, s.atkfilter, tp, 0, LOCATION_MZONE, 1, 1, nil)
    
    -- Calcula a estimativa para o display inicial do sistema
    local mills = math.floor(g:GetFirst():GetAttack() / 1000) * 4
    Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 0, 1 - tp, mills)
end

function s.atkop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    -- Confere a relação e o ATK real no momento da resolução
    if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
        local atk = tc:GetAttack()
        local mills = math.floor(atk / 1000) * 4
        
        if mills > 0 then
            Duel.DiscardDeck(1 - tp, mills, REASON_EFFECT)
        end
    end
end