-- Thunder Force Potions
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito Único de Ativação com Menu de Escolhas
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- Identificador nativo para mostrar o ícone de moeda
s.toss_coin = true

-- ====================================================================
-- Filtros das 3 Opções e do Boss
-- ====================================================================
function s.spfilter(c, e, tp)
    return c:IsSetCard(0x301) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.lvfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x301) and c:HasLevel() and c:GetLevel() < 10
end

function s.atkfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x301) and c:HasLevel()
end

function s.bossfilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777001370
end

-- ====================================================================
-- Target (Construção do Menu e Validação de Flags)
-- ====================================================================
function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    -- Verifica quais efeitos são possíveis E ainda não foram usados neste turno
    local b1 = Duel.GetFlagEffect(tp, id) == 0 and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 
        and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp)
        
    local b2 = Duel.GetFlagEffect(tp, id + 1) == 0 
        and Duel.IsExistingMatchingCard(s.lvfilter, tp, LOCATION_MZONE, 0, 1, nil)
        
    local b3 = Duel.GetFlagEffect(tp, id + 2) == 0 
        and Duel.IsExistingMatchingCard(s.atkfilter, tp, LOCATION_MZONE, 0, 1, nil)
        
    if chk == 0 then return b1 or b2 or b3 end
    
    local ops = {}
    local opval = {}
    
    if b1 then
        table.insert(ops, aux.Stringid(id, 0))
        table.insert(opval, 1)
    end
    if b2 then
        table.insert(ops, aux.Stringid(id, 1))
        table.insert(opval, 2)
    end
    if b3 then
        table.insert(ops, aux.Stringid(id, 2))
        table.insert(opval, 3)
    end
    
    -- O jogador escolhe a opção disponível
    local op = Duel.SelectOption(tp, table.unpack(ops))
    local sel = opval[op + 1]
    e:SetLabel(sel)
    
    -- Registra que essa opção foi usada no turno (id, id+1 ou id+2)
    Duel.RegisterFlagEffect(tp, id + (sel - 1), RESET_PHASE + PHASE_END, 0, 1)
    
    -- Define as Categorias corretas para o motor do jogo baseado na escolha
    if sel == 1 then
        e:SetCategory(CATEGORY_SPECIAL_SUMMON)
        Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE)
    elseif sel == 2 then
        e:SetCategory(CATEGORY_COIN)
        Duel.SetOperationInfo(0, CATEGORY_COIN, nil, 0, tp, 1)
    elseif sel == 3 then
        e:SetCategory(CATEGORY_ATKCHANGE)
    end
end

-- ====================================================================
-- Operation (Resolução da Opção Escolhida + Efeito do Zeus)
-- ====================================================================
function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local sel = e:GetLabel()
    
    -- Executa a Opção 1
    if sel == 1 then
        if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
            local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
            if #g > 0 then
                Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
            end
        end
        
    -- Executa a Opção 2
    elseif sel == 2 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
        local g = Duel.SelectMatchingCard(tp, s.lvfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
        local tc = g:GetFirst()
        if tc then
            local call = Duel.AnnounceCoin(tp)
            local res = Duel.TossCoin(tp, 1)
            
            local inc = (call == res) and 2 or 1
            local max_inc = math.min(inc, 10 - tc:GetLevel())
            
            if max_inc > 0 then
                local e1 = Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_LEVEL)
                e1:SetValue(max_inc)
                e1:SetReset(RESET_EVENT + RESETS_STANDARD)
                tc:RegisterEffect(e1)
            end
        end
        
    -- Executa a Opção 3
    elseif sel == 3 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
        local g = Duel.SelectMatchingCard(tp, s.atkfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
        local tc = g:GetFirst()
        if tc then
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(tc:GetLevel() * 200)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
            tc:RegisterEffect(e1)
        end
    end
    
    -- Resolução final (Comum para as 3 opções): Bônus do Zeus
    if c:IsRelateToEffect(e) and c:IsCanTurnSet() 
        and Duel.IsExistingMatchingCard(s.bossfilter, tp, LOCATION_MZONE, 0, 1, nil) 
        and Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
        
        Duel.BreakEffect()
        c:CancelToGrave() -- Cancela o envio da carta pro cemitério
        Duel.ChangePosition(c, POS_FACEDOWN)
        Duel.RaiseEvent(c, EVENT_SSET, e, REASON_EFFECT, tp, tp, 0)
    end
end