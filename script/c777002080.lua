-- Rockslash Knight
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Normal/Special Summon -> Enviar pro GY (+ Dano Opcional se controlar Haruna)
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOGRAVE + CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.tgtg)
    e1:SetOperation(s.tgop)
    c:RegisterEffect(e1)
    local e2 = e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)

    -- Efeito 2: Enviado do campo para o GY -> Reviver e Causar Dano
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCountLimit(1, id + 1)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

-- ====================================================================
-- Filtro Global da Haruna
-- ====================================================================
function s.harunafilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777002010
end

-- ====================================================================
-- Efeito 1: Foolish Burial Dinâmico + Dano
-- ====================================================================
function s.tgfilter(c, has_haruna)
    -- Tem que ser possível ir para o Cemitério
    if not c:IsAbleToGrave() then return false end
    
    -- Condição A: Carta "Rockslash" (Magia/Armadilha/Monstro), exceto ele mesmo
    if c:IsSetCard(0x309) and not c:IsCode(id) then return true end
    
    -- Condição B: Se possuir a Haruna, aceita qualquer monstro do tipo Rocha
    if has_haruna and c:IsRace(RACE_ROCK) and c:IsType(TYPE_MONSTER) then return true end
    
    return false
end

function s.tgtg(e, tp, eg, ep, ev, re, r, rp, chk)
    local has_haruna = Duel.IsExistingMatchingCard(s.harunafilter, tp, LOCATION_MZONE, 0, 1, nil)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.tgfilter, tp, LOCATION_DECK, 0, 1, nil, has_haruna) end
    
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
    -- Projeta o dano se a Haruna estiver no campo no momento da ativação
    if has_haruna then
        Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, 400)
    end
end

function s.tgop(e, tp, eg, ep, ev, re, r, rp)
    -- Verifica a Haruna dinamicamente para aplicar o filtro na resolução
    local has_haruna = Duel.IsExistingMatchingCard(s.harunafilter, tp, LOCATION_MZONE, 0, 1, nil)
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.tgfilter, tp, LOCATION_DECK, 0, 1, 1, nil, has_haruna)
    
    if #g > 0 and Duel.SendtoGrave(g, REASON_EFFECT) > 0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
        -- Após enviar com sucesso, "then," quebra o efeito para checar a Haruna e causar o dano
        if Duel.IsExistingMatchingCard(s.harunafilter, tp, LOCATION_MZONE, 0, 1, nil) then
            Duel.BreakEffect()
            Duel.Damage(1 - tp, 400, REASON_EFFECT)
        end
    end
end

-- ====================================================================
-- Efeito 2: Retorno do GY e Dano de Queima
-- ====================================================================
function s.rsfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x309)
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    -- Confere se a carta veio do campo E se você controla atualmente um Rockslash (excluindo ele mesmo, já que está no GY)
    return c:IsPreviousLocation(LOCATION_ONFIELD) and Duel.IsExistingMatchingCard(s.rsfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
        
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, 400)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        Duel.BreakEffect()
        -- "then," causa o dano obrigatoriamente após a Invocação
        Duel.Damage(1 - tp, 400, REASON_EFFECT)
        
        -- Aplica a restrição: Banir quando deixar o campo
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT + RESETS_REDIRECT)
        e1:SetValue(LOCATION_REMOVED)
        c:RegisterEffect(e1, true)
    end
end