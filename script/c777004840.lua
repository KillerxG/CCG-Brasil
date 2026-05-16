-- East Wings Striker
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Colocar na Zona de Magias/Armadilhas e adicionar do Deck à mão
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND | CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, {id, 1})
    e1:SetTarget(s.pltg)
    e1:SetOperation(s.plop)
    c:RegisterEffect(e1)

    -- Efeito 2: Invocar por Invocação-Especial um monstro da Zona de Magias/Armadilhas
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

s.listed_series = {0x314}
s.listed_names = {id}

-- ==========================================================
-- Efeito 1: Colocar na Zona S&T e Buscar
-- ==========================================================
function s.thfilter(c)
    return c:IsSetCard(0x314) and c:IsMonster() and not c:IsCode(id) and c:IsAbleToHand()
end

function s.pltg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
            and Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.plop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    -- Confirma se a carta ativadora continua na mão e se há espaço na zona de magias
    if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp, LOCATION_SZONE) <= 0 then return end
    
    -- Realoca a carta da mão para a zona de Magias/Armadilhas
    if Duel.MoveToField(c, tp, tp, LOCATION_SZONE, POS_FACEUP, true) then
        -- Aplica os atributos de Magia Contínua
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_TYPE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetValue(TYPE_SPELL | TYPE_CONTINUOUS)
        e1:SetReset(RESET_EVENT | RESETS_STANDARD - RESET_TURN_SET)
        c:RegisterEffect(e1)
        
        -- Adiciona o monstro East Wings
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
        if #g > 0 then
            Duel.SendtoHand(g, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, g)
        end
    end
end

-- ==========================================================
-- Efeito 2: Invocar da Zona S&T e Travar o Extra Deck
-- ==========================================================
function s.spfilter(c, e, tp)
    -- Verifica se é originalmente um monstro, está virado para cima e tratado como magia
    return c:IsFaceup() and c:IsOriginalType(TYPE_MONSTER) and c:IsSetCard(0x314) 
        and c:IsContinuousSpell() and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.spfilter(chkc, e, tp) end
    if chk == 0 then 
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and Duel.IsExistingTarget(s.spfilter, tp, LOCATION_SZONE, 0, 1, nil, e, tp) 
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.spfilter, tp, LOCATION_SZONE, 0, 1, 1, nil, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
    end
    
    -- Aplica a restrição de não poder invocar do Extra Deck pelo resto do turno
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET | EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetDescription(aux.Stringid(id, 2)) -- String local que alerta sobre a restrição na tela
    e1:SetTargetRange(1, 0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE | PHASE_END)
    Duel.RegisterEffect(e1, tp)
end

-- Limite espacial para a trava do Extra Deck
function s.splimit(e, c)
    return c:IsLocation(LOCATION_EXTRA)
end