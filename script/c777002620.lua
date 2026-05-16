--Northern Guild - David
--Scripted by KillerxG
local s, id = GetID()
function s.initial_effect(c)
    --Fusion Summon
    c:EnableReviveLimit()
    Fusion.AddProcMixN(c, true, true, aux.FilterBoolFunctionEx(Card.IsSetCard, 0x280), 2)
    --(1)Unaffected
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.immcon)
    e1:SetValue(s.immval)
    c:RegisterEffect(e1)
	--(2)Destroy
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DESTROY | CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0, TIMINGS_CHECK_MONSTER | TIMING_END_PHASE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
	--(3)Destroy replace
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EFFECT_DESTROY_REPLACE)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, id + 1)
    e3:SetTarget(s.reptg)
    e3:SetValue(s.repval)
    e3:SetOperation(s.repop)
    c:RegisterEffect(e3)
end
--(1)Unaffected
function s.immcon(e)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, 777002610), e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil)
end
function s.immval(e, te)
    local tc = te:GetHandler()
    return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer() ~= e:GetHandlerPlayer() 
        and tc:GetBaseAttack() < e:GetHandler():GetAttack()
end
--(2)Destroy
function s.descon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ph = Duel.GetCurrentPhase()
    return c:GetAttack() ~= c:GetBaseAttack() and ph ~= PHASE_DAMAGE and ph ~= PHASE_DAMAGE_CAL
end
function s.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(1 - tp) and chkc:IsOnField() end
    if chk == 0 then return Duel.IsExistingTarget(nil, tp, 0, LOCATION_ONFIELD, 1, nil) end    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, nil, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end
function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    local c = e:GetHandler()    
    if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc, REASON_EFFECT) > 0 then
        if c:IsRelateToEffect(e) and c:IsFaceup() then
            Duel.BreakEffect()
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SET_ATTACK_FINAL)
            e1:SetValue(c:GetBaseAttack())
            e1:SetReset(RESET_EVENT | RESETS_STANDARD_DISABLE)
            c:RegisterEffect(e1)
        end
    end
end
--(3)Destroy replace
function s.repfilter(c, tp)
    return c:IsFaceup() and c:IsControler(tp) and c:IsOnField() and c:IsSetCard(0x280)
        and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_BATTLE | REASON_EFFECT)
end
function s.reptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToRemove() and eg:IsExists(s.repfilter, 1, nil, tp) end
    if Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        return true
    else
        return false
    end
end
function s.repval(e, c)
    return s.repfilter(c, e:GetHandlerPlayer())
end
function s.repop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Remove(e:GetHandler(), POS_FACEUP, REASON_EFFECT | REASON_REPLACE)    
    local ph = Duel.GetCurrentPhase()
    if ph >= PHASE_BATTLE_START and ph <= PHASE_BATTLE then
        Duel.SkipPhase(Duel.GetTurnPlayer(), PHASE_BATTLE, RESET_PHASE | PHASE_BATTLE_STEP, 1)
    end
end