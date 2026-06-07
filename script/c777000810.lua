-- Draconic Rune
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Ativação da Magia Contínua
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- Efeito 1: Monstros "Draconic" também são tratados como Dragão (Campo, GY e Banishment)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(LOCATION_MZONE + LOCATION_GRAVE + LOCATION_REMOVED, 0) -- Apenas suas cartas
    e1:SetCode(EFFECT_ADD_RACE)
    e1:SetTarget(s.racetg)
    e1:SetValue(RACE_DRAGON)
    c:RegisterEffect(e1)

    -- Efeito 2: Gatilho de Ataque -> Banir Monstro do Oponente
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_ATTACK_ANNOUNCE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.atkcon)
    e2:SetTarget(s.atktg)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)

    -- Efeito 3: Ignition -> Alvejar "Draconic" no GY/Banido para Add à Mão ou Special Summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1, id + 1)
    e3:SetTarget(s.thstg)
    e3:SetOperation(s.thsop)
    c:RegisterEffect(e3)

    -- Efeito 4: Ignition do GY -> Banir esta carta para retornar até 3 Draconics banidos pro GY
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_TOGRAVE)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCountLimit(1, id + 2)
    e4:SetCondition(s.rtcon)
    e4:SetCost(aux.bfgcost)
    e4:SetTarget(s.rttg)
    e4:SetOperation(s.rtop)
    c:RegisterEffect(e4)
end

-- ====================================================================
-- Filtros Globais
-- ====================================================================
function s.blazefilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777000680
end

-- ====================================================================
-- Efeito 1: Alteração de Tipo (Raça)
-- ====================================================================
function s.racetg(e, c)
    return c:IsSetCard(0x300) and c:IsType(TYPE_MONSTER)
end

-- ====================================================================
-- Efeito 2: Banir ao Declarar Ataque
-- ====================================================================
function s.atkcon(e, tp, eg, ep, ev, re, r, rp)
    local at = Duel.GetAttacker()
    local de = Duel.GetAttackTarget()
    if not at or not de then return false end
    
    -- Ajusta os ponteiros para saber de qual lado é qual monstro
    if at:IsControler(1 - tp) then at, de = de, at end
    
    -- "at" é o seu monstro, "de" é o monstro do oponente. Confere se o seu é "Draconic"
    return at:IsControler(tp) and at:IsFaceup() and at:IsSetCard(0x300)
        and de:IsControler(1 - tp)
end

function s.atktg(e, tp, eg, ep, ev, re, r, rp, chk)
    local at = Duel.GetAttacker()
    local de = Duel.GetAttackTarget()
    if at:IsControler(1 - tp) then at, de = de, at end
    
    if chk == 0 then return de:IsAbleToRemove() end
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, de, 1, 0, 0)
end

function s.atkop(e, tp, eg, ep, ev, re, r, rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    
    local at = Duel.GetAttacker()
    local de = Duel.GetAttackTarget()
    if not at or not de then return end
    if at:IsControler(1 - tp) then at, de = de, at end
    
    if de:IsRelateToBattle() then
        Duel.Remove(de, POS_FACEUP, REASON_EFFECT)
    end
end

-- ====================================================================
-- Efeito 3: Add/Special Summon do GY ou Banishment
-- ====================================================================
function s.thspfilter(c, e, tp)
    -- Para ler as propriedades de uma carta banida com precisão, ela deve estar virada para cima
    if c:IsLocation(LOCATION_REMOVED) and c:IsFacedown() then return false end
    if not c:IsSetCard(0x300) then return false end
    
    local b1 = c:IsAbleToHand()
    local b2 = c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
    return b1 or b2
end

function s.thstg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE + LOCATION_REMOVED) and chkc:IsControler(tp) and s.thspfilter(chkc, e, tp) end
    if chk == 0 then return Duel.IsExistingTarget(s.thspfilter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil, e, tp) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g = Duel.SelectTarget(tp, s.thspfilter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, 1, nil, e, tp)
    
    -- Resguarda os operation infos para as duas possibilidades
    Duel.SetPossibleOperationInfo(0, CATEGORY_TOHAND, g, 1, tp, LOCATION_GRAVE + LOCATION_REMOVED)
    Duel.SetPossibleOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, tp, LOCATION_GRAVE + LOCATION_REMOVED)
end

function s.thsop(e, tp, eg, ep, ev, re, r, rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local tc = Duel.GetFirstTarget()
    
    if tc and tc:IsRelateToEffect(e) then
        local b1 = tc:IsAbleToHand()
        local b2 = tc:IsCanBeSpecialSummoned(e, 0, tp, false, false) and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        local op = 0
        
        -- Lógica de decisão
        if b1 and b2 then
            op = Duel.SelectOption(tp, aux.Stringid(id, 3), aux.Stringid(id, 4))
        elseif b1 then
            op = Duel.SelectOption(tp, aux.Stringid(id, 3))
        elseif b2 then
            op = Duel.SelectOption(tp, aux.Stringid(id, 4)) + 1
        else
            return
        end
        
        -- Aplica o efeito escolhido
        if op == 0 then
            Duel.SendtoHand(tc, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, tc)
        else
            Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
        end
    end
end

-- ====================================================================
-- Efeito 4: Retornar Cartas Banidas para o GY
-- ====================================================================
function s.rtcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.blazefilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.rtfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x300)
end

function s.rttg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    -- Garante que o alvo não seja a própria Magia que acabou de ser banida como custo
    if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.rtfilter(chkc) and chkc ~= c end
    if chk == 0 then return Duel.IsExistingTarget(s.rtfilter, tp, LOCATION_REMOVED, 0, 1, c) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectTarget(tp, s.rtfilter, tp, LOCATION_REMOVED, 0, 1, 3, c)
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g, #g, 0, 0)
end

function s.rtop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetTargetCards(e)
    if #g > 0 then
        -- O sistema entende o Retorno pro Cemitério a partir da zona de Banimento usando REASON_RETURN
        Duel.SendtoGrave(g, REASON_EFFECT + REASON_RETURN)
    end
end