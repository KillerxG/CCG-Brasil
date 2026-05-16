-- Pyroland Salamander
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Revelar na mão, escavar 3, Invocar e enviar para o GY ou embaralhar
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON | CATEGORY_DECKDES)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCost(s.excxcost)
    e1:SetTarget(s.excxtg)
    e1:SetOperation(s.excxop)
    c:RegisterEffect(e1)

    -- Efeito 2: Invocação-Especial do Deck ao ser enviado do Campo para o GY
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

s.listed_series = {0x278}
s.listed_names = {id}

-- ==========================================================
-- Efeito 1: Escavar Topo do Deck
-- ==========================================================
function s.excxcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    -- Custo de revelar a si próprio na mão
    if chk == 0 then return not c:IsPublic() end
    Duel.ConfirmCards(1 - tp, c)
end

function s.excxtg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) >= 3 
        and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
        
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
    Duel.SetPossibleOperationInfo(0, CATEGORY_DECKDES, nil, 0, tp, 3)
end

function s.excxop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) < 3 then return end
    
    -- Revela as 3 cartas do topo
    Duel.ConfirmDecktop(tp, 3)
    local g = Duel.GetDecktopGroup(tp, 3)
    
    if #g > 0 then
        -- Checa se existe ao menos 1 carta "Pyroland"
        if g:IsExists(Card.IsSetCard, 1, nil, 0x278) then
            Duel.DisableShuffleCheck() -- Impede o embaralhamento durante o SendtoGrave
            
            if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
                Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
            end
            
            Duel.SendtoGrave(g, REASON_EFFECT)
        else
            -- Apenas aciona a função de embaralhar o Deck, misturando o topo de volta
            Duel.ShuffleDeck(tp)
        end
    end
end

-- ==========================================================
-- Efeito 2: Special Summon do Deck (Enviado do Campo ao GY)
-- ==========================================================
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.spfilter(c, e, tp)
    return c:IsSetCard(0x278) and c:IsLevelBelow(4) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_DECK, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
    if #g > 0 then
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
    end
end