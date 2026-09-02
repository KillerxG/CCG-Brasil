-- Corrupted Okami - Crinsom Helm
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Descartar 1 OUTRO Yokai para invocar esta carta da mão/GY
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.spcost1)
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)

    -- Efeito 2: Não pode ser destruído em batalha
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- Efeito 3: Alvejar 2 Yokais diferentes no GY -> Adicionar 1 e Invocar o outro
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id + 1)
    e3:SetTarget(s.tgtg)
    e3:SetOperation(s.tgop)
    c:RegisterEffect(e3)
end

-- ====================================================================
-- Efeito 1: Invocação Especial da Mão ou Cemitério
-- ====================================================================
function s.dcfilter(c)
    return c:IsRace(RACE_YOKAI) and c:IsDiscardable()
end

function s.spcost1(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    -- Passar o 'c' no final garante que você descarta 1 *outro* Yokai e não a si mesmo se estiver na mão
    if chk == 0 then return Duel.IsExistingMatchingCard(s.dcfilter, tp, LOCATION_HAND, 0, 1, c) end
    Duel.DiscardHand(tp, s.dcfilter, 1, 1, REASON_COST + REASON_DISCARD, c)
end

function s.sptg1(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.spop1(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
    end
end

-- ====================================================================
-- Efeito 3: Alvejar 2 Yokais, Adicionar e Invocar
-- ====================================================================
function s.tgfilter(c, e, tp)
    -- As cartas precisam ser Yokai e ter pelo menos uma utilidade (ir pra mão ou invocar)
    return c:IsRace(RACE_YOKAI) and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e, 0, tp, false, false))
end

function s.rescon(sg, e, tp, mg)
    -- Garante que sejam exatamente 2 nomes diferentes
    if sg:GetClassCount(Card.GetCode) ~= 2 then return false end
    
    -- Testa as permutações: Pelo menos uma tem que ir pra mão e a outra invocar (ou vice-versa)
    local c1 = sg:GetFirst()
    local c2 = sg:GetNext()
    local b1 = c1:IsAbleToHand() and c2:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    local b2 = c2:IsAbleToHand() and c1:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    return b1 or b2
end

function s.tgtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return false end -- Desliga chkc padrão pois vamos usar SelectUnselectGroup
    
    local g = Duel.GetMatchingGroup(s.tgfilter, tp, LOCATION_GRAVE, 0, nil, e, tp)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 
        and aux.SelectUnselectGroup(g, e, tp, 2, 2, s.rescon, 0) end
        
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local sg = aux.SelectUnselectGroup(g, e, tp, 2, 2, s.rescon, 1, tp, HINTMSG_TARGET)
    Duel.SetTargetCard(sg)
    
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, sg, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, sg, 1, 0, 0)
end

function s.tgop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetTargetCards(e)
    if #g ~= 2 then return end
    
    local c1 = g:GetFirst()
    local c2 = g:GetNext()
    
    -- Reavalia as condições na resolução (caso algo mude no meio do chain)
    local b1 = c1:IsAbleToHand() and c2:IsCanBeSpecialSummoned(e, 0, tp, false, false) and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
    local b2 = c2:IsAbleToHand() and c1:IsCanBeSpecialSummoned(e, 0, tp, false, false) and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
    if not (b1 or b2) then return end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local hg = nil
    
    -- Se ambas servem para as duas coisas, você escolhe qual vai pra mão. 
    -- Se não, o jogo decide automaticamente a única opção válida.
    if b1 and b2 then
        hg = g:Select(tp, 1, 1, nil)
    elseif b1 then
        hg = Group.FromCards(c1)
    else
        hg = Group.FromCards(c2)
    end
    
    local tc = hg:GetFirst()
    local sc = g:Clone()
    sc:RemoveCard(tc)
    local spc = sc:GetFirst() -- spc é a carta que sobrou para Special Summon
    
    -- Manda a primeira pra mão e, se for bem sucedido, invoca a segunda
    if Duel.SendtoHand(tc, nil, REASON_EFFECT) > 0 and tc:IsLocation(LOCATION_HAND) then
        Duel.ConfirmCards(1 - tp, tc)
        Duel.SpecialSummon(spc, 0, tp, tp, false, false, POS_FACEUP)
    end
end