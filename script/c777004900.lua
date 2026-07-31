-- Shadow Chronicler of Mythos
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- ====================================================================
    -- Invocação Link: 1 monstro DARK Spirit
    -- ====================================================================
    c:EnableReviveLimit()
    -- Link.AddProcedure(carta, filtro, min, max)
    Link.AddProcedure(c, s.matfilter, 1, 1)

    -- Efeito: Se Link Summoned -> Revelar Spirit na mão -> Buscar monstro de Nível maior
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.thcon)
    e1:SetCost(s.thcost)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
end

-- ====================================================================
-- Filtro do Material Link
-- ====================================================================
function s.matfilter(c, lc, stype, tp)
    -- Precisa ser simultaneamente DARK e Spirit
    return c:IsAttribute(ATTRIBUTE_DARK, lc, stype, tp) and c:IsType(TYPE_SPIRIT, lc, stype, tp)
end

-- ====================================================================
-- Efeito Gatilho: Revelar e Buscar
-- ====================================================================
function s.thcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.thfilter(c, race, attr, lvl)
    -- Verifica se tem o mesmo Tipo, Atributo e um Nível MAIOR
    return c:IsType(TYPE_MONSTER) and c:IsRace(race) and c:IsAttribute(attr) 
        and c:GetLevel() > lvl and c:IsAbleToHand()
end

function s.costfilter(c, tp)
    -- A carta na mão precisa ser Spirit, não estar pública (revelada) e TER um alvo válido no déqui
    return c:IsType(TYPE_SPIRIT) and not c:IsPublic()
        and Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil, c:GetRace(), c:GetAttribute(), c:GetLevel())
end

function s.thcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.costfilter, tp, LOCATION_HAND, 0, 1, nil, tp) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local g = Duel.SelectMatchingCard(tp, s.costfilter, tp, LOCATION_HAND, 0, 1, 1, nil, tp)
    
    Duel.ConfirmCards(1 - tp, g)
    Duel.ShuffleHand(tp)
    
    local tc = g:GetFirst()
    -- Cria uma relação segura entre a carta revelada e este efeito
    tc:CreateEffectRelation(e)
    -- Salva o objeto da carta para ser chamado na operação
    e:SetLabelObject(tc)
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    -- A validação dura (se o alvo existe) já foi garantida dentro do s.costfilter acima
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    -- Resgata a carta revelada na mão
    local tc = e:GetLabelObject()
    
    -- Se a carta ainda existe e a relação não foi quebrada
    if tc and tc:IsRelateToEffect(e) then
        -- Extrai os status exatos dela
        local race = tc:GetRace()
        local attr = tc:GetAttribute()
        local lvl = tc:GetLevel()
        
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil, race, attr, lvl)
        
        if #g > 0 then
            Duel.SendtoHand(g, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, g)
        end
    end
end