-- Pyroland Swordmaiden
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Revelar para Invocar por Fusão do Extra Deck (Mão, Campo e Deck - máx 1 do Deck)
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON | CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCost(s.fuscost)
    e1:SetTarget(s.fustg)
    e1:SetOperation(s.fusop)
    c:RegisterEffect(e1)

    -- Efeito 2: Enviar "Pyroland" como custo; Special Summon do GY e (Opcional) Embaralhar 3 do GY no Deck
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON | CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    -- Efeito 3: (Efeito Rápido) Negar efeitos e retornar para a Mão
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_DISABLE | CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E | TIMING_MAIN_END)
    e3:SetCountLimit(1, {id, 3})
    e3:SetCondition(s.negcon)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)
end

s.listed_series = {0x278}

-- ==========================================================
-- Efeito 1: Invocação-Fusão (Mão, Campo e Deck limitados)
-- ==========================================================
function s.fuscost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return not c:IsPublic() end
    Duel.ConfirmCards(1 - tp, c)
end

function s.mfilter(c, e)
    return c:IsAbleToGrave() and (not e or not c:IsImmuneToEffect(e))
end

function s.fcheck(tp, sg, fc)
    -- Impede a matriz de Fusão de selecionar mais do que 1 carta que tenha LOCATION_DECK como origem
    return sg:FilterCount(Card.IsLocation, nil, LOCATION_DECK) <= 1
end

function s.spfilter(c, e, tp, m, f, gc, chkf)
    return c:IsType(TYPE_FUSION) and c:IsSetCard(0x278) and (not f or f(c))
        and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_FUSION, tp, false, false)
        and c:CheckFusionMaterial(m, gc, chkf)
end

function s.fustg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        local chkf = tp
        local mg1 = Duel.GetFusionMaterial(tp):Filter(s.mfilter, nil, e)
        local mg2 = Duel.GetMatchingGroup(s.mfilter, tp, LOCATION_DECK, 0, nil, e)
        mg1:Merge(mg2)
        
        -- Liga a checagem que limita a 1 carta do deck temporariamente na Engine
        Fusion.CheckAdditional = s.fcheck
        local res = Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, mg1, nil, c, chkf)
        if not res then
            local ce = Duel.GetChainMaterial(tp)
            if ce ~= nil then
                local fgroup = ce:GetTarget()
                local mg3 = fgroup(ce, e, tp)
                local mf = ce:GetValue()
                res = Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, mg3, mf, c, chkf)
            end
        end
        Fusion.CheckAdditional = nil
        return res
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.fusop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local chkf = tp
    if not c:IsRelateToEffect(e) then return end
    
    local mg1 = Duel.GetFusionMaterial(tp):Filter(s.mfilter, nil, e)
    local mg2 = Duel.GetMatchingGroup(s.mfilter, tp, LOCATION_DECK, 0, nil, e)
    mg1:Merge(mg2)
    
    -- Mantém a flag Fusion.CheckAdditional ativa durante TODA a resolução para blindar a escolha do jogador
    Fusion.CheckAdditional = s.fcheck
    
    local sg1 = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_EXTRA, 0, nil, e, tp, mg1, nil, c, chkf)
    local mg3 = nil
    local sg2 = nil
    local ce = Duel.GetChainMaterial(tp)
    if ce ~= nil then
        local fgroup = ce:GetTarget()
        mg3 = fgroup(ce, e, tp)
        local mf = ce:GetValue()
        sg2 = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_EXTRA, 0, nil, e, tp, mg3, mf, c, chkf)
    end
    
    if #sg1 > 0 or (sg2 ~= nil and #sg2 > 0) then
        local sg = sg1:Clone()
        if sg2 then sg:Merge(sg2) end
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local tg = sg:Select(tp, 1, 1, nil)
        local tc = tg:GetFirst()
        if sg1:IsContains(tc) and (sg2 == nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp, ce:GetDescription())) then
            local mat1 = Duel.SelectFusionMaterial(tp, tc, mg1, c, chkf)
            tc:SetMaterial(mat1)
            Duel.SendtoGrave(mat1, REASON_EFFECT | REASON_MATERIAL | REASON_FUSION)
            Duel.BreakEffect()
            Duel.SpecialSummon(tc, SUMMON_TYPE_FUSION, tp, tp, false, false, POS_FACEUP)
        else
            local mat2 = Duel.SelectFusionMaterial(tp, tc, mg3, c, chkf)
            local fop = ce:GetOperation()
            fop(ce, e, tp, tc, mat2)
        end
        tc:CompleteProcedure()
    end
    -- Desliga a variável global apenas após a conclusão absoluta das escolhas
    Fusion.CheckAdditional = nil
end

-- ==========================================================
-- Efeito 2: Custo e Special Summon do GY
-- ==========================================================
function s.spcostfilter(c, ft, tp)
    return c:IsSetCard(0x278) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost()
        and (ft > 0 or (c:IsLocation(LOCATION_MZONE) and c:GetControler() == tp and c:GetSequence() < 5))
end

function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.spcostfilter, tp, LOCATION_HAND | LOCATION_ONFIELD, 0, 1, e:GetHandler(), ft, tp) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.spcostfilter, tp, LOCATION_HAND | LOCATION_ONFIELD, 0, 1, 1, e:GetHandler(), ft, tp)
    Duel.SendtoGrave(g, REASON_COST)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
    Duel.SetPossibleOperationInfo(0, CATEGORY_TODECK, nil, 1, PLAYER_ALL, LOCATION_GRAVE)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        -- Verifica se tem cartas nos cemitérios para a etapa opcional de embaralhar (Shuffle)
        local g = Duel.GetMatchingGroup(Card.IsAbleToDeck, tp, LOCATION_GRAVE, LOCATION_GRAVE, nil)
        if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
            -- Permite que o jogador escolha até 3 cartas de qualquer um dos cemitérios
            local sg = g:Select(tp, 1, 3, nil)
            Duel.SendtoDeck(sg, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
        end
    end
end

-- ==========================================================
-- Efeito 3: Negar e Retornar para a Mão (Bounce)
-- ==========================================================
function s.cwfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x278)
end

function s.negcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.cwfilter, tp, LOCATION_ONFIELD, 0, 1, e:GetHandler())
end

function s.negtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(1 - tp) and chkc:IsOnField() and chkc:IsFaceup() end
    if chk == 0 then return Duel.IsExistingTarget(Card.IsFaceup, tp, 0, LOCATION_ONFIELD, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_NEGATE)
    local g = Duel.SelectTarget(tp, Card.IsFaceup, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_DISABLE, g, 1, 0, 0)
    Duel.SetPossibleOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, tp, LOCATION_MZONE)
end

function s.negop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    
    if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsDisabled() then
        Duel.NegateRelatedChain(tc, RESET_TURN_SET)
        
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT | RESETS_STANDARD | RESET_PHASE | PHASE_END)
        tc:RegisterEffect(e1)
        
        local e2 = Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e2:SetValue(RESET_TURN_SET)
        e2:SetReset(RESET_EVENT | RESETS_STANDARD | RESET_PHASE | PHASE_END)
        tc:RegisterEffect(e2)
        
        if tc:IsType(TYPE_TRAPMONSTER) then
            local e3 = Effect.CreateEffect(c)
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
            e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e3:SetReset(RESET_EVENT | RESETS_STANDARD | RESET_PHASE | PHASE_END)
            tc:RegisterEffect(e3)
        end
        
        if c:IsRelateToEffect(e) and Duel.SelectYesNo(tp, aux.Stringid(id, 4)) then
            Duel.BreakEffect()
            Duel.SendtoHand(c, nil, REASON_EFFECT)
        end
    end
end