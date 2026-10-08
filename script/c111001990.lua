-- RPG Hack Skill
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Habilita o suporte da Skill
    aux.AddSkillProcedure(c, 2, false, nil, nil)
    
    -- [Skill Activation] Virar a carta no início do Duelo
    local e0 = Effect.CreateEffect(c)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_STARTUP)
    e0:SetCountLimit(1)
    e0:SetRange(0x5f)
    e0:SetOperation(s.flipop)
    c:RegisterEffect(e0)
end

function s.flipop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SKILL_FLIP, tp, id | (1 << 32))
    Duel.Hint(HINT_CARD, tp, id)
    
    -- [MENU UNIFICADO] Apenas 1 botão que controla os 3 efeitos (Sem restrição de turnos)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(0x5f)
    e1:SetCondition(s.menu_con)
    e1:SetOperation(s.menu_op)
    Duel.RegisterEffect(e1, tp)
end

-- ====================================================================
-- Condições Individuais (SEM LIMITES)
-- ====================================================================
function s.eff1con(tp)
    return Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_DECK + LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil)
end

function s.eff2con(tp)
    return Duel.IsPlayerCanDraw(tp, 1)
end

function s.eff3con(tp)
    return Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0
end

-- ====================================================================
-- Lógica do Menu
-- ====================================================================
function s.menu_con(e, tp, eg, ep, ev, re, r, rp)
    if not aux.CanActivateSkill(tp) then return false end
    -- O botão só aparece se pelo menos 1 dos efeitos puder ser ativado
    return s.eff1con(tp) or s.eff2con(tp) or s.eff3con(tp)
end

function s.menu_op(e, tp, eg, ep, ev, re, r, rp)
    local b1 = s.eff1con(tp)
    local b2 = s.eff2con(tp)
    local b3 = s.eff3con(tp)
    
    local ops = {}
    local opval = {}
    
    -- Constrói o menu apenas com as opções disponíveis
    if b1 then
        table.insert(ops, aux.Stringid(id, 1)) -- String 1: Add/Swap
        table.insert(opval, 1)
    end
    if b2 then
        table.insert(ops, aux.Stringid(id, 2)) -- String 2: Draw 1
        table.insert(opval, 2)
    end
    if b3 then
        table.insert(ops, aux.Stringid(id, 3)) -- String 3: Look top
        table.insert(opval, 3)
    end
    
    if #ops == 0 then return end
    
    -- Abre a janela de seleção
    local sel = Duel.SelectOption(tp, table.unpack(ops)) + 1
    local choice = opval[sel]
    
    Duel.Hint(HINT_CARD, tp, id)
    
    -- Executa a escolha livremente
    if choice == 1 then
        s.eff1op(e, tp)
    elseif choice == 2 then
        s.eff2op(e, tp)
    elseif choice == 3 then
        s.eff3op(e, tp)
    end
end

-- ====================================================================
-- Operações Finais
-- ====================================================================
function s.eff1op(e, tp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, function(c) return not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup() end, tp, LOCATION_DECK + LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, 1, nil)
    
    if #g > 0 and Duel.SendtoHand(g, nil, REASON_EFFECT) > 0 then
        Duel.ConfirmCards(1 - tp, g)
        Duel.ShuffleHand(tp)
        
        Duel.BreakEffect()
        
        local hg = Duel.GetFieldGroup(tp, LOCATION_HAND, 0)
        if #hg > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 4)) then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
            local sg = Duel.SelectMatchingCard(tp, aux.TRUE, tp, LOCATION_HAND, 0, 1, 1, nil)
            if #sg > 0 then
                local op = Duel.SelectOption(tp, aux.Stringid(id, 5), aux.Stringid(id, 6), aux.Stringid(id, 7))
                if op == 0 then
                    Duel.SendtoDeck(sg, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
                elseif op == 1 then
                    Duel.SendtoGrave(sg, REASON_EFFECT)
                else
                    Duel.Remove(sg, POS_FACEUP, REASON_EFFECT)
                end
            end
        end
    end
end

function s.eff2op(e, tp)
    Duel.Draw(tp, 1, REASON_EFFECT)
end

function s.eff3op(e, tp)
    Duel.ConfirmDecktop(tp, 1)
end