-- Thunder Force Confront
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Ativação da Carta -> Busca (Cara = Até 2, Coroa = 1 Monstro)
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_COIN)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH) -- HOPT da ativação da carta
    e1:SetTarget(s.acttg)
    e1:SetOperation(s.actop)
    c:RegisterEffect(e1)

    -- Efeito 2: Oponente invoca Xyz/Link (Sem Nível) e você tem Zeus -> Moeda para Negar
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DISABLE + CATEGORY_COIN)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1, 0, EFFECT_COUNT_CODE_CHAIN) -- "Once per chain"
    e2:SetCondition(s.negcon)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)

    -- Efeito 3: Monstro do Oponente ataca -> Moeda para ATK 0
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_COIN)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_ATTACK_ANNOUNCE)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.atkcon)
    e3:SetTarget(s.atktg)
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)
end

-- Mostra ícone de moeda nativo
s.toss_coin = true

-- ====================================================================
-- Efeito 1: Ativação e Moeda (Busca)
-- ====================================================================
function s.thfilter_wrong(c)
    -- Se errar a moeda: Adiciona 1 monstro Thunder Force
    return c:IsSetCard(0x301) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.thfilter_right(c)
    -- Se acertar a moeda: Adiciona até 2 cartas Thunder Force (exceto ela mesma)
    return c:IsSetCard(0x301) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.acttg(e, tp, eg, ep, ev, re, r, rp, chk)
    -- A ativação da magia contínua sempre é legal, mas perguntamos se quer usar o efeito
    if chk == 0 then return true end
    
    -- O efeito só é perguntado se houver pelo menos 1 monstro no deck (para resolver caso erre a moeda)
    if Duel.IsExistingMatchingCard(s.thfilter_wrong, tp, LOCATION_DECK, 0, 1, nil) 
        and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        e:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_COIN)
        Duel.SetOperationInfo(0, CATEGORY_COIN, nil, 0, tp, 1)
        e:SetLabel(1) -- Marca que o efeito será usado na resolução
    else
        e:SetCategory(0)
        e:SetLabel(0)
    end
end

function s.actop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    
    -- Se ele não aceitou jogar a moeda no Target, o efeito acaba aqui
    if e:GetLabel() ~= 1 then return end
    
    local call = Duel.AnnounceCoin(tp)
    local res = Duel.TossCoin(tp, 1)
    
    if call == res then
        -- Acertou (Right)
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local g = Duel.SelectMatchingCard(tp, s.thfilter_right, tp, LOCATION_DECK, 0, 1, 2, nil)
        if #g > 0 then
            Duel.SendtoHand(g, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, g)
        end
    else
        -- Errou (Wrong)
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local g = Duel.SelectMatchingCard(tp, s.thfilter_wrong, tp, LOCATION_DECK, 0, 1, 1, nil)
        if #g > 0 then
            Duel.SendtoHand(g, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, g)
        end
    end
end

-- ====================================================================
-- Efeito 2: Oponente Invocou sem Nível (Xyz/Link) -> Negar
-- ====================================================================
function s.bossfilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777001370
end

function s.nolevel_filter(c, tp)
    -- Filtra apenas monstros do oponente que sejam Xyz ou Link (Sem Nível)
    return c:IsControler(1 - tp) and (c:IsType(TYPE_XYZ) or c:IsType(TYPE_LINK))
end

function s.negcon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.nolevel_filter, 1, nil, tp) 
        and Duel.IsExistingMatchingCard(s.bossfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.negtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    local g = eg:Filter(s.nolevel_filter, nil, tp)
    Duel.SetTargetCard(g)
    Duel.SetOperationInfo(0, CATEGORY_COIN, nil, 0, tp, 1)
    Duel.SetOperationInfo(0, CATEGORY_DISABLE, g, #g, 0, 0)
end

function s.negop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    
    local call = Duel.AnnounceCoin(tp)
    local res = Duel.TossCoin(tp, 1)
    
    if call == res then
        local g = Duel.GetTargetCards(e):Filter(s.nolevel_filter, nil, tp)
        for tc in aux.Next(g) do
            if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsDisabled() then
                -- Anula os efeitos do monstro
                Duel.NegateRelatedChain(tc, RESET_TURN_SET)
                local e1 = Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_DISABLE)
                e1:SetReset(RESET_EVENT + RESETS_STANDARD)
                tc:RegisterEffect(e1)
                
                local e2 = Effect.CreateEffect(c)
                e2:SetType(EFFECT_TYPE_SINGLE)
                e2:SetCode(EFFECT_DISABLE_EFFECT)
                e2:SetValue(RESET_TURN_SET)
                e2:SetReset(RESET_EVENT + RESETS_STANDARD)
                tc:RegisterEffect(e2)
            end
        end
    end
end

-- ====================================================================
-- Efeito 3: Oponente Declara Ataque -> ATK para 0
-- ====================================================================
function s.atkcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetAttacker():IsControler(1 - tp)
end

function s.atktg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetTargetCard(Duel.GetAttacker())
    Duel.SetOperationInfo(0, CATEGORY_COIN, nil, 0, tp, 1)
end

function s.atkop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    
    local call = Duel.AnnounceCoin(tp)
    local res = Duel.TossCoin(tp, 1)
    
    if call == res then
        local tc = Duel.GetFirstTarget()
        if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
            -- Muda o ATK para 0
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SET_ATTACK_FINAL)
            e1:SetValue(0)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
            tc:RegisterEffect(e1)
        end
    end
end