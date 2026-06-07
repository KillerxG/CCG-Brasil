-- Draconic Maiden - Ryuzu
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Special Summon Inerente da Mão (Se controlar "Draconic")
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    -- O "once per turn this way" exige a flag OATH para limitar a tentativa de invocação inerente
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    -- Efeito 2: Dano de Batalha e Efeito vira 0 (Se controlar o Blaze)
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(1, 0) -- Afeta você
    e2:SetCondition(s.damcon)
    c:RegisterEffect(e2)
    local e3 = e2:Clone()
    e3:SetCode(EFFECT_NO_EFFECT_DAMAGE)
    c:RegisterEffect(e3)

    -- Efeito 3: Normal/Special Summon -> Banir S/T e Reciclar Dragão
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_REMOVE + CATEGORY_TODECK)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET)
    e4:SetCode(EVENT_SUMMON_SUCCESS)
    e4:SetCountLimit(1, id + 1)
    e4:SetTarget(s.rmtg)
    e4:SetOperation(s.rmop)
    c:RegisterEffect(e4)
    local e5 = e4:Clone()
    e5:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e5)
end

-- ====================================================================
-- Efeito 1: Special Summon da Mão
-- ====================================================================
function s.draconicfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x300)
end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingMatchingCard(s.draconicfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

-- ====================================================================
-- Efeito 2: Proteção de Dano (Blaze)
-- ====================================================================
function s.blazefilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777000680
end

function s.damcon(e)
    local tp = e:GetHandlerPlayer()
    return Duel.IsExistingMatchingCard(s.blazefilter, tp, LOCATION_MZONE, 0, 1, nil)
end

-- ====================================================================
-- Efeito 3: Banir S/T e Embaralhar
-- ====================================================================
function s.rmfilter(c)
    return c:IsType(TYPE_SPELL + TYPE_TRAP) and c:IsAbleToRemove()
end

function s.tdfilter(c)
    -- Ao lidar com o banimento, é padrão verificar se a carta está virada para cima para ter certeza de que o jogo pode ler sua raça
    return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAbleToDeck()
end

function s.rmtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1 - tp) and s.rmfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.rmfilter, tp, 0, LOCATION_ONFIELD, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectTarget(tp, s.rmfilter, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
    
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, 1, 0, 0)
    Duel.SetPossibleOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_REMOVED)
end

function s.rmop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    
    -- Verifica se o alvo ainda está no campo e consegue ser banido com sucesso
    if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc, POS_FACEUP, REASON_EFFECT) > 0 then
        local g = Duel.GetMatchingGroup(s.tdfilter, tp, LOCATION_REMOVED, 0, nil)
        
        -- O "then you can" permite a opção de embaralhar o dragão se você quiser
        if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
            local sg = g:Select(tp, 1, 1, nil)
            Duel.SendtoDeck(sg, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
        end
    end
end