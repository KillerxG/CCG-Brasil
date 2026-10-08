--Diabound Necrophades
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	c:EnableReviveLimit()
	--(1)Ritual Summon
	local ritual_params={handler=c,lvtype=RITPROC_GREATER,filter=function(c) return c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK) end}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.IsMainPhase() end)
	e1:SetCost(Cost.SelfReveal)
	e1:SetTarget(Ritual.Target(ritual_params))
	e1:SetOperation(Ritual.Operation(ritual_params))
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e1)
	--(2)Search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--(3)Negate
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_NEGATE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+2)
    e3:SetCondition(s.negcon)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)
    --(4)Recycle
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,3))
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_ATKCHANGE)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetCountLimit(1,id+3)
    e4:SetCondition(s.th2con)
    e4:SetTarget(s.th2tg)
    e4:SetOperation(s.th2op)
    c:RegisterEffect(e4)
end
--(2)Search
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsRitualSummoned()
end
function s.thfilter(c)
	return c:IsCode(16625614) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--(3)Negate
function s.tfilter(c,tp)
    return c:IsControler(tp) and c:IsOnField() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.negcon(e, tp, eg, ep, ev, re, r, rp)
    if rp == tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end 
    local g = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    return g and g:IsExists(s.tfilter, 1, nil, tp)
end
function s.negtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
end
function s.negop(e, tp, eg, ep, ev, re, r, rp)
    Duel.NegateActivation(ev)
end
--(4)Recycle
function s.th2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsReason(REASON_BATTLE + REASON_EFFECT)
end
function s.th2filter(c)
    local isValidLoc = c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()
    return isValidLoc and c:IsCode(94212438, 30170981, 31893528, 67287533, 94772232) and c:IsAbleToHand()
end
function s.th2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE + LOCATION_REMOVED) and chkc:IsControler(tp) and s.th2filter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.th2filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil) end
    local max = Duel.GetMatchingGroupCount(s.th2filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, nil)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectTarget(tp, s.th2filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, max, nil)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, #g, tp, LOCATION_GRAVE + LOCATION_REMOVED)
end
function s.th2op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetTargetCards(e)
    if #g > 0 and Duel.SendtoHand(g, nil, REASON_EFFECT) > 0 then
        local cg = g:Filter(Card.IsLocation, nil, LOCATION_HAND)
        if #cg > 0 then
            Duel.ConfirmCards(1 - tp, cg)
            local opp_monsters = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil)
            if #opp_monsters > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 4)) then
                Duel.BreakEffect()
                local hand_count = Duel.GetFieldGroupCount(tp, LOCATION_HAND, 0)
                local atk_loss = hand_count * 400
                for tc in aux.Next(opp_monsters) do
                    local e1 = Effect.CreateEffect(e:GetHandler())
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetCode(EFFECT_UPDATE_ATTACK)
                    e1:SetValue(-atk_loss)
                    e1:SetReset(RESET_EVENT + RESETS_STANDARD)
                    tc:RegisterEffect(e1)
                end
            end
        end
    end
end