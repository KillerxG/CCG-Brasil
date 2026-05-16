-- East Wings Swordsman
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Trigger Effect: Quando Invocado por Invocação-Normal ou Especial
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SEARCH | CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1, {id, 1})
    e1:SetTarget(s.pltg)
    e1:SetOperation(s.plop)
    c:RegisterEffect(e1)
    
    -- Clone para a Invocação-Especial
    local e2 = e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
end

s.listed_series = {0x314}

-- Filtros usando as funções de atalho atualizadas
function s.plfilter(c)
    return c:IsSetCard(0x314) and c:IsMonster() and not c:IsForbidden()
end

function s.thfilter(c)
    return c:IsSetCard(0x314) and c:IsRitualSpell() and c:IsAbleToHand()
end

function s.pltg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
            and Duel.IsExistingMatchingCard(s.plfilter, tp, LOCATION_DECK, 0, 1, nil)
    end
    Duel.SetPossibleOperationInfo(0, CATEGORY_TOHAND, nil, 0, tp, LOCATION_DECK)
end

function s.plop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetLocationCount(tp, LOCATION_SZONE) <= 0 then return end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOFIELD)
    local g = Duel.SelectMatchingCard(tp, s.plfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    local tc = g:GetFirst()
    
    if tc and Duel.MoveToField(tc, tp, tp, LOCATION_SZONE, POS_FACEUP, true) then
        -- Aplica o efeito que transforma o monstro legalmente em Spell Contínua
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_TYPE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetValue(TYPE_SPELL | TYPE_CONTINUOUS)
        e1:SetReset(RESET_EVENT | RESETS_STANDARD)
        tc:RegisterEffect(e1)

        -- Prossegue com a busca se houver Magia de Ritual disponível
        local hg = Duel.GetMatchingGroup(s.thfilter, tp, LOCATION_DECK, 0, nil)
        if #hg > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
            local sg = hg:Select(tp, 1, 1, nil)
            Duel.SendtoHand(sg, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, sg)
        end
    end
end