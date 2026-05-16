--Northern Guild - Meitu
--Scripted by KillerxG
local s, id = GetID()
function s.initial_effect(c)
    --(1)Speficla Summon itself
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND | LOCATION_GRAVE)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
	--(2)Double other monster's ATK
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id + 1)
    e2:SetTarget(s.atktg)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)
	--(3)Recycle "Northern Guild" S/T
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetProperty(EFFECT_FLAG_DELAY | EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1, id + 2)
    e3:SetCondition(s.thcon)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
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
--(1)Speficla Summon itself
function s.cfilter(c)
    return c:IsFaceup() and c:GetAttack() ~= c:GetBaseAttack()
end
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        local is_from_gy = c:IsLocation(LOCATION_GRAVE)        
        if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 and is_from_gy then            
            local e1 = Effect.CreateEffect(c)
			e1:SetDescription(3300)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
            e1:SetReset(RESET_EVENT | RESETS_REDIRECT)
            e1:SetValue(LOCATION_REMOVED)
            c:RegisterEffect(e1, true)
		end
    end
end
--(2)Double other monster's ATK
function s.atkfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x280)
end
function s.atktg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	local c = e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.atkfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.atkfilter, tp, LOCATION_MZONE, 0, 1, c) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, s.atkfilter, tp, LOCATION_MZONE, 0, 1, 1, c)
end
function s.atkop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        --Double ATK
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(tc:GetAttack() * 2)
        e1:SetReset(RESET_EVENT | RESETS_STANDARD | RESET_PHASE | PHASE_END)
        tc:RegisterEffect(e1)        
        --"Northern Guild - Meitu" monsters cannot attack
        local e2 = Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_CANNOT_ATTACK)
        e2:SetTargetRange(LOCATION_MZONE, 0)
        e2:SetTarget(function(e, c) return c:IsCode(id) end)
        e2:SetReset(RESET_PHASE | PHASE_END)
        Duel.RegisterEffect(e2, tp)
    end
end
--(3)Recycle "Northern Guild" S/T
function s.thcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()
    return c:IsLocation(LOCATION_GRAVE) and (r & (REASON_SYNCHRO | REASON_LINK)) ~= 0 and rc and rc:IsSetCard(0x280)
end
function s.thfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x280) and c:IsType(TYPE_SPELL | TYPE_TRAP) and c:IsAbleToHand()
end
function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.thfilter, tp, LOCATION_GRAVE+LOCATION_REMOVED, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectTarget(tp, s.thfilter, tp, LOCATION_GRAVE+LOCATION_REMOVED, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, 0)
end
function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, tc)
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