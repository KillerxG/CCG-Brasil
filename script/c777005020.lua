--Everlasting Soul Pressure
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    -- Ativação base da Armadilha
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
    c:RegisterEffect(e1)
	--(1)You can activate "Everlasting Soul" Trap Cards the turn they are Set
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetCondition(s.actcon)
	e2:SetTarget(function(e,c) return c:IsSetCard(0x258) end)
	c:RegisterEffect(e2)
    --(2)Change monster to Defense
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_POSITION | CATEGORY_DEFCHANGE | CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_SZONE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.postg)
    e3:SetOperation(s.posop)
    c:RegisterEffect(e3)
    --(3)Set Itself
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_GRAVE)
	e4:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
    e4:SetCountLimit(1,id+1)
    e4:SetCost(s.setcost)
    e4:SetTarget(s.settg)
    e4:SetOperation(s.setop)
    c:RegisterEffect(e4)
end
s.listed_names={777004920,id}
--(1)You can activate "Everlasting Soul" Trap Cards the turn they are Set
function s.bossfilter(c)
    return c:IsFaceup() and c:IsCode(777004920)
end
function s.actcon(e)
    return Duel.IsExistingMatchingCard(s.bossfilter, e:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, nil)
end
--(2)Change monster to Defense
function s.posfilter(c)
    return c:IsFaceup() and c:IsAttackPos() and not c:IsType(TYPE_LINK)
end
function s.postg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.posfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.posfilter, tp, 0, LOCATION_MZONE, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_POSCHANGE)
    local g = Duel.SelectTarget(tp, s.posfilter, tp, 0, LOCATION_MZONE, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_POSITION, g, 1, 0, 0)
end
function s.posop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsAttackPos() then
        local atk = tc:GetAttack()
        if Duel.ChangePosition(tc, POS_FACEUP_DEFENSE) > 0 then
            --Change DEF
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_DEFENSE)
            e1:SetValue(-atk)
            e1:SetReset(RESET_EVENT | RESETS_STANDARD)
            tc:RegisterEffect(e1)            
            --Destroy it if control Yuna
            if tc:GetDefense() == 0 and Duel.IsExistingMatchingCard(s.bossfilter, tp, LOCATION_MZONE, 0, 1, nil) then
                Duel.BreakEffect()
                Duel.Destroy(tc, REASON_EFFECT)
            end
        end
    end
end
--(3)Set Itself
function s.cfilter(c)
    return c:IsAbleToRemoveAsCost()
end
function s.setcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_GRAVE, 0, 1, c) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_GRAVE, 0, 1, 1, c)
    Duel.Remove(g, POS_FACEUP, REASON_COST)
end
function s.settg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsSSetable() end
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, c, 1, 0, 0)
end
function s.setop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsSSetable() then
        Duel.SSet(tp, c)
		--Banish it when leaves the field
        local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
    end
end