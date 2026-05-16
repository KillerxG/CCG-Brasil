--Northern Guild - Nefios
--Scripted by KillerxG
local s, id = GetID()
function s.initial_effect(c)
    --(1)Unaffected
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.immcon)
    e1:SetValue(s.immval)
    c:RegisterEffect(e1)
	--(2)Special Summon itself
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON | CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
	--(3)Change this card's Level
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.lvtg)
    e3:SetOperation(s.lvop)
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
--(2)Special Summon itself
function s.atkfilter(c)
    return c:IsFaceup() and c:GetAttack() >= 1000
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.atkfilter(chkc) end
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingTarget(s.atkfilter, tp, LOCATION_MZONE, 0, 1, nil)
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
        
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, s.atkfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end
function s.splimit(e, c, sump, sumtype, sumpos, targetp, se)
    return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x280)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()    
    if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:GetAttack() >= 1000 then
        local pre_atk = tc:GetAttack()        
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(-1000)
        e1:SetReset(RESET_EVENT | RESETS_STANDARD)
        tc:RegisterEffect(e1)
        if not tc:IsHasEffect(EFFECT_REVERSE_UPDATE) and tc:GetAttack() == pre_atk - 1000 then
            if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then                
                local e2 = Effect.CreateEffect(c)
                e2:SetType(EFFECT_TYPE_FIELD)
                e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
                e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET | EFFECT_FLAG_CLIENT_HINT)
                e2:SetDescription(aux.Stringid(id, 2))
                e2:SetTargetRange(1, 0)
                e2:SetTarget(s.splimit)
                e2:SetReset(RESET_PHASE | PHASE_END)
                Duel.RegisterEffect(e2, tp)
            end
        end
    end
end
--(3)Change this card's Level
function s.lvtg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:GetAttack() >= 400 and c:GetLevel() ~= 7 end
end
function s.lvop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFaceup() and c:IsRelateToEffect(e) and c:GetAttack() >= 400 then
        local pre_atk = c:GetAttack()        
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(-400)
        e1:SetReset(RESET_EVENT | RESETS_STANDARD)
        c:RegisterEffect(e1)
        if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) and c:GetAttack() == pre_atk - 400 then
            local e2 = Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_CHANGE_LEVEL)
            e2:SetValue(7)
            e2:SetReset(RESET_EVENT | RESETS_STANDARD)
            c:RegisterEffect(e2)
        end
    end
end