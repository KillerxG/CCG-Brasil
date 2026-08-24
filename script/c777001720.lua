-- Thunder Force Tamer
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Revelar na mão + Moeda -> Special Summon de si e de 1 LIGHT Thunder da mão/GY
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_COIN)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Efeito 2: Oponente adiciona carta do Deck -> Moeda para subir Nível (+1, max. 10)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_COIN)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_HAND)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.lvcon)
    e2:SetTarget(s.lvtg)
    e2:SetOperation(s.lvop)
    c:RegisterEffect(e2)

    -- Efeito 3: Substituir destruição reduzindo o Nível em 1 (Manual + Once Per Turn)
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_DESTROY_REPLACE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.reptg)
    e3:SetOperation(s.repop)
    c:RegisterEffect(e3)

    -- Efeito 4: Proteção de Batalha baseada no Nível contra monstros menores (Com Zeus)
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e4:SetCondition(s.indcon)
    e4:SetValue(s.indval)
    c:RegisterEffect(e4)
	
	-- e5: Ganho de ATK para os seus "Thunder Force" (Nível 8+)
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_UPDATE_ATTACK)
    e5:SetRange(LOCATION_MZONE)
    e5:SetTargetRange(LOCATION_MZONE, 0) -- Apenas o seu campo
    e5:SetCondition(s.aura_con)
    e5:SetTarget(aux.TargetBoolFunction(Card.IsSetCard, 0x301)) -- Filtro: Apenas Thunder Force
    e5:SetValue(500)
    c:RegisterEffect(e5)
    
    -- e6: Ganho de DEF (Clonado do e5)
    local e6 = e5:Clone()
    e6:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e6)

    -- e7: Perda de ATK para os monstros do oponente (Nível 8+)
    local e7 = Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_FIELD)
    e7:SetCode(EFFECT_UPDATE_ATTACK)
    e7:SetRange(LOCATION_MZONE)
    e7:SetTargetRange(0, LOCATION_MZONE) -- Apenas o campo do oponente
    e7:SetCondition(s.aura_con)
    e7:SetValue(-500)
    c:RegisterEffect(e7)
    
    -- e8: Perda de DEF (Clonado do e7)
    local e8 = e7:Clone()
    e8:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e8)
end

-- Identificador nativo para mostrar o ícone de moeda
s.toss_coin = true

-- ====================================================================
-- Efeito 1: Revelar e Invocar da Mão + Suporte LIGHT Thunder
-- ====================================================================
function s.spfilter(c, e, tp)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_THUNDER) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return not c:IsPublic() and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_COIN, nil, 0, tp, 1)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    
    local call = Duel.AnnounceCoin(tp)
    local res = Duel.TossCoin(tp, 1)
    
    if call == res then
        if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
            -- "...and if you do, you can Special Summon 1 LIGHT Thunder monster from your hand or GY."
            if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 
                and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter), tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, nil, e, tp)
                and Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
                
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
                local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.spfilter), tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
                if #g > 0 then
                    Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
                end
            end
        end
    end
end

-- ====================================================================
-- Efeito 2: Oponente puxa carta do Deck -> Moeda para subir Nível (+1)
-- ====================================================================
function s.cfilter(c,tp)
	return c:IsControler(tp)
end
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DRAW and eg:IsExists(s.cfilter,1,nil,1-tp)
end

function s.lvtg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    -- Agora verificamos a Fase aqui, onde o comando Duel.GetPhase() é permitido
    if chk == 0 then return Duel.GetCurrentPhase() ~= PHASE_DRAW and c:IsFaceup() and c:GetLevel() > 0 and c:GetLevel() < 10 end
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
-- Efeito 3: Substituir Destruição reduzindo Nível em 1 (Manual + Once Per Turn)
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
-- Efeito 4: Proteção de Batalha baseada no Nível contra monstros menores (Com Zeus)
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

-- ====================================================================
-- Função de Condição da Aura (ATK/DEF)
-- ====================================================================
function s.aura_con(e)
    local c = e:GetHandler()
    -- Ativa apenas se a própria carta for Nível 8 ou maior
    return c:IsFaceup() and c:GetLevel() > 0 and c:GetLevel() >= 8
end