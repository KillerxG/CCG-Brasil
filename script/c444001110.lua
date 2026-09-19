local s, id = GetID()

function s.initial_effect(c)
    Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTuner(nil), 1, 99, nil, nil, function(g) return g:IsExists(Card.IsSetCard, 1, nil, 0x208e) end)
    c:EnableReviveLimit()

    -- 1. Válvula de Escape: Pagar 1000 LP na Standby Phase ou pular a MP1
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_PHASE + PHASE_STANDBY)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetOperation(s.skipop)
    c:RegisterEffect(e1)

    -- 2. Pagar 500 LP para declarar um ataque (Custo de Ataque)
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_ATTACK_COST)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetTargetRange(1, 1)
    e2:SetCost(s.atcost)
    e2:SetOperation(s.atop)
    c:RegisterEffect(e2)

    -- 3. Deve atacar se possível
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_MUST_ATTACK)
    c:RegisterEffect(e3)

    -- 4. Quando declarar ataque: Pagar 500 LP para virar Ataque Direto e reduzir ATK
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1)) -- Puxa a str2 do CDB ("Pay 500 LP to attack directly?")
    e4:SetCategory(CATEGORY_ATKCHANGE)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_ATTACK_ANNOUNCE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.dircon)
    e4:SetCost(s.dircost)
    e4:SetOperation(s.dirop)
    c:RegisterEffect(e4)
end

s.listed_series = {0x8e}

-- === Funções do Efeito 1 (Pular MP1) ===
function s.skipop(e, tp, eg, ep, ev, re, r, rp)
    local p = Duel.GetTurnPlayer()
    -- Puxa a str1 do CDB ("Pay 1000 LP to conduct Main Phase 1?")
    if Duel.CheckLPCost(p, 1000) and Duel.SelectYesNo(p, aux.Stringid(id, 0)) then 
        Duel.PayLPCost(p, 1000)
    else
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCode(EFFECT_SKIP_M1)
        e1:SetTargetRange(1, 0)
        if p ~= tp then e1:SetTargetRange(0, 1) end
        e1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(e1, tp)
    end
end

-- === Funções do Efeito 2 (Custo de Ataque Geral) ===
function s.atcost(e, c, tp)
    return Duel.CheckLPCost(tp, 500)
end
function s.atop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.IsAttackCostPaid() ~= 2 then
        Duel.PayLPCost(tp, 500)
        Duel.AttackCostPaid()
    end
end

-- === Funções do Efeito 4 (Mudar para Ataque Direto) ===
function s.dircon(e,tp,eg,ep,ev,re,r,rp)
    -- Só pergunta se o oponente tiver monstros (se não tiver, o ataque já é direto por padrão)
    return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
function s.dircost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,500) end
    Duel.PayLPCost(tp,500)
end
function s.dirop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        Duel.ChangeAttackTarget(nil) -- Muda o alvo para o jogador (Ataque Direto)
        
        -- Corta o ATK pela metade até o fim da Battle Phase
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(math.floor(c:GetAttack()/2))
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
        c:RegisterEffect(e1)
    end
end