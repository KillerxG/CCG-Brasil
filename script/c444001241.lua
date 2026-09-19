-- The True Vampire Castle (Action Duel Version)
local s, id = GetID()

function s.initial_effect(c)
    -- ==========================================================
    -- PARTE 1: EFEITOS BASE DO TRUE VAMPIRE CASTLE
    -- ==========================================================
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- Virar DARK Zombie
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

    -- Trava de Invocação para Donos da Empress/Princess
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

    -- Substituir Custo de LP
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EFFECT_LPCOST_REPLACE)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCondition(s.lrcon)
    e5:SetOperation(s.lrop)
    c:RegisterEffect(e5)

    -- Comprar 2 no próximo turno
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

    -- Debuff da Virada
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

    -- Busca na Draw Phase
    local e8 = Effect.CreateEffect(c)
    e8:SetDescription(aux.Stringid(id, 1))
    e8:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e8:SetCode(EVENT_PREDRAW)
    e8:SetRange(LOCATION_FZONE)
    e8:SetCondition(s.drawcon)
    e8:SetOperation(s.drawop)
    c:RegisterEffect(e8)

    -- ==========================================================
    -- PARTE 2: EFEITOS DE RPG / ACTION DUEL (DEBUG E UTILIDADES)
    -- ==========================================================
    -- Impedir ativação de outras Field Spells
    local e9 = Effect.CreateEffect(c)
    e9:SetType(EFFECT_TYPE_FIELD)
    e9:SetRange(LOCATION_FZONE)
    e9:SetCode(EFFECT_CANNOT_ACTIVATE)
    e9:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e9:SetTargetRange(1, 0)
    e9:SetValue(s.aclimit)
    c:RegisterEffect(e9)

    -- [RPG] Descartar 1 carta da própria mão
    local e10 = Effect.CreateEffect(c)
    e10:SetDescription(aux.Stringid(id, 3))
    e10:SetCategory(CATEGORY_TOGRAVE)
    e10:SetType(EFFECT_TYPE_IGNITION)
    e10:SetRange(LOCATION_FZONE)
    e10:SetTarget(s.tgtg)
    e10:SetOperation(s.tgop)
    c:RegisterEffect(e10)

    -- [RPG] Reduzir LP
    local e11 = Effect.CreateEffect(c)
    e11:SetDescription(aux.Stringid(id, 4))
    e11:SetType(EFFECT_TYPE_IGNITION)
    e11:SetRange(LOCATION_FZONE)
    e11:SetTarget(s.lptg)
    e11:SetOperation(s.lpop)
    c:RegisterEffect(e11)

    -- [RPG] Negar Ataque Direto
    local e12 = Effect.CreateEffect(c)
    e12:SetDescription(aux.Stringid(id, 7))
    e12:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_TRIGGER_O)
    e12:SetCode(EVENT_ATTACK_ANNOUNCE)
    e12:SetRange(LOCATION_FZONE)
    e12:SetCountLimit(1)
    e12:SetCondition(s.negcon)
    e12:SetOperation(s.negop)
    c:RegisterEffect(e12)

    -- [RPG] Call Vampire Empress
    local e13 = Effect.CreateEffect(c)
    e13:SetDescription(aux.Stringid(id, 8))
    e13:SetType(EFFECT_TYPE_IGNITION)
    e13:SetRange(LOCATION_FZONE)
    e13:SetCountLimit(1)
    e13:SetTarget(s.tktg)
    e13:SetOperation(s.tkop)
    c:RegisterEffect(e13)
end

s.listed_series = {0x8e}
s.listed_names = {444001010, 444001020}

-- ==========================================================
-- FUNÇÕES DO TRUE VAMPIRE CASTLE (Idênticas ao base)
-- ==========================================================
function s.owner_filter(c, sum_player)
    return (c:IsCode(444001010) or c:IsCode(444001020)) and c:GetOwner() == sum_player
end
function s.sumlimit(e, c, sump, sumtype, sumpos, targetp, se)
    local is_locked = Duel.IsExistingMatchingCard(s.owner_filter, sump, 0xff, 0xff, 1, nil, sump)
    if not is_locked then return false end
    return not c:IsSetCard(0x8e)
end

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
    if #g > 0 then Duel.SendtoGrave(g, REASON_COST) end
end

function s.tdfilter(c) return c:IsSetCard(0x8e) and c:IsFaceup() and c:IsAbleToGrave() end
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

function s.cfilter(c) return c:IsFaceup() and not c:IsSetCard(0x8e) end
function s.debuffcon(e, tp, eg, ep, ev, re, r, rp) return eg:IsExists(s.cfilter, 1, nil) end
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
    if total_lost > 0 then Duel.Recover(tp, total_lost, REASON_EFFECT) end
end

function s.drawcon(e, tp, eg, ep, ev, re, r, rp)
    return tp == Duel.GetTurnPlayer() and Duel.GetDrawCount(tp) > 0
end
function s.thfilter(c) return c:IsSetCard(0x8e) and c:IsAbleToHand() end
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
                if tc:IsType(TYPE_MONSTER) then cost = cost + math.ceil(math.max(0, tc:GetBaseAttack()) / 2)
                else cost = cost + 1000 end
            end
            if cost > 0 then Duel.PayLPCost(tp, cost) end
        end
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

-- ==========================================================
-- FUNÇÕES DE RPG / ACTION DUEL
-- ==========================================================
function s.aclimit(e, re, tp)
    return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsType(TYPE_FIELD)
end

function s.tgfilter(c) return c:IsAbleToGrave() end
function s.tgtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.tgfilter, tp, LOCATION_HAND, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_HAND)
end
function s.tgop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.tgfilter, tp, LOCATION_HAND, 0, 1, 1, nil)
    if #g > 0 then Duel.SendtoGrave(g, REASON_EFFECT) end
end

function s.lptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_NUMBER)
    local num = Duel.AnnounceNumber(tp, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200)
    Duel.SetTargetParam(num)
end
function s.lpop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end    
    local num = Duel.GetChainInfo(0, CHAININFO_TARGET_PARAM)    
    -- Seleciona entre si mesmo (String 5) ou Oponente (String 6)
    local op = Duel.SelectOption(tp, aux.Stringid(id, 5), aux.Stringid(id, 6))
    local target_player = (op == 0) and tp or (1 - tp)    
    local current_lp = Duel.GetLP(target_player)
    Duel.SetLP(target_player, math.max(0, current_lp - num))
end

function s.negcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetAttacker():IsControler(1 - tp) and Duel.GetAttackTarget() == nil
end
function s.negop(e, tp, eg, ep, ev, re, r, rp)
    Duel.NegateAttack()
end

function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, 0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
        -- 444001010 = ID da Vampire Empress
        local token = Duel.CreateToken(tp, 444001010) 
        Duel.SpecialSummon(token, 0, tp, tp, false, false, POS_FACEUP)
    end
end

-- ==========================================================
-- MARCADORES DO SISTEMA DE ACTION DUEL
-- ==========================================================
s.af = "a"
s.tableAction = {
    -- Ajuste essa lista depois com as Action Cards específicas deste Castelo!
    150000024, 150000033, 150000047, 150000042, 150000011, 
    150000044, 150000022, 150000020
}