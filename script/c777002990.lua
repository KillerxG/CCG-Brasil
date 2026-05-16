-- Ereshkigal, Sovereign of the Underworld
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Habilita Invocação-Xyz (3 monstros Nível 10)
    c:EnableReviveLimit()
    Xyz.AddProcedure(c, nil, 10, 3)

    -- Efeito 1: Inafetada por efeitos de cartas do oponente enquanto possuir Matéria Xyz
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.immcon)
    e1:SetValue(s.efilter)
    c:RegisterEffect(e1)

    -- Efeito 2: Acoplamento e Banimento ao Invocarem ou Banirem do GY
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    -- Efeito não dá alvo (sem EFFECT_FLAG_CARD_TARGET), escolha feita na resolução
    e2:SetProperty(EFFECT_FLAG_DELAY) 
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, {id, 1})
    e2:SetCondition(s.attcon)
    e2:SetCost(s.attcost)
    e2:SetTarget(s.atttg)
    e2:SetOperation(s.attop)
    c:RegisterEffect(e2, false, REGISTER_FLAG_DETACH_XMAT)

    -- Clone do Efeito 2 para monitorar também a aba de Cartas Banidas (EVENT_REMOVE)
    local e3 = e2:Clone()
    e3:SetCode(EVENT_REMOVE)
    c:RegisterEffect(e3)

    -- Efeito 3: Invocação-Especial de uma matéria na End Phase
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PHASE | PHASE_END)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1, {id, 2})
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end

-- ==========================================================
-- Efeito 1: Imunidade (Condition e Filter)
-- ==========================================================
function s.immcon(e)
    return e:GetHandler():GetOverlayCount() > 0
end

function s.efilter(e, te)
    return te:GetOwnerPlayer() ~= e:GetHandlerPlayer()
end

-- ==========================================================
-- Efeito 2: Acoplar como Matéria (Sem alvo) e Banir do GY 
-- ==========================================================
function s.cfilter(c, e, tp)
    return c:IsPreviousLocation(LOCATION_GRAVE) and c:IsMonster()
        and c:IsLocation(LOCATION_MZONE | LOCATION_REMOVED)
        and not c:IsType(TYPE_TOKEN)
end

function s.attcon(e, tp, eg, ep, ev, re, r, rp)
    return not Duel.IsDamageStep() and eg:IsExists(s.cfilter, 1, nil, e, tp)
end

function s.attcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():CheckRemoveOverlayCard(tp, 1, REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp, 1, 1, REASON_COST)
end

function s.atttg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return eg:IsExists(s.cfilter, 1, nil, e, tp) end
    Duel.SetPossibleOperationInfo(0, CATEGORY_REMOVE, nil, 1, 1 - tp, LOCATION_GRAVE)
end

function s.attop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    
    -- Como não dá alvo, filtramos o grupo de evento e selecionamos na hora da resolução
    local g = eg:Filter(s.cfilter, nil, e, tp)
    if #g > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_XMATERIAL)
        local tc = g:Select(tp, 1, 1, nil):GetFirst()
        if tc and not tc:IsImmuneToEffect(e) then
            Duel.Overlay(c, tc)
            
            -- Confirma se a carta foi atrelada perfeitamente ("and if you do")
            if c:GetOverlayGroup():IsContains(tc) then
                local rg = Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, 0, LOCATION_GRAVE, nil)
                
                if #rg > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
                    Duel.BreakEffect()
                    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
                    local sg = rg:Select(tp, 1, 3, nil)
                    Duel.HintSelection(sg)
                    Duel.Remove(sg, POS_FACEUP, REASON_EFFECT)
                end
            end
        end
    end
end

-- ==========================================================
-- Efeito 3: Invocação-Especial da Matéria (End Phase)
-- ==========================================================
function s.spfilter(c, e, tp)
    -- As matérias retêm seu tipo original, logo IsMonster() funciona para checar se é invocável
    return c:IsMonster() and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:GetOverlayGroup():IsExists(s.spfilter, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_OVERLAY)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = c:GetOverlayGroup():FilterSelect(tp, s.spfilter, 1, 1, nil, e, tp)
    if #g > 0 then
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
    end
end