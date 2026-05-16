--Everlasting Soul, Majin Yuna
--Scripted by KillerxG
local s, id = GetID()
function s.initial_effect(c)
	--Synchro Summon
    c:EnableReviveLimit()    
    Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x258),1,1,Synchro.NonTuner(nil),1,99)
    c:SetUniqueOnField(1,0,id)
    --(1)Chain Attack
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_DAMAGE_STEP_END)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCondition(s.atkcon)
    e1:SetTarget(s.atktg)
    e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)
    --(2)Destroy 1 card
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
    --(3)Destroy all S/T on the field
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetCondition(s.tdescon)
    e3:SetTarget(s.tdestg)
    e3:SetOperation(s.tdesop)
    c:RegisterEffect(e3)
end
--(1)Chain Attack
function s.atkcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and Duel.GetAttacker() == c
end

function s.trapfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and not c:IsDisabled()
end
function s.atktg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.trapfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.trapfilter, tp, LOCATION_SZONE, 0, 1, nil) end    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_NEGATE)
    Duel.SelectTarget(tp, s.trapfilter, tp, LOCATION_SZONE, 0, 1, 1, nil)
end
function s.atkop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()    
    if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsDisabled() then
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT | RESETS_STANDARD | RESET_PHASE | PHASE_END, 2)
        tc:RegisterEffect(e1)        
        local e2 = Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetValue(RESET_TURN_SET)
        e2:SetReset(RESET_EVENT | RESETS_STANDARD | RESET_PHASE | PHASE_END, 2)
        tc:RegisterEffect(e2)
        if tc:IsType(TYPE_TRAPMONSTER) then
            local e3 = Effect.CreateEffect(c)
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
            e3:SetReset(RESET_EVENT | RESETS_STANDARD | RESET_PHASE | PHASE_END, 2)
            tc:RegisterEffect(e3)
        end
        if not tc:IsImmuneToEffect(e1) and not tc:IsImmuneToEffect(e2) then
            if c:IsRelateToEffect(e) and c:IsFaceup() then
                Duel.ChainAttack()
            end
        end
    end
end
--(2)Destroy 1 card
function s.descon(e, tp, eg, ep, ev, re, r, rp)
    local ph = Duel.GetCurrentPhase()
    return ph == PHASE_MAIN1 or ph == PHASE_MAIN2
end
function s.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chkc then return chkc:IsOnField() and chkc ~= c end
    if chk == 0 then return Duel.IsExistingTarget(nil, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, c) end    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, nil, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, c)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end
function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc, REASON_EFFECT)
    end
end
--(3)Destroy all S/T on the field
function s.tdescon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsReason(REASON_BATTLE | REASON_EFFECT)
end
function s.tdestg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    local g = Duel.GetMatchingGroup(Card.IsType, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, nil, TYPE_SPELL | TYPE_TRAP)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end
function s.tdesop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(Card.IsType, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, nil, TYPE_SPELL | TYPE_TRAP)
    if #g > 0 then
        Duel.Destroy(g, REASON_EFFECT)
    end
end