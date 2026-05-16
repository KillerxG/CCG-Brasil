-- Creature-Warden, Tigor
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Revelar 2, descartar esta carta, colocar a outra no topo do Deck e comprar
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_HANDES | CATEGORY_TODECK | CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCost(s.cost1)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)

    -- Efeito 2: Revelar monstro da mão para colocar no topo, Invocar do GY e Comprar (se tiver Ritual)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TODECK | CATEGORY_SPECIAL_SUMMON | CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCost(s.cost2)
    e2:SetTarget(s.tg2)
    e2:SetOperation(s.op2)
    c:RegisterEffect(e2)
end

s.listed_series = {0x251}

-- ==========================================================
-- Efeito 1: Revelar (Custo), Descartar e Comprar (Efeito)
-- ==========================================================
function s.cwfilter(c)
    return c:IsSetCard(0x251) and c:IsMonster() and not c:IsPublic()
end

function s.cost1(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return not c:IsPublic() and Duel.IsExistingMatchingCard(s.cwfilter, tp, LOCATION_HAND, 0, 1, c) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local g = Duel.SelectMatchingCard(tp, s.cwfilter, tp, LOCATION_HAND, 0, 1, 1, c)
    
    -- Revela ambas as cartas para o oponente
    local cg = Group.FromCards(c, g:GetFirst())
    Duel.ConfirmCards(1 - tp, cg)
    Duel.ShuffleHand(tp)
    
    -- Preserva APENAS a outra carta na memória para ser colocada no topo no Operation
    g:KeepAlive()
    e:SetLabelObject(g)
end

function s.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsPlayerCanDraw(tp, 1) end
    Duel.SetOperationInfo(0, CATEGORY_HANDES, c, 1, tp, LOCATION_HAND)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_HAND)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.op1(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = e:GetLabelObject()
    if not g then return end
    
    local tc = g:GetFirst()
    
    -- "discard this card, and if you do..."
    if c:IsRelateToEffect(e) and Duel.SendtoGrave(c, REASON_EFFECT | REASON_DISCARD) > 0 and c:IsLocation(LOCATION_GRAVE) then
        -- "...place the other monster on the top of your Deck, then draw 1 card..."
        if tc and tc:IsLocation(LOCATION_HAND) then
            if Duel.SendtoDeck(tc, nil, SEQ_DECKTOP, REASON_EFFECT) > 0 and tc:IsLocation(LOCATION_DECK) then
                if Duel.Draw(tp, 1, REASON_EFFECT) > 0 then
                    -- "...then if your opponent controls a monster, you can draw 1 card."
                    if Duel.GetFieldGroupCount(tp, 0, LOCATION_MZONE) > 0 and Duel.IsPlayerCanDraw(tp, 1) then
                        if Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
                            Duel.BreakEffect()
                            Duel.Draw(tp, 1, REASON_EFFECT)
                        end
                    end
                end
            end
        end
    end
    
    -- Limpa a memória
    g:DeleteGroup()
end

-- ==========================================================
-- Efeito 2: Invocação do GY e Compra opcional por Ritual
-- ==========================================================
function s.cost2(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.cwfilter, tp, LOCATION_HAND, 0, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local g = Duel.SelectMatchingCard(tp, s.cwfilter, tp, LOCATION_HAND, 0, 1, 1, nil)
    Duel.ConfirmCards(1 - tp, g)
    Duel.ShuffleHand(tp)
    
    g:KeepAlive()
    e:SetLabelObject(g)
end

function s.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_HAND)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.ritfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_RITUAL)
end

function s.op2(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = e:GetLabelObject()
    if not g then return end
    
    local tc = g:GetFirst()
    if tc and tc:IsLocation(LOCATION_HAND) then
        -- Manda a carta revelada pro topo
        if Duel.SendtoDeck(tc, nil, SEQ_DECKTOP, REASON_EFFECT) > 0 and tc:IsLocation(LOCATION_DECK) then
            -- Se der sucesso, Invoca Especialmente esta carta
            if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
                
                -- "...then if you control a Ritual monster, you can draw 1 card."
                if Duel.IsExistingMatchingCard(s.ritfilter, tp, LOCATION_MZONE, 0, 1, nil) and Duel.IsPlayerCanDraw(tp, 1) then
                    if Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
                        Duel.BreakEffect()
                        Duel.Draw(tp, 1, REASON_EFFECT)
                    end
                end
            end
        end
    end
    g:DeleteGroup()
end