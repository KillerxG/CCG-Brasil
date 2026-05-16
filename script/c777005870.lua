-- Celestial Guardian - Tryce
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Special Summon da mão se houver Equip Spell no campo (Efeito de Ignição)
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Efeito 2: Se Invocado por Invocação-Normal/Especial: Descartar 1; Buscar Equip Spell do Deck
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TOHAND | CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1, {id, 2})
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    -- Clone do Efeito 2 para engatilhar também em Special Summons
    local e3 = e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    -- Efeito 3: Banir do campo/GY; Monstro "Celestial Guardian" ganha ATK, ataca 2x e ganha efeito "Armades"
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_ATKCHANGE)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE | LOCATION_GRAVE)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetCountLimit(1, {id, 3})
    e4:SetCost(s.buffcost)
    e4:SetTarget(s.bufftg)
    e4:SetOperation(s.buffop)
    c:RegisterEffect(e4)
end

s.listed_series = {0x252}

-- ==========================================================
-- Efeito 1: Invocação da Mão
-- ==========================================================
function s.eqcfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsSpell()
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    -- Varre ambos os lados do campo procurando por qualquer Magia de Equipamento ativa
    return Duel.IsExistingMatchingCard(s.eqcfilter, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
    end
end

-- ==========================================================
-- Efeito 2: Descartar 1 e Adicionar Equip Spell à Mão
-- ==========================================================
function s.thcost(e, tp, eg, ep, ev, re, r, rp, chk)
    -- Checa se existe carta legal para descarte na mão do jogador
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, nil) end
    Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1, REASON_COST | REASON_DISCARD)
end

function s.thfilter(c)
    return c:IsType(TYPE_EQUIP) and c:IsSpell() and c:IsAbleToHand()
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

-- ==========================================================
-- Efeito 3: Bônus de ATK, Ataque Extra e Efeito Restritivo
-- ==========================================================
function s.buffcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToRemoveAsCost() end
    Duel.Remove(c, POS_FACEUP, REASON_COST)
end

function s.bufffilter(c)
    -- Verifica se pertence ao arquétipo "Celestial Guardian" e possui Nível para que a matemática de ATK funcione
    return c:IsFaceup() and c:IsSetCard(0x252) and c:HasLevel()
end

function s.bufftg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.bufffilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.bufffilter, tp, LOCATION_MZONE, 0, 1, e:GetHandler()) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, s.bufffilter, tp, LOCATION_MZONE, 0, 1, 1, e:GetHandler())
end

function s.buffop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    local c = e:GetHandler()
    
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        -- 1. Ganho de ATK igual ao Level x 100
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(tc:GetLevel() * 100)
        e1:SetReset(RESET_EVENT | RESETS_STANDARD | RESET_PHASE | PHASE_END)
        tc:RegisterEffect(e1)
        
        -- 2. Pode realizar um Segundo Ataque durante a mesma Battle Phase
        local e2 = Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_EXTRA_ATTACK)
        e2:SetValue(1)
        e2:SetReset(RESET_EVENT | RESETS_STANDARD | RESET_PHASE | PHASE_END)
        tc:RegisterEffect(e2)
        
        -- 3. Se atacar, oponente não pode ativar cartas/efeitos até o fim da Damage Step
        local e3 = Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_CONTINUOUS)
        e3:SetCode(EVENT_ATTACK_ANNOUNCE)
        e3:SetOperation(s.armop)
        e3:SetReset(RESET_EVENT | RESETS_STANDARD | RESET_PHASE | PHASE_END)
        tc:RegisterEffect(e3)
    end
end

function s.armop(e, tp, eg, ep, ev, re, r, rp)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetTargetRange(0, 1)
    e1:SetValue(1)
    -- Reseta automaticamente no exato momento que a Etapa de Dano (Damage Step) é concluída
    e1:SetReset(RESET_PHASE | PHASE_DAMAGE)
    Duel.RegisterEffect(e1, tp)
end