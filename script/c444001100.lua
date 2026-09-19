-- The Sentinel of Vampire Castle
local s, id = GetID()

function s.initial_effect(c)
    -- 1. Efeito padrao da classe Illusion (Protecao mutua de batalha)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    e1:SetTarget(s.indtg)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- 2. Revelar da mao na declaracao de ataque do oponente -> Invocacao-Normal -> Mudar para Defesa
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SUMMON + CATEGORY_POSITION)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_ATTACK_ANNOUNCE)
    e2:SetRange(LOCATION_HAND)
    e2:SetCondition(s.sumcon)
    e2:SetCost(s.sumcost)
    e2:SetTarget(s.sumtg)
    e2:SetOperation(s.sumop)
    c:RegisterEffect(e2)

    -- 3. Oponente e obrigado a atacar esta carta, se possivel
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_MUST_ATTACK)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(0, LOCATION_MZONE)
    c:RegisterEffect(e3)

    local e3b = Effect.CreateEffect(c)
    e3b:SetType(EFFECT_TYPE_FIELD)
    e3b:SetCode(EFFECT_MUST_ATTACK_MONSTER)
    e3b:SetRange(LOCATION_MZONE)
    e3b:SetTargetRange(0, LOCATION_MZONE)
    e3b:SetValue(s.atklimit)
    c:RegisterEffect(e3b)

    -- 4. Aumento de ATK/DEF nos monstros Vampire quando atacado
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_BE_BATTLE_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.atkcon)
    e4:SetOperation(s.atkop)
    c:RegisterEffect(e4)

    -- 5. Banir do GY para reciclar Magia/Armadilha "Vampire" (GY ou Banimento -> Deck)
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 2))
    e5:SetCategory(CATEGORY_TODECK)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e5:SetRange(LOCATION_GRAVE)
    e5:SetCost(aux.bfgcost)
    e5:SetTarget(s.tdtg)
    e5:SetOperation(s.tdop)
    c:RegisterEffect(e5)
end

s.listed_series = {0x8e}

--------------------------------------------------------------------------------
-- Efeito 1: Illusion Protection
--------------------------------------------------------------------------------
function s.indtg(e, c)
    local handler = e:GetHandler()
    return c == handler or c == handler:GetBattleTarget()
end

--------------------------------------------------------------------------------
-- Efeito 2: Invocacao-Normal + Mudanca de Posicao
--------------------------------------------------------------------------------
function s.sumcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetAttacker():IsControler(1 - tp)
end

function s.sumcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return not c:IsPublic() end
    Duel.ConfirmCards(1 - tp, c)
    Duel.ShuffleHand(tp)
end

function s.sumtg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsSummonable(true, nil) end
    Duel.SetOperationInfo(0, CATEGORY_SUMMON, c, 1, 0, 0)
end

function s.sumop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsSummonable(true, nil) then
        -- Cria uma espera no jogo para mudar a posição assim que a invocação terminar
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_SUMMON_SUCCESS)
        e1:SetOperation(function(e_aux, tp_aux, eg_aux, ep_aux, ev_aux, re_aux, r_aux, rp_aux)
            if eg_aux:IsContains(c) then
                Duel.ChangePosition(c, POS_FACEUP_DEFENSE)
                e_aux:Reset() -- Apaga esse efeito auxiliar logo em seguida
            end
        end)
        Duel.RegisterEffect(e1, tp)
        
        -- Faz a Invocação
        Duel.Summon(tp, c, true, nil)
    end
end

--------------------------------------------------------------------------------
-- Efeito 3: Redirecionamento de Ataque
--------------------------------------------------------------------------------
function s.atklimit(e, c)
    return c == e:GetHandler()
end

--------------------------------------------------------------------------------
-- Efeito 4: Buff nos monstros Vampire
--------------------------------------------------------------------------------
function s.atkcon(e, tp, eg, ep, ev, re, r, rp)
    local at = Duel.GetAttackTarget()
    -- Confirma se o alvo do ataque é esta carta e se quem atacou foi o oponente
    return at and at == e:GetHandler() and Duel.GetAttacker():IsControler(1 - tp)
end

function s.vampfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x8e)
end

function s.atkop(e, tp, eg, ep, ev, re, r, rp)
    local attacker = Duel.GetAttacker()
    if not attacker or not attacker:IsRelateToBattle() then return end
    local val = math.floor(attacker:GetBaseAttack() / 2)
    if val <= 0 then return end

    local g = Duel.GetMatchingGroup(s.vampfilter, tp, LOCATION_MZONE, 0, nil)
    for tc in aux.Next(g) do
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(val)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(e1)
        local e2 = e1:Clone()
        e2:SetCode(EFFECT_UPDATE_DEFENSE)
        tc:RegisterEffect(e2)
    end
end

--------------------------------------------------------------------------------
-- Efeito 5: Embaralhar Magia/Armadilha no Deck
--------------------------------------------------------------------------------
function s.tdfilter(c)
    return c:IsSetCard(0x8e) and c:IsSpellTrap() and c:IsAbleToDeck() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end

function s.tdtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE + LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.tdfilter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectTarget(tp, aux.NecroValleyFilter(s.tdfilter), tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, 1, 0, 0)
end

function s.tdop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoDeck(tc, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
    end
end