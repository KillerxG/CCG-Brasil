-- Corrupted Okami - Evil Rao
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Special Summon da mão se controlar um monstro Yokai
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.spcon1)
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)

    -- Efeito 2: Se Normal ou Special Summoned -> Revelar Yokai na mão -> SS Yokai do Deck (nome diferente)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1, id + 1)
    e2:SetCost(s.spcost2)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)

    -- Clonamos o gatilho para ativar também em Invocação-Especial
    local e3 = e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
end

-- ====================================================================
-- Efeito 1: Invocação Especial da Mão (Ignição)
-- ====================================================================
function s.cfilter(c)
    -- Checa se o monstro está virado para cima e pertence à raça Yokai
    return c:IsFaceup() and c:IsRace(RACE_YOKAI)
end

function s.spcon1(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.sptg1(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

function s.spop1(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
    end
end

-- ====================================================================
-- Efeito 2: Revelar da Mão para Invocar do Deck (Gatilho)
-- ====================================================================
function s.spfilter2(c, code, e, tp)
    -- Precisa ser Yokai, NÃO pode ter o mesmo código da carta revelada e tem que ser invocável
    return c:IsRace(RACE_YOKAI) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.revfilter(c, e, tp)
    -- Verifica a viabilidade do custo: Se revelar este Yokai, ainda sobra alvo válido no deck?
    return c:IsRace(RACE_YOKAI) and not c:IsPublic() 
        and Duel.IsExistingMatchingCard(s.spfilter2, tp, LOCATION_DECK, 0, 1, nil, c:GetCode(), e, tp)
end

function s.spcost2(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.revfilter, tp, LOCATION_HAND, 0, 1, nil, e, tp) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    
    -- Seleciona 1 carta na sua mão que cumpra as exigências para revelar
    local g = Duel.SelectMatchingCard(tp, s.revfilter, tp, LOCATION_HAND, 0, 1, 1, nil, e, tp)
    Duel.ConfirmCards(1 - tp, g)
    Duel.ShuffleHand(tp)
    
    -- Salva o código da carta revelada no "Label" do efeito
    e:SetLabel(g:GetFirst():GetCode())
end

function s.sptg2(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end

function s.spop2(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    
    -- Recupera o código da carta revelada no custo
    local code = e:GetLabel()
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    -- Busca no deck usando o código memorizado para excluir nomes repetidos
    local g = Duel.SelectMatchingCard(tp, s.spfilter2, tp, LOCATION_DECK, 0, 1, 1, nil, code, e, tp)
    
    if #g > 0 then
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
    end
end