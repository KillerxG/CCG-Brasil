-- Little Dark Magician Girl
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Special Summon da mão se não controlar monstros ou se todos forem "Magician Girl"
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.spcon1)
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)

    -- Efeito 2: Buscar carta "Magician Girl" ou que mencione a "Dark Magician Girl"
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TOHAND | CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1, {id, 2})
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    local e3 = e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    -- Efeito 3: Banir do GY para Invocar "Dark Magician Girl" da Mão com Bônus e Proteção
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCountLimit(1, {id, 3})
    e4:SetCondition(s.spcon2)
    e4:SetCost(aux.bfgcost)
    e4:SetTarget(s.sptg2)
    e4:SetOperation(s.spop2)
    c:RegisterEffect(e4)
end

-- Registros obrigatórios para otimizar a máquina de buscas do simulador
s.listed_names = {id, 38033121} -- 38033121 é a ID oficial da Dark Magician Girl
s.listed_series = {0x20a2, 0x30a2} -- 0x20a2 = Magician Girl / 0x30a2 = Dark Magician Girl

-- ==========================================================
-- Efeito 1: Invocação-Especial da Mão
-- ==========================================================
function s.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x20a2)
end

function s.spcon1(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetFieldGroup(tp, LOCATION_MZONE, 0)
    -- O jogador não pode ter monstros, ou todos os monstros em sua zona devem ser "Magician Girl" virados para cima
    return #g == 0 or (#g > 0 and g:FilterCount(s.cfilter, nil) == #g)
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

-- ==========================================================
-- Efeito 2: Buscar Carta para a Mão
-- ==========================================================
function s.thfilter(c)
    local is_mg = c:IsSetCard(0x20a2)
    -- Nova sintaxe direta da API em C++ do OCGCore: c:ListsCode(id)
    local mentions_dmg = c:ListsCode(38033121)
    return (is_mg or mentions_dmg) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

-- ==========================================================
-- Efeito 3: Invocar "Dark Magician Girl" com Buff e Imunidade
-- ==========================================================
function s.spcon2(e, tp, eg, ep, ev, re, r, rp)
    -- Condição: "If you control no monsters"
    return Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0) == 0
end

function s.spfilter2(c, e, tp)
    return c:IsSetCard(0x30a2) and c:IsMonster() and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.sptg2(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingMatchingCard(s.spfilter2, tp, LOCATION_HAND, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND)
end

function s.spop2(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.spfilter2, tp, LOCATION_HAND, 0, 1, 1, nil, e, tp)
    local tc = g:GetFirst()
    
    if tc and Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        local c = e:GetHandler()
        
        -- Torna o monstro inafetado por efeitos de cartas do oponente
        local e1 = Effect.CreateEffect(c)
        e1:SetDescription(3110) -- Código de Client Hint oficial: "Unaffected by opponent's card effects"
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE | EFFECT_FLAG_CLIENT_HINT)
        e1:SetRange(LOCATION_MZONE)
        e1:SetCode(EFFECT_IMMUNE_EFFECT)
        e1:SetValue(s.efilter)
        e1:SetReset(RESET_EVENT | RESETS_STANDARD)
        tc:RegisterEffect(e1, true)
        
        -- Concede 800 de ATK
        local e2 = Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_UPDATE_ATTACK)
        e2:SetValue(800)
        e2:SetReset(RESET_EVENT | RESETS_STANDARD)
        tc:RegisterEffect(e2, true)
        
        -- Concede 800 de DEF
        local e3 = e2:Clone()
        e3:SetCode(EFFECT_UPDATE_DEFENSE)
        tc:RegisterEffect(e3, true)
    end
end

function s.efilter(e, te)
    -- Garante que só fique imune contra cartas com dono diferente de quem o controla
    return te:GetOwnerPlayer() ~= e:GetHandlerPlayer()
end