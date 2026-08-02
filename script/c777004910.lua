-- Specter of Lost Travelers
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Destruir 1 do seu campo -> Special Summon da mão
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DESTROY + CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)

    -- Efeito 2: Monstro do oponente destruído em batalha -> Comprar 1 carta
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EVENT_BATTLE_DESTROYED)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.drcon)
    e2:SetTarget(s.drtg)
    e2:SetOperation(s.drop)
    c:RegisterEffect(e2)

    -- Efeito 3: Reviver 1 monstro do GY no campo oponente (ATK/DEF 0, Negado)
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id + 2)
    e3:SetTarget(s.sptg2)
    e3:SetOperation(s.spop2)
    c:RegisterEffect(e3)
end

-- ====================================================================
-- Efeito 1: Destruir e Special Summon da Mão
-- ====================================================================
function s.desfilter(c, tp)
    -- Garante que se destruir este monstro, haverá espaço para invocar o Specter
    return Duel.GetMZoneCount(tp, c) > 0
end

function s.sptg1(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.desfilter(chkc, tp) end
    if chk == 0 then return Duel.IsExistingTarget(s.desfilter, tp, LOCATION_MZONE, 0, 1, nil, tp)
        and e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false) end
        
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, s.desfilter, tp, LOCATION_MZONE, 0, 1, 1, nil, tp)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

function s.spop1(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    
    if tc:IsRelateToEffect(e) and Duel.Destroy(tc, REASON_EFFECT) > 0 then
        if c:IsRelateToEffect(e) then
            Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
        end
    end
end

-- ====================================================================
-- Efeito 2: Comprar ao Destruir em Batalha
-- ====================================================================
function s.drfilter(c, tp)
    -- Verifica se quem foi destruído era controlado pelo oponente
    return c:IsPreviousControler(1 - tp)
end

function s.drcon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.drfilter, 1, nil, tp)
end

function s.drtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDraw(tp, 1) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.drop(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    Duel.Draw(p, d, REASON_EFFECT)
end

-- ====================================================================
-- Efeito 3: Reviver para o Oponente (Status Zerados)
-- ====================================================================
function s.spfilter2(c, e, tp)
    -- Importante testar se pode ser invocado no campo do oponente (1 - tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP, 1 - tp)
end

function s.sptg2(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter2(chkc, e, tp) end
    if chk == 0 then return Duel.GetLocationCount(1 - tp, LOCATION_MZONE) > 0
        and Duel.IsExistingTarget(s.spfilter2, tp, LOCATION_GRAVE, 0, 1, nil, e, tp) end
        
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.spfilter2, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function s.spop2(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    local c = e:GetHandler()
    
    if tc:IsRelateToEffect(e) and Duel.GetLocationCount(1 - tp, LOCATION_MZONE) > 0 then
        -- Inicia a invocação passo a passo (Step) para aplicar os debuffs antes de entrar de vez
        if Duel.SpecialSummonStep(tc, 0, tp, 1 - tp, false, false, POS_FACEUP) then
            
            -- ATK 0
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SET_ATTACK)
            e1:SetValue(0)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(e1, true)
            
            -- DEF 0
            local e2 = e1:Clone()
            e2:SetCode(EFFECT_SET_DEFENSE)
            tc:RegisterEffect(e2, true)
            
            -- Negado
            local e3 = Effect.CreateEffect(c)
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_DISABLE)
            e3:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(e3, true)
            
            local e4 = Effect.CreateEffect(c)
            e4:SetType(EFFECT_TYPE_SINGLE)
            e4:SetCode(EFFECT_DISABLE_EFFECT)
            e4:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(e4, true)
            
            Duel.SpecialSummonComplete()
        end
    end
end