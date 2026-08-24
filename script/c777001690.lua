-- Thunder Force Witch - Junipher
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Special Summon da mão + Moeda (Buscar S/T)
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_COIN)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Efeito 2: Moeda por turno para aumentar o Nível (+1, max. 10)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_COIN)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.lvtg)
    e2:SetOperation(s.lvop)
    c:RegisterEffect(e2)

    -- Efeito 3 (Corrigido): Substituir destruição (Perguntando ao jogador + Once Per Turn)
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 3)) -- Nova string para o prompt de pergunta
    e3:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_DESTROY_REPLACE)
    e3:SetCountLimit(1) -- Once Per Turn aqui
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
	
	-- e5: Enquanto Nível 8 ou superior -> Reduz o Nível de todos os monstros do oponente em 1
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_UPDATE_LEVEL)
    e5:SetRange(LOCATION_MZONE)
    e5:SetTargetRange(0, LOCATION_MZONE)
    e5:SetCondition(s.lvldebuff_con)
    e5:SetValue(-1)
    c:RegisterEffect(e5)
end

-- Identificador nativo para mostrar o ícone de moeda na carta
s.toss_coin = true

-- ====================================================================
-- Efeito 1: Special Summon da Mão
-- ====================================================================
function s.spfilter(c)
    return c:IsFaceup() and not c:IsSetCard(0x301)
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    -- Controla no monsters OR all monsters are "Thunder Force"
    return Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0) == 0 
        or not Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.setfilter(c)
    return c:IsSetCard(0x301) and c:IsType(TYPE_SPELL + TYPE_TRAP) and c:IsSSetable()
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_COIN, nil, 0, tp, 1)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        -- Toss a coin and call it
        local call = Duel.AnnounceCoin(tp)
        local res = Duel.TossCoin(tp, 1)
        
        if call == res and Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 
            and Duel.IsExistingMatchingCard(s.setfilter, tp, LOCATION_DECK, 0, 1, nil) 
            and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
            
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
            local g = Duel.SelectMatchingCard(tp, s.setfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
            if #g > 0 then
                Duel.SSet(tp, g:GetFirst())
            end
        end
    end
end

-- ====================================================================
-- Efeito 2: Aumentar o Nível com Moeda
-- ====================================================================
function s.lvtg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsFaceup() and c:HasLevel() and c:GetLevel() < 10 end
    Duel.SetOperationInfo(0, CATEGORY_COIN, nil, 0, tp, 1)
end

function s.lvop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFaceup() and c:IsRelateToEffect(e) and c:HasLevel() and c:GetLevel() < 10 then
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
-- Efeito 3: Lógica de Substituição (Manual e Limitada)
-- ====================================================================
function s.reptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    -- Checagem de segurança: Só pergunta se a carta for destruída e tiver Nível > 1
    if chk == 0 then return c:IsReason(REASON_BATTLE + REASON_EFFECT) and not c:IsReason(REASON_REPLACE) 
        and c:HasLevel() and c:GetLevel() > 1 end
    
    -- Pergunta ao jogador se ele quer ativar a proteção
    return Duel.SelectYesNo(tp, aux.Stringid(id, 3))
end

function s.repop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    -- Reduz o nível em 1
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_LEVEL)
    e1:SetValue(-1)
    e1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(e1)
end

-- ====================================================================
-- Efeito 4: Proteção contra monstros menores com o Zeus em campo
-- ====================================================================
function s.bossfilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777001370
end

function s.indcon(e)
    return Duel.IsExistingMatchingCard(s.bossfilter, e:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, nil)
end

function s.indval(e, c)
    local tc = c -- Monstro oponente atacando
    if not tc or not tc:IsFaceup() then return false end
    
    local rating = 0
    if tc:IsType(TYPE_XYZ) then
        rating = tc:GetRank()
    elseif tc:IsType(TYPE_LINK) then
        rating = tc:GetLink()
    elseif tc:HasLevel() then
        rating = tc:GetLevel()
    else
        return false
    end
    
    -- O monstro oponente deve ter Nível/Rank/Link menor que o Nível atual da Junipher
    return rating > 0 and rating < e:GetHandler():GetLevel()
end

-- ====================================================================
-- Função de Condição do e5 (Aura de Redução de Nível)
-- ====================================================================
function s.lvldebuff_con(e)
    local c = e:GetHandler()
    -- Confere se a própria carta que tem o efeito está Face-Up, tem Nível, e se é Nível 8 ou maior
    return c:IsFaceup() and c:GetLevel() > 0 and c:GetLevel() >= 8
end