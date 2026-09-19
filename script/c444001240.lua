-- The True Vampire Castle
local s, id = GetID()

function s.initial_effect(c)
    -- Ativação
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- 1. Virar DARK Zombie
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE + LOCATION_GRAVE, LOCATION_MZONE + LOCATION_GRAVE)
    e2:SetCode(EFFECT_CHANGE_RACE)
    e2:SetValue(RACE_ZOMBIE)
    c:RegisterEffect(e2)
    local e3 = e2:Clone()
    e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e3:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(e3)

    -- 2. Trava de Invocação para quem é Dono da Empress/Princess
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetTargetRange(1, 1)
    e4:SetTarget(s.sumlimit)
    c:RegisterEffect(e4)
    local e4a = e4:Clone()
    e4a:SetCode(EFFECT_CANNOT_SUMMON)
    c:RegisterEffect(e4a)
    local e4b = e4:Clone()
    e4b:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
    c:RegisterEffect(e4b)

    -- 3. Substituir custo de LP por envio do Deck para o GY
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EFFECT_LPCOST_REPLACE)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCondition(s.lrcon)
    e5:SetOperation(s.lrop)
    c:RegisterEffect(e5)

    -- 4. Retornar banido pro GY para Comprar 2 no próximo turno
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 2))
    e6:SetCategory(CATEGORY_TOGRAVE)
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetRange(LOCATION_FZONE)
    e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e6:SetCountLimit(1)
    e6:SetTarget(s.draw2tg)
    e6:SetOperation(s.draw2op)
    c:RegisterEffect(e6)

    -- 5. Debuff: Oponente Invoca Especial um não-Vampire
    local e7 = Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id, 0)) 
    e7:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE + CATEGORY_RECOVER)
    e7:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F) 
    e7:SetCode(EVENT_SPSUMMON_SUCCESS)
    e7:SetRange(LOCATION_FZONE)
    e7:SetCondition(s.debuffcon)
    e7:SetTarget(s.debufftg)
    e7:SetOperation(s.debuffop)
    c:RegisterEffect(e7)

    -- 6. Fase de Compra: Buscar em vez de comprar
    local e8 = Effect.CreateEffect(c)
    e8:SetDescription(aux.Stringid(id, 1)) 
    e8:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e8:SetCode(EVENT_PREDRAW)
    e8:SetRange(LOCATION_FZONE)
    e8:SetCondition(s.drawcon)
    e8:SetOperation(s.drawop)
    c:RegisterEffect(e8)
end

s.listed_series = {0x8e}
s.listed_names = {444001010, 444001020}

-- [Funções da Trava de Invocação]
function s.owner_filter(c, sum_player)
    return (c:IsCode(444001010) or c:IsCode(444001020)) and c:GetOwner() == sum_player
end
function s.sumlimit(e, c, sump, sumtype, sumpos, targetp, se)
    local is_locked = Duel.IsExistingMatchingCard(s.owner_filter, sump, 0xff, 0xff, 1, nil, sump)
    if not is_locked then return false end
    return not c:IsSetCard(0x8e)
end

-- [Funções de Substituição de Custo de LP]
function s.lrfilter(c)
    return c:IsSetCard(0x8e) and c:IsAbleToGraveAsCost()
end
function s.lrcon(e, tp, eg, ep, ev, re, r, rp)
    if tp ~= ep or not re then return false end
    local rc = re:GetHandler()
    if not rc:IsSetCard(0x8e) then return false end
    local is_draw_effect = (re:GetCode() == EVENT_PREDRAW and rc:IsCode(id))
    if re:IsActivated() or is_draw_effect then
        return Duel.IsExistingMatchingCard(s.lrfilter, tp, LOCATION_DECK, 0, 1, nil)
    end
    return false
end
function s.lrop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.lrfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoGrave(g, REASON_COST)
    end
end

-- [Funções do Comprar 2 (Reciclar)]
function s.tdfilter(c)
    return c:IsSetCard(0x8e) and c:IsFaceup() and c:IsAbleToGrave()
end
function s.draw2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.tdfilter, tp, LOCATION_REMOVED, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectTarget(tp, s.tdfilter, tp, LOCATION_REMOVED, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g, 1, 0, 0)
end
function s.draw2op(e, tp, eg, ep, ev, re, r, rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc, REASON_EFFECT + REASON_RETURN) > 0 then
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_DRAW_COUNT)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1, 0)
        e1:SetValue(2)
        e1:SetReset(RESET_PHASE + PHASE_DRAW + RESET_SELF_TURN, 1)
        Duel.RegisterEffect(e1, tp)
    end
end

-- [Funções do Debuff / Cura]
function s.cfilter(c)
    return c:IsFaceup() and not c:IsSetCard(0x8e)
end
function s.debuffcon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.cfilter, 1, nil)
end
function s.debufftg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetTargetCard(eg:Filter(s.cfilter, nil))
end
function s.debuffop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetTargetCards(e)
    local total_lost = 0
    for tc in aux.Next(g) do
        if tc:IsFaceup() then
            local pre_atk = math.max(0, tc:GetBaseAttack())
            local pre_def = math.max(0, tc:GetBaseDefense())
            local new_atk = math.ceil(pre_atk / 2)
            local new_def = math.ceil(pre_def / 2)
            
            local e1 = Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SET_BASE_ATTACK)
            e1:SetValue(new_atk)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(e1)
            local e2 = e1:Clone()
            e2:SetCode(EFFECT_SET_BASE_DEFENSE)
            e2:SetValue(new_def)
            tc:RegisterEffect(e2)
            
            total_lost = total_lost + (pre_atk - new_atk)
        end
    end
    if total_lost > 0 then
        Duel.Recover(tp, total_lost, REASON_EFFECT)
    end
end

-- [Funções da Draw Phase (Buscar no lugar de comprar)]
function s.drawcon(e, tp, eg, ep, ev, re, r, rp)
    return tp == Duel.GetTurnPlayer() and Duel.GetDrawCount(tp) > 0
end
function s.thfilter(c)
    return c:IsSetCard(0x8e) and c:IsAbleToHand()
end
function s.drawop(e, tp, eg, ep, ev, re, r, rp)
    local ct = Duel.GetDrawCount(tp)
    if ct == 0 then return end
    if not Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil) then return end
    
    if Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then 
        local g = Duel.GetMatchingGroup(s.thfilter, tp, LOCATION_DECK, 0, nil)
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local sg = g:Select(tp, 1, ct, nil)
        
        if sg and #sg > 0 then
            Duel.SendtoHand(sg, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, sg)
            
            local cost = 0
            for tc in aux.Next(sg) do
                if tc:IsType(TYPE_MONSTER) then
                    local atk = math.max(0, tc:GetBaseAttack())
                    cost = cost + math.ceil(atk / 2)
                else
                    cost = cost + 1000
                end
            end
            
            if cost > 0 then
                Duel.PayLPCost(tp, cost)
            end
        end
        
        -- Zera as compras normais e anula as restantes (Corrige o SetDrawCount)
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCode(EFFECT_DRAW_COUNT)
        e1:SetTargetRange(1, 0)
        e1:SetReset(RESET_PHASE + PHASE_DRAW)
        e1:SetValue(0)
        Duel.RegisterEffect(e1, tp)
    end
end