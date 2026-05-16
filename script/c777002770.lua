--Northern Guild - Sophie
--Scripted by KillerxG
local s, id = GetID()
function s.initial_effect(c)
    --(1)Special Summon itself
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON | CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_TO_HAND)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
	--(2)Change opponent's monster ATK to 0
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_CONTINUOUS)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetCode(EVENT_ADJUST)
    e0:SetRange(LOCATION_MZONE)
    e0:SetOperation(s.atkcheck)
    c:RegisterEffect(e0)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_CUSTOM + id) 
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET | EFFECT_FLAG_DELAY | EFFECT_FLAG_DAMAGE_STEP)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.atktgcon)
    e2:SetTarget(s.atktg)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)
	--(3)Self Recycle
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1, id + 2)
    e3:SetCondition(s.regcon)
    e3:SetTarget(s.regtg)
    e3:SetOperation(s.regop)
    c:RegisterEffect(e3)
	--(4)Unaffected
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_IMMUNE_EFFECT)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.immcon)
    e4:SetValue(s.immval)
    c:RegisterEffect(e4)
end
--(1)Special Summon itself
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    return not e:GetHandler():IsReason(REASON_DRAW)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end
function s.atkfilter(c)
    return c:IsFaceup() and c:GetAttack() >= 500
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        if c:GetFlagEffect(id + 100) == 0 then
            c:RegisterFlagEffect(id + 100, RESET_EVENT | RESETS_STANDARD, 0, 1, c:GetAttack())
        end        
        local g = Duel.GetMatchingGroup(s.atkfilter, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
        if #g > 0 then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
            local sg = g:Select(tp, 1, 1, nil)
            Duel.HintSelection(sg)
            local tc = sg:GetFirst()            
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(-500)
            e1:SetReset(RESET_EVENT | RESETS_STANDARD)
            tc:RegisterEffect(e1)
        end
    end
end
--(2)Change opponent's monster ATK to 0
function s.atkcheck(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsFaceup() then return end    
    local prev_atk = c:GetFlagEffectLabel(id + 100)
    local curr_atk = c:GetAttack()    
    if not prev_atk then
        c:RegisterFlagEffect(id + 100, RESET_EVENT | RESETS_STANDARD, 0, 1, curr_atk)
    elseif prev_atk ~= curr_atk then
        c:SetFlagEffectLabel(id + 100, curr_atk)
        local cg = Group.FromCards(c)
        Duel.RaiseEvent(cg, EVENT_CUSTOM + id, e, REASON_EFFECT, tp, tp, 0)
    end
end
function s.atktgcon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsContains(e:GetHandler())
end
function s.atk0filter(c)
    return c:IsFaceup() and c:GetAttack() > 0
end
function s.atktg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1 - tp) and s.atk0filter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.atk0filter, tp, 0, LOCATION_MZONE, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, s.atk0filter, tp, 0, LOCATION_MZONE, 1, 1, nil)
end
function s.atkop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(0)
        e1:SetReset(RESET_EVENT | RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end
end
--(3)Self Recycle
function s.regcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()
    return c:IsLocation(LOCATION_GRAVE) and (r & (REASON_SYNCHRO | REASON_LINK)) ~= 0 and rc and rc:IsSetCard(0x280)
end
function s.regtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
end
function s.regop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE | PHASE_STANDBY)
    e1:SetCountLimit(1)
    e1:SetCondition(s.thcon)
    e1:SetOperation(s.thop)    
    if Duel.GetTurnPlayer() == tp and Duel.GetCurrentPhase() == PHASE_STANDBY then
        e1:SetLabel(Duel.GetTurnCount())
        e1:SetReset(RESET_PHASE | PHASE_STANDBY | RESET_SELF_TURN, 2)
    else
        e1:SetLabel(0)
        e1:SetReset(RESET_PHASE | PHASE_STANDBY | RESET_SELF_TURN, 1)
    end
    Duel.RegisterEffect(e1, tp)
end
function s.thcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == tp and Duel.GetTurnCount() ~= e:GetLabel()
end
function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetOwner()
    if c:IsLocation(LOCATION_GRAVE) and c:IsAbleToHand() then
        Duel.Hint(HINT_CARD, 0, id)
        Duel.SendtoHand(c, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, c)
    end
end
--(4)Unaffected
function s.immcon(e)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, 777002610), e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil)
end
function s.immval(e, te)
    local tc = te:GetHandler()
    return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer() ~= e:GetHandlerPlayer() 
        and tc:GetBaseAttack() < e:GetHandler():GetAttack()
end