-- Thunder Force Mission
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Special Summon do Deck + Cara ou Coroa
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_COIN)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Efeito 2: Recuperar do GY para a mão se controlar o Zeus
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

-- Identificador nativo para a engine exibir o ícone de moeda na carta
s.toss_coin = true 

-- ====================================================================
-- Efeito 1: Special Summon e Lançamento de Moeda
-- ====================================================================
function s.spfilter(c, e, tp)
    return c:IsSetCard(0x301) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_DECK, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
    Duel.SetOperationInfo(0, CATEGORY_COIN, nil, 0, tp, 1)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
    local tc = g:GetFirst()
    
    if tc and Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        -- "...then toss a coin and call it."
        Duel.BreakEffect()
        -- Abre a janela pro jogador gritar Cara ou Coroa
        local call = Duel.AnnounceCoin(tp) 
        -- Joga a moeda
        local res = Duel.TossCoin(tp, 1)   
        
        if call == res then
            -- Acertou (Right): Aumenta o Nível em 2 (max. 10)
            if tc:IsFaceup() and tc:HasLevel() and tc:GetLevel() < 10 then
                -- Calcula matematicamente para não exceder o limite de 10
                local lvl_increase = math.min(2, 10 - tc:GetLevel())
                
                local e1 = Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_LEVEL)
                e1:SetValue(lvl_increase)
                e1:SetReset(RESET_EVENT + RESETS_STANDARD)
                tc:RegisterEffect(e1)
            end
        else
            -- Errou (Wrong): Trava as invocações (exceto Thunder)
            local e2 = Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_FIELD)
            e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
            e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e2:SetDescription(aux.Stringid(id, 2))
            e2:SetTargetRange(1, 0)
            e2:SetTarget(s.splimit)
            e2:SetReset(RESET_PHASE + PHASE_END)
            Duel.RegisterEffect(e2, tp)
        end
    end
end

function s.splimit(e, c)
    return not c:IsRace(RACE_THUNDER)
end

-- ====================================================================
-- Efeito 2: Recuperar do GY para a Mão (Checagem do Zeus)
-- ====================================================================
function s.bossfilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777001370
end

function s.thcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.bossfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsAbleToHand() end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoHand(c, nil, REASON_EFFECT)
    end
end