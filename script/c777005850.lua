-- Celestial Guardian's Prayer
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Descartar 1 carta para Invocar do Deck e Equipar, depois (opcional) Invocar da Mão
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON | CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Efeito 2: Banir do GY, dar alvo em 1 Equip Spell no GY e adicionar à mão
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

s.listed_series = {0x252}

-- ==========================================================
-- Efeito 1: Invocação-Especial e Equipamento
-- ==========================================================
function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
    -- Verifica se há cartas na mão que possam ser descartadas como custo
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, e:GetHandler()) end
    Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1, REASON_COST | REASON_DISCARD)
end

function s.spfilter(c, e, tp)
    return c:IsSetCard(0x252) and c:IsMonster() and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then 
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_DECK, 0, 1, nil, e, tp) 
        -- Atesta genericamente se existe ao menos 1 magia de equipamento no Deck ou GY para suprir o texto
        and Duel.IsExistingMatchingCard(Card.IsType, tp, LOCATION_DECK | LOCATION_GRAVE, 0, 1, nil, TYPE_EQUIP)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
    Duel.SetOperationInfo(0, CATEGORY_EQUIP, nil, 1, tp, LOCATION_DECK | LOCATION_GRAVE)
    -- Declaração possível de invocação da mão (evita falsos positivos com a Ash Blossom)
    Duel.SetPossibleOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND)
end

function s.eqfilter(c, mc)
    -- Assegura que o alvo selecionado é uma Magia de Equipamento legal e tem permissão oficial para equipar o monstro
    return c:IsSpell() and c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(mc)
end

function s.handspfilter(c, e, tp)
    return c:IsSetCard(0x252) and c:IsMonster() and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
    local tc = g:GetFirst()
    
    -- Invocou com sucesso o monstro do Deck ("...and if you do, equip it...")
    if tc and Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
        -- O filtro só aprova as Magias de Equipamento que podem ser atreladas ao monstro recém-invocado
        local eqg = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.eqfilter), tp, LOCATION_DECK | LOCATION_GRAVE, 0, 1, 1, nil, tc)
        local eqc = eqg:GetFirst()
        
        -- Equipa a carta escolhida ("...then, if your opponent controls 2 or more monsters...")
        if eqc and Duel.Equip(tp, eqc, tc) then
            if Duel.GetFieldGroupCount(tp, 0, LOCATION_MZONE) >= 2 then
                -- Confirma se há espaço e alvo legal na Mão
                if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and Duel.IsExistingMatchingCard(s.handspfilter, tp, LOCATION_HAND, 0, 1, nil, e, tp) then
                    -- Pergunta interativa ("you can")
                    if Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
                        Duel.BreakEffect()
                        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
                        local hg = Duel.SelectMatchingCard(tp, s.handspfilter, tp, LOCATION_HAND, 0, 1, 1, nil, e, tp)
                        if #hg > 0 then
                            Duel.SpecialSummon(hg, 0, tp, tp, false, false, POS_FACEUP)
                        end
                    end
                end
            end
        end
    end
end

-- ==========================================================
-- Efeito 2: Resgatar Equip Spell do Cemitério
-- ==========================================================
function s.thfilter(c)
    return c:IsType(TYPE_EQUIP) and c:IsSpell() and c:IsAbleToHand()
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.thfilter, tp, LOCATION_GRAVE, 0, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectTarget(tp, s.thfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, 0)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, tc)
    end
end