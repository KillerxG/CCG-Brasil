-- Shinigami of Oblivion - Giorgio
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Special Summon da mão (Tributando 1 DARK - Suporte Lair of Darkness)
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Efeito 2: Se Tributado -> SpSummon -> Mexer no Extra Deck (Colocar S/T no oponente)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_RELEASE)
    e2:SetCountLimit(1, id + 1)
    e2:SetTarget(s.reltg)
    e2:SetOperation(s.relop)
    c:RegisterEffect(e2)

    -- ====================================================================
    -- Mecânica Spirit Exata
    -- ====================================================================
    local sme,soe=Spirit.AddProcedure(c,EVENT_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS)
    --Mandatory return
    sme:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    sme:SetTarget(s.mrettg)
    sme:SetOperation(s.retop)
    --Optional return
    soe:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    soe:SetTarget(s.orettg)
    soe:SetOperation(s.retop)
end

-- ====================================================================
-- Efeito 1: Special Summon da mão (Suporte Lair of Darkness)
-- ====================================================================
function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.CheckReleaseGroupCost(tp, Card.IsAttribute, 1, true, nil, c, ATTRIBUTE_DARK) end
    local g = Duel.SelectReleaseGroupCost(tp, Card.IsAttribute, 1, 1, true, nil, c, ATTRIBUTE_DARK)
    Duel.Release(g, REASON_COST)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
    end
end

-- ====================================================================
-- Efeito 2: Retorno após Tributo + Transformar Extra Deck em Armadilha
-- ====================================================================
function s.reltg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.relop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        local exg = Duel.GetMatchingGroup(Card.IsFacedown, tp, 0, LOCATION_EXTRA, nil)
        
        -- Checa se o oponente tem Extra Deck e se tem espaço na S&T dele
        if #exg > 0 and Duel.GetLocationCount(1 - tp, LOCATION_SZONE) > 0 
            and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
            
            Duel.BreakEffect()
            
            -- Seleciona até 3 cartas aleatórias, ou menos se ele não tiver 3
            local count = math.min(3, #exg)
            local conf = exg:RandomSelect(tp, count)
            Duel.ConfirmCards(tp, conf)
            
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOFIELD)
            local sg = conf:Select(tp, 1, 1, nil)
            local tc = sg:GetFirst()
            
            if tc then
                -- Move para a zona do oponente face-up
                if Duel.MoveToField(tc, tp, 1 - tp, LOCATION_SZONE, POS_FACEUP, true) then
                    -- Altera o tipo nativo da carta para Armadilha Contínua
                    local e1 = Effect.CreateEffect(c)
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                    e1:SetCode(EFFECT_CHANGE_TYPE)
                    e1:SetValue(TYPE_TRAP + TYPE_CONTINUOUS)
                    e1:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TURN_SET)
                    tc:RegisterEffect(e1)
                end
            end
        end
    end
end

-- ====================================================================
-- Efeito 3: Spirit Procedure + Roubo de Extra Deck com Boss
-- ====================================================================
function s.mrettg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
end

function s.orettg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsAbleToHand() end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
end

function s.bossfilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777001120
end

function s.spfilter_extra(c, e, tp)
    -- Filtro para garantir que a carta escolhida pode ser invocada
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.retop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    
    if c:IsRelateToEffect(e) and Duel.SendtoHand(c, nil, REASON_EFFECT) > 0 and c:IsLocation(LOCATION_HAND) then
        
        local exg2 = Duel.GetMatchingGroup(Card.IsFacedown, tp, 0, LOCATION_EXTRA, nil)
        
        -- Bônus Boss: Olhar 2 aleatórias e roubar 1 pro seu campo
        if Duel.IsExistingMatchingCard(s.bossfilter, tp, LOCATION_MZONE, 0, 1, nil)
            and #exg2 > 0 and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
            
            Duel.BreakEffect()
            
            local count = math.min(2, #exg2)
            local conf = exg2:RandomSelect(tp, count)
            Duel.ConfirmCards(tp, conf)
            
            -- Filtra as aleatórias para ver quais realmente podem ser invocadas
            local sg2 = conf:FilterSelect(tp, s.spfilter_extra, 1, 1, nil, e, tp)
            local tc2 = sg2:GetFirst()
            
            if tc2 and Duel.SpecialSummonStep(tc2, 0, tp, tp, false, false, POS_FACEUP) then
                -- "...but its effects are negated"
                local e1 = Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_DISABLE)
                e1:SetReset(RESET_EVENT + RESETS_STANDARD)
                tc2:RegisterEffect(e1, true)
                local e2 = Effect.CreateEffect(c)
                e2:SetType(EFFECT_TYPE_SINGLE)
                e2:SetCode(EFFECT_DISABLE_EFFECT)
                e2:SetReset(RESET_EVENT + RESETS_STANDARD)
                tc2:RegisterEffect(e2, true)
                
                Duel.SpecialSummonComplete()
            end
        end
    end
end