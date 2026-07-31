-- Timerx Assistant
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Retornado ao déqui -> Special Summon
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EVENT_TO_DECK)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Efeito 2: Sp. Summon do déqui -> Declarar Tipo/Atributo -> Fusão (Super Poly)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_FUSION_SUMMON + CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.fuscon)
    e2:SetTarget(s.fustg)
    e2:SetOperation(s.fusop)
    c:RegisterEffect(e2)

    -- Efeito 3: No GY -> Colocar do Hand no fundo do déqui -> Comprar 1 -> Banir (ou manter c/ Chronos)
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_TODECK + CATEGORY_DRAW + CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, id + 2)
    e3:SetTarget(s.drtg)
    e3:SetOperation(s.drop)
    c:RegisterEffect(e3)
end

-- ====================================================================
-- Efeito 1: Retornado ao déqui -> Special Summon
-- ====================================================================
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
    end
end

-- ====================================================================
-- Efeito 2: Declarar Tipo/Atributo e Fusion Summon c/ campo oponente
-- ====================================================================
function s.fuscon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end

function s.fustg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsFaceup, tp, 0, LOCATION_MZONE, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RACE)
    local rc = Duel.AnnounceRace(tp, 1, RACE_ALL)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATTRIBUTE)
    local att = Duel.AnnounceAttribute(tp, 1, 0x7f)
    
    -- Salva o Tipo na Label principal do efeito
    e:SetLabel(rc)
    -- Salva o Atributo no parâmetro alvo da corrente (solução perfeita para números adicionais)
    Duel.SetTargetParam(att)
end

function s.fusfilter(c, e, tp, m)
    return c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_FUSION, tp, false, false)
        and c:CheckFusionMaterial(m, nil, tp)
end

function s.fusop(e, tp, eg, ep, ev, re, r, rp)
    local rc = e:GetLabel()
    local att = Duel.GetChainInfo(0, CHAININFO_TARGET_PARAM)
    
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil)
    local changed = false
    
    for tc in aux.Next(g) do
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_RACE)
        e1:SetValue(rc)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(e1)
        
        local e2 = e1:Clone()
        e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        e2:SetValue(att)
        tc:RegisterEffect(e2)
        changed = true
    end
    
    if changed then
        local mg = Duel.GetMatchingGroup(Card.IsCanBeFusionMaterial, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
        
        if Duel.IsExistingMatchingCard(s.fusfilter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, mg)
            and Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
            
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
            local sg = Duel.SelectMatchingCard(tp, s.fusfilter, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp, mg)
            local fc = sg:GetFirst()
            
            if fc then
                local mat = Duel.SelectFusionMaterial(tp, fc, mg, nil, tp)
                fc:SetMaterial(mat)
                Duel.SendtoGrave(mat, REASON_EFFECT + REASON_MATERIAL + REASON_FUSION)
                Duel.BreakEffect()
                Duel.SpecialSummon(fc, SUMMON_TYPE_FUSION, tp, tp, false, false, POS_FACEUP)
                fc:CompleteProcedure()
            end
        end
    end
end

-- ====================================================================
-- Efeito 3: Mandar do Hand pro fundo do déqui -> Comprar 1 -> Banir
-- ====================================================================
function s.handfilter(c)
    return c:IsSetCard(0x305) and c:IsAbleToDeck()
end

function s.drtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.handfilter, tp, LOCATION_HAND, 0, 1, nil)
        and Duel.IsPlayerCanDraw(tp, 1) end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_HAND)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.chronosfilter(c)
    return c:IsFaceup() and c:GetOriginalCodeRule() == 777000640
end

function s.drop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectMatchingCard(tp, s.handfilter, tp, LOCATION_HAND, 0, 1, 1, nil)
    
    if #g > 0 then
        Duel.ConfirmCards(1 - tp, g)
        -- SEQ_DECKBOTTOM manda cirurgicamente para o final do déqui
        if Duel.SendtoDeck(g, nil, SEQ_DECKBOTTOM, REASON_EFFECT) > 0 and g:GetFirst():IsLocation(LOCATION_DECK) then
            if Duel.Draw(tp, 1, REASON_EFFECT) > 0 then
                
                local c = e:GetHandler()
                -- "then banish this card from your GY unless you control Chronos"
                if c:IsRelateToEffect(e) and not Duel.IsExistingMatchingCard(s.chronosfilter, tp, LOCATION_MZONE, 0, 1, nil) then
                    Duel.Remove(c, POS_FACEUP, REASON_EFFECT)
                end
            end
        end
    end
end