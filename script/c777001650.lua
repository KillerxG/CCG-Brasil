-- Shinigami of Depletion - Carmilla
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

    -- Efeito 2: Se Tributada -> Special Summon -> -2000 ATK e Negar
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_ATKCHANGE + CATEGORY_DISABLE)
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
-- Efeito 1: Special Summon da mão (Suporte à Lair of Darkness)
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
-- Efeito 2: Retorno após Tributo + Redução de ATK + Negação
-- ====================================================================
function s.reltg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.relop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    -- Invoca a Carmilla
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        
        -- Confere se o oponente tem monstros virados para cima e pergunta se quer aplicar o debuff
        local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil)
        if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
            Duel.BreakEffect()
            local ng = Group.CreateGroup() -- Grupo para armazenar quem vai ser negado
            
            -- Aplica a perda de ATK em área
            for tc in aux.Next(g) do
                local pre_atk = tc:GetAttack()
                
                local e1 = Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_ATTACK)
                e1:SetValue(-2000)
                e1:SetReset(RESET_EVENT + RESETS_STANDARD)
                tc:RegisterEffect(e1)
                
                -- Se o ATK não era zero, e agora se tornou zero como resultado...
                if pre_atk > 0 and tc:GetAttack() == 0 then
                    ng:AddCard(tc)
                end
            end
            
            -- Anula os efeitos dos monstros que zeraram o ataque
            if #ng > 0 then
                for nc in aux.Next(ng) do
                    Duel.NegateRelatedChain(nc, RESET_TURN_SET)
                    local e2 = Effect.CreateEffect(c)
                    e2:SetType(EFFECT_TYPE_SINGLE)
                    e2:SetCode(EFFECT_DISABLE)
                    e2:SetReset(RESET_EVENT + RESETS_STANDARD)
                    nc:RegisterEffect(e2)
                    local e3 = Effect.CreateEffect(c)
                    e3:SetType(EFFECT_TYPE_SINGLE)
                    e3:SetCode(EFFECT_DISABLE_EFFECT)
                    e3:SetValue(RESET_TURN_SET)
                    e3:SetReset(RESET_EVENT + RESETS_STANDARD)
                    nc:RegisterEffect(e3)
                end
            end
        end
    end
end

-- ====================================================================
-- Efeito 3: Spirit Procedure (Alvos e Operação)
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

function s.gyfilter(c)
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.retop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    
    if c:IsRelateToEffect(e) and Duel.SendtoHand(c, nil, REASON_EFFECT) > 0 and c:IsLocation(LOCATION_HAND) then
        
        -- Bônus do Boss: Pegar 1 DARK de QUALQUER Cemitério
        if Duel.IsExistingMatchingCard(s.bossfilter, tp, LOCATION_MZONE, 0, 1, nil)
            and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.gyfilter), tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, nil)
            and Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
            
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
            
            -- Busca no cemitério de ambos os jogadores simultaneamente
            local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.gyfilter), tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, 1, nil)
            
            if #g > 0 then
                Duel.SendtoHand(g, tp, REASON_EFFECT)
                Duel.ConfirmCards(1 - tp, g)
            end
        end
    end
end