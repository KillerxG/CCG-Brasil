-- Pyroland Lizardman Knight
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Enviar 1 "Pyroland" do Deck/Campo, Special Summon da mão e enviar 3 ao GY
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOGRAVE | CATEGORY_SPECIAL_SUMMON | CATEGORY_DECKDES)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, {id, 1})
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Efeito 2: Se enviado do Deck ao GY, resgatar "Pyroland" do GY (Mão ou Set)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TOHAND | CATEGORY_LEAVE_GRAVE)
    e2:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET | EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

s.listed_series = {0x278}
s.listed_names = {id}

-- ==========================================================
-- Efeito 1: Envio, Special Summon e Mill (Enviar 3)
-- ==========================================================
function s.tgfilter(c)
    -- A carta do campo DEVE estar virada para cima, e a do Deck não tem essa restrição
    return c:IsSetCard(0x278) and c:IsAbleToGrave() and (c:IsLocation(LOCATION_DECK) or c:IsFaceup())
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then 
        local ct = Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0)
        -- Atesta logicamente a quantidade absoluta de cartas no deck baseada na origem do card a ser enviado
        local b1 = Duel.IsExistingMatchingCard(s.tgfilter, tp, LOCATION_ONFIELD, 0, 1, c) and ct >= 3
        local b2 = Duel.IsExistingMatchingCard(s.tgfilter, tp, LOCATION_DECK, 0, 1, c) and ct >= 4
        
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
            and Duel.IsPlayerCanDiscardDeck(tp, 3)
            and (b1 or b2)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK | LOCATION_ONFIELD)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 0, tp, 3)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.tgfilter, tp, LOCATION_DECK | LOCATION_ONFIELD, 0, 1, 1, c)
    
    if #g > 0 and Duel.SendtoGrave(g, REASON_EFFECT) > 0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
        if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
            Duel.BreakEffect()
            Duel.DiscardDeck(tp, 3, REASON_EFFECT)
        end
    end
end

-- ==========================================================
-- Efeito 2: Recuperar "Pyroland" do GY (Para a Mão ou Set)
-- ==========================================================
function s.thcon(e, tp, eg, ep, ev, re, r, rp)
    -- Assegura que veio direto do Deck para o Cemitério
    return e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end

function s.thfilter(c)
    if not (c:IsSetCard(0x278) and not c:IsCode(id)) then return false end
    -- Atesta as viabilidades para os dois desfechos
    return c:IsAbleToHand() or (c:IsSpellTrap() and c:IsSSetable())
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.thfilter, tp, LOCATION_GRAVE, 0, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g = Duel.SelectTarget(tp, s.thfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    -- Declarado como "Possible" porque a carta pode acabar não indo para a mão, e sim sendo Setada
    Duel.SetPossibleOperationInfo(0, CATEGORY_TOHAND, g, 1, tp, LOCATION_GRAVE)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        local b1 = tc:IsAbleToHand()
        local b2 = tc:IsSpellTrap() and tc:IsSSetable()
        local op = 0
        
        -- Se puder fazer os dois, gera a janela de escolhas para o jogador
        if b1 and b2 then
            op = Duel.SelectOption(tp, aux.Stringid(id, 2), aux.Stringid(id, 3))
        elseif b1 then
            op = 0
        elseif b2 then
            op = 1
        else
            return
        end
        
        if op == 0 then
            Duel.SendtoHand(tc, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, tc)
        else
            Duel.SSet(tp, tc)
        end
    end
end