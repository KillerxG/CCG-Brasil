--West Royal Dragon - Adventurer Irya
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --Synchro Summon
    c:EnableReviveLimit()
    Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_TUNER),1,1,aux.FilterSummonCode(777003710),1,1)
    --(1)Change Name
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
    e1:SetValue(777003710)
    c:RegisterEffect(e1)
    --(2)Gain ATK
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.atkcon)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)
	--(3)Negate
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.negcon)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)
end
s.listed_names={777003720,id}
--(2)Gain ATK
function s.get_col(c)
    local seq = c:GetSequence()
    local p = c:GetControler()
    if seq < 5 then
        return p == 0 and seq or (4 - seq)
    elseif seq == 5 then
        return p == 0 and 1 or 3
    elseif seq == 6 then
        return p == 0 and 3 or 1
    else
        return -1
    end
end
function s.atkfilter(tc, c, tp)
    if tc:GetSummonPlayer() ~= 1 - tp then return false end    
    local col1 = s.get_col(tc)
    local col2 = s.get_col(c)
    return col1 ~= -1 and col2 ~= -1 and col1 ~= col2
end
function s.atkcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return eg:IsExists(s.atkfilter, 1, nil, c, tp)
end
function s.atkop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFaceup() then
        Duel.Hint(HINT_CARD, 0, id)
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(500)
        e1:SetReset(RESET_EVENT | RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e1)
    end
end
--(3)Negate
function s.negcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return ep ~= tp and Duel.IsChainNegatable(ev) 
        and c:GetAttack() ~= c:GetBaseAttack()
end
function s.negtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0)
    end
end
function s.negop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        if Duel.Destroy(eg, REASON_EFFECT) > 0 and c:IsRelateToEffect(e) and c:IsFaceup() then
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