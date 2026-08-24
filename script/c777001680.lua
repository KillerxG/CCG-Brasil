-- Thunder Force Swordsman - Carlos
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Reduzir nível de 1 Thunder -> Special Summon do GY
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Efeito 2: Moeda para aumentar o Nível (+1, max. 10)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_COIN)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.lvtg)
    e2:SetOperation(s.lvop)
    c:RegisterEffect(e2)

    -- Efeito 3: Substituir destruição reduzindo o Nível em 1 (Manual + Once Per Turn)
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_DESTROY_REPLACE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.reptg)
    e3:SetOperation(s.repop)
    c:RegisterEffect(e3)

    -- Efeito 4A: Nível 8 ou superior -> Oponente é forçado a atacar
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_MUST_ATTACK)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(0, LOCATION_MZONE)
    e4:SetCondition(s.bosslvlcon)
    c:RegisterEffect(e4)

    -- Efeito 4B: Nível 8 ou superior -> Você escolhe os alvos do ataque (Patrician of Darkness)
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_PATRICIAN_OF_DARKNESS)
    e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e5:SetRange(LOCATION_MZONE)
    e5:SetTargetRange(0, 1)
    e5:SetCondition(s.bosslvlcon)
    c:RegisterEffect(e5)

    -- Efeito 5: Proteção de Batalha baseada no Nível contra monstros menores (Com Zeus)
    local e6 = Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e6:SetCondition(s.indcon)
    e6:SetValue(s.indval)
    c:RegisterEffect(e6)
end

-- Identificador nativo para mostrar o ícone de moeda
s.toss_coin = true

-- ====================================================================
-- Efeito 1: Special Summon do GY
-- ====================================================================
function s.thfilter(c)
    -- Thunder monster, virado para cima, e que tenha Nível 2 ou superior
    return c:IsFaceup() and c:IsRace(RACE_THUNDER) and c:GetLevel() > 0 and c:GetLevel() >= 2
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.thfilter(chkc) end
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false)
        and Duel.IsExistingTarget(s.thfilter, tp, LOCATION_MZONE, 0, 1, nil) end
        
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g = Duel.SelectTarget(tp, s.thfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    
    if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetLevel() >= 2 then
        -- Reduz o nível do alvo em 2
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_LEVEL)
        e1:SetValue(-2)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(e1)
        
        -- Special Summon do Carlos
        if c:IsRelateToEffect(e) then
            Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
        end
    end
end

-- ====================================================================
-- Efeito 2: Moeda para subir Nível (+1)
-- ====================================================================
function s.lvtg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsFaceup() and c:GetLevel() > 0 and c:GetLevel() < 10 end
    Duel.SetOperationInfo(0, CATEGORY_COIN, nil, 0, tp, 1)
end

function s.lvop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFaceup() and c:IsRelateToEffect(e) and c:GetLevel() > 0 and c:GetLevel() < 10 then
        local call = Duel.AnnounceCoin(tp)
        local res = Duel.TossCoin(tp, 1)
        
        if call == res then
            local max_inc = math.min(1, 10 - c:GetLevel())
            if max_inc > 0 then
                local e1 = Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_LEVEL)
                e1:SetValue(max_inc)
                e1:SetReset(RESET_EVENT + RESETS_STANDARD)
                c:RegisterEffect(e1)
            end
        end
    end
end

-- ====================================================================
-- Efeito 3: Substituir Destruição reduzindo Nível em 1
-- ====================================================================
function s.reptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsReason(REASON_BATTLE + REASON_EFFECT) and not c:IsReason(REASON_REPLACE) 
        and c:GetLevel() > 1 end
    return Duel.SelectYesNo(tp, aux.Stringid(id, 2))
end

function s.repop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_LEVEL)
    e1:SetValue(-1)
    e1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(e1)
end

-- ====================================================================
-- Efeitos 4A e 4B: Nível 8+ (Forçar ataques e Escolher Alvos)
-- ====================================================================
function s.bosslvlcon(e)
    local c = e:GetHandler()
    return c:IsFaceup() and c:GetLevel() > 0 and c:GetLevel() >= 8
end

-- ====================================================================
-- Efeito 5: Proteção de Batalha (Com Zeus)
-- ====================================================================
function s.bossfilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777001370
end

function s.indcon(e)
    return Duel.IsExistingMatchingCard(s.bossfilter, e:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, nil)
end

function s.indval(e, c)
    local tc = c
    if not tc or not tc:IsFaceup() then return false end
    
    local rating = 0
    if tc:IsType(TYPE_XYZ) then
        rating = tc:GetRank()
    elseif tc:IsType(TYPE_LINK) then
        rating = tc:GetLink()
    elseif tc:IsType(TYPE_MONSTER) and not tc:IsType(TYPE_XYZ + TYPE_LINK) then
        rating = tc:GetLevel()
    else
        return false
    end
    
    return rating > 0 and rating < e:GetHandler():GetLevel()
end