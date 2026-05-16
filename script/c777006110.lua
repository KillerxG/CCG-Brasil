-- Creature-Warden, Luna
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Revelar, Setar S/T do Deck, Descartar e (opcional) colocar no Topo do Deck
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_HANDES | CATEGORY_TODECK | CATEGORY_SET)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCost(s.setcost)
    e1:SetTarget(s.settg)
    e1:SetOperation(s.setop)
    c:RegisterEffect(e1)

    -- Efeito 2: Special Summon, colocar alvo no Topo do Deck e Comprar
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON | CATEGORY_TODECK | CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

s.listed_series = {0x251}
s.listed_names = {id}

-- ==========================================================
-- Efeito 1: Revelar, Setar e Descartar
-- ==========================================================
function s.setcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return not c:IsPublic() end
    Duel.ConfirmCards(1 - tp, c)
end

function s.setfilter(c)
    -- Magia ou armadilha direto do Deck
    return c:IsSetCard(0x251) and c:IsSpellTrap() and c:IsSSetable()
end

function s.topfilter(c)
    return c:IsSetCard(0x251) and c:IsMonster() and not c:IsCode(id)
end

function s.settg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then 
        return Duel.IsExistingMatchingCard(s.setfilter, tp, LOCATION_DECK, 0, 1, nil)
        and c:IsDiscardable(REASON_EFFECT)
    end
    Duel.SetOperationInfo(0, CATEGORY_SET, nil, 1, tp, LOCATION_DECK)
    Duel.SetOperationInfo(0, CATEGORY_HANDES, c, 1, tp, LOCATION_HAND)
    -- Operação ajustada para "Possible" por causa do "you can take"
    Duel.SetPossibleOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_DECK)
end

function s.setop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
    local g = Duel.SelectMatchingCard(tp, s.setfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    
    if #g > 0 and Duel.SSet(tp, g:GetFirst()) > 0 then
        if c:IsRelateToEffect(e) and Duel.SendtoGrave(c, REASON_EFFECT | REASON_DISCARD) > 0 and c:IsLocation(LOCATION_GRAVE) then
            local tg = Duel.GetMatchingGroup(s.topfilter, tp, LOCATION_DECK, 0, nil)
            
            -- Pergunta ao jogador se ele quer realizar o efeito opcional
            if #tg > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
                local sg = tg:Select(tp, 1, 1, nil)
                -- Embaralha o deck antes para que o MoveSequence coloque a carta selecionada isoladamente no topo
                Duel.ShuffleDeck(tp)
                Duel.MoveSequence(sg:GetFirst(), SEQ_DECKTOP)
                Duel.ConfirmCards(1 - tp, sg)
            end
        end
    end
end

-- ==========================================================
-- Efeito 2: Invocar do GY e Manipular Topo
-- ==========================================================
function s.spfilter(c)
    return c:IsSetCard(0x251) and c:IsMonster() and c:IsAbleToDeck()
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc) and chkc ~= c end
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
        and Duel.IsExistingTarget(s.spfilter, tp, LOCATION_GRAVE, 0, 1, c) end
        
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectTarget(tp, s.spfilter, tp, LOCATION_GRAVE, 0, 1, 1, c)
    
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, 1, 0, 0)
    Duel.SetPossibleOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        if tc and tc:IsRelateToEffect(e) then
            if Duel.SendtoDeck(tc, nil, SEQ_DECKTOP, REASON_EFFECT) > 0 and tc:IsLocation(LOCATION_DECK) then
                if Duel.GetFieldGroupCount(tp, 0, LOCATION_MZONE) > Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0)
                    and Duel.IsPlayerCanDraw(tp, 1) then
                    if Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
                        Duel.BreakEffect()
                        Duel.Draw(tp, 1, REASON_EFFECT)
                    end
                end
            end
        end
    end
end