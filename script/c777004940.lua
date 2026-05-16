--Everlasting Soul Absorption
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
    c:RegisterEffect(e1)
    --(1)Negate the effect of monsters with zero ATK
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_DISABLE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(0, LOCATION_MZONE)
    e2:SetCondition(s.negcon)
    e2:SetTarget(s.negtg)
    c:RegisterEffect(e2)    
    local e3=e2:Clone()
    e3:SetCode(EFFECT_DISABLE_EFFECT)
    c:RegisterEffect(e3)
    --(2)ATK Change
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_ATKCHANGE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_SZONE)
    e4:SetHintTiming(0, TIMINGS_CHECK_MONSTER | TIMING_MAIN_END)
    e4:SetCountLimit(1,id)
    e4:SetCondition(s.atkcon)
    e4:SetTarget(s.atktg)
    e4:SetOperation(s.atkop)
    c:RegisterEffect(e4)
	--(3)Set
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_SET)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1,id+1)
	e5:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e5:SetCost(Cost.SelfBanish)
	e5:SetTarget(s.settg)
	e5:SetOperation(s.setop)
	c:RegisterEffect(e5)
end
s.listed_names={777004920,id}
--(1)Negate the effect of monsters with zero ATK
function s.bossfilter(c)
    return c:IsFaceup() and c:IsCode(777004920)
end
function s.negcon(e)
    return Duel.IsExistingMatchingCard(s.bossfilter, e:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, nil)
end
function s.negtg(e, c)
    return c:IsFaceup() and c:GetAttack() == 0
end
--(2)ATK Change
function s.atkcon(e, tp, eg, ep, ev, re, r, rp)
    local ph = Duel.GetCurrentPhase()
    return ph == PHASE_MAIN1 or ph == PHASE_MAIN2
end
function s.disfilter(c)
	return c:IsFaceup() and not c:GetAttack()==0
end
function s.atktg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(1 - tp) and chkc:IsLocation(LOCATION_MZONE) and s.disfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.disfilter, tp, 0, LOCATION_MZONE, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local g = Duel.SelectTarget(tp, s.disfilter, tp, 0, LOCATION_MZONE, 1, 1, nil)
end
function s.esfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x258)
end
function s.atkop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end    
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(0)
        e1:SetReset(RESET_EVENT | RESETS_STANDARD)
        tc:RegisterEffect(e1)
        if Duel.IsExistingMatchingCard(s.bossfilter, tp, LOCATION_MZONE, 0, 1, nil) then
            local g = Duel.GetMatchingGroup(s.esfilter, tp, LOCATION_MZONE, 0, nil)
            if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id,1)) then
                Duel.BreakEffect()
                for ec in aux.Next(g) do
                    local e2 = Effect.CreateEffect(c)
                    e2:SetType(EFFECT_TYPE_SINGLE)
                    e2:SetCode(EFFECT_UPDATE_ATTACK)
                    e2:SetValue(1000)
                    e2:SetReset(RESET_EVENT | RESETS_STANDARD | RESET_PHASE | PHASE_END)
                    ec:RegisterEffect(e2)
                end
            end
        end
    end
end
--(3)Set
function s.setfilter(c)
	return c:IsSetCard(0x258) and c:IsContinuousTrap() and c:IsSSetable() and not c:IsCode(id)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end