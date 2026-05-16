--West Royal Dragon - Witch Irya
--Scripted by KillerxG
local s, id = GetID()
function s.initial_effect(c)
	--Fusion Summon
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,777003710,777002840)
    --(1)Change Name
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
    e1:SetValue(777003710)
    c:RegisterEffect(e1)
	--(2)Burn if Special
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.damcon)
    e2:SetOperation(s.damop)
    c:RegisterEffect(e2)
	--(3)Recycle, then can SS Token
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id)
    e3:SetTarget(s.tokentg)
    e3:SetOperation(s.tokenop)
    c:RegisterEffect(e3)
end
s.listed_names={777003710,777002840,id}
--(2)Burn if Special
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
function s.colfilter(tc, c)
    if tc == c then return false end    
    local col1 = s.get_col(tc)
    local col2 = s.get_col(c)
    return col1 ~= -1 and col2 ~= -1 and col1 ~= col2
end
function s.damcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return eg:IsExists(s.colfilter, 1, nil, c)
end
function s.damop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_CARD, 0, id)
    Duel.Damage(1-tp, 500, REASON_EFFECT)
end
--(3)Recycle, then can SS Token
function s.thfilter(c)
    return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.revfilter(c, e, tp)
    return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
        and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsPlayerCanSpecialSummonMonster(tp, id+5, 0x288, TYPES_TOKEN, c:GetAttack(), c:GetDefense(), c:GetLevel(), RACE_DRAGON, ATTRIBUTE_DARK)
end
function s.tokentg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.thfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.thfilter, tp, LOCATION_GRAVE, 0, 1, nil) end    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectTarget(tp, s.thfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)    
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, 0)
    Duel.SetPossibleOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND)
    Duel.SetPossibleOperationInfo(0, CATEGORY_TOKEN, nil, 1, tp, 0)
end
function s.tokenop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc, nil, REASON_EFFECT) > 0 then
        local g = Duel.GetMatchingGroup(s.revfilter, tp, LOCATION_HAND, 0, nil, e, tp)
        if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
            local rg = g:Select(tp, 1, 1, nil)
            Duel.ConfirmCards(1-tp, rg)
            Duel.ShuffleHand(tp)            
            local rc = rg:GetFirst()   
            local token = Duel.CreateToken(tp, id+5)
            if Duel.SpecialSummonStep(token, 0, tp, tp, false, false, POS_FACEUP) then
				--Set Level
                local c = e:GetHandler()
                local e1 = Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_CHANGE_LEVEL)
                e1:SetValue(rc:GetLevel())
                e1:SetReset(RESET_EVENT | RESETS_STANDARD)
                token:RegisterEffect(e1, true)
                --Set Attack
                local e2 = Effect.CreateEffect(c)
                e2:SetType(EFFECT_TYPE_SINGLE)
                e2:SetCode(EFFECT_SET_BASE_ATTACK)
                e2:SetValue(rc:GetAttack())
                e2:SetReset(RESET_EVENT | RESETS_STANDARD)
                token:RegisterEffect(e2, true)
                --Set Defense
                local e3 = Effect.CreateEffect(c)
                e3:SetType(EFFECT_TYPE_SINGLE)
                e3:SetCode(EFFECT_SET_BASE_DEFENSE)
                e3:SetValue(rc:GetDefense())
                e3:SetReset(RESET_EVENT | RESETS_STANDARD)
                token:RegisterEffect(e3, true)
                --Destroy, burn and change ATK to 0
                local e4 = Effect.CreateEffect(c)
                e4:SetDescription(aux.Stringid(id, 2))
                e4:SetCategory(CATEGORY_DESTROY | CATEGORY_DAMAGE | CATEGORY_ATKCHANGE)
                e4:SetType(EFFECT_TYPE_IGNITION)
                e4:SetRange(LOCATION_MZONE)
                e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
                e4:SetTarget(s.tdestg)
                e4:SetOperation(s.tdesop)
                e4:SetReset(RESET_EVENT | RESETS_STANDARD)
                token:RegisterEffect(e4, true)                
                Duel.SpecialSummonComplete()
            end
        end
    end
end
function s.tdesfilter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
function s.tdestg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.tdesfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.tdesfilter, tp, 0, LOCATION_MZONE, 1, nil) end    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, s.tdesfilter, tp, 0, LOCATION_MZONE, 1, 1, nil)    
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, e:GetHandler(), 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1-tp, 1000)
end
function s.tdesop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()    
    if c:IsRelateToEffect(e) and Duel.Destroy(c, REASON_EFFECT) > 0 then
        if Duel.Damage(1-tp, 1000, REASON_EFFECT) > 0 and tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
            local e1 = Effect.CreateEffect(e:GetOwner())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SET_ATTACK_FINAL)
            e1:SetValue(0)
            e1:SetReset(RESET_EVENT | RESETS_STANDARD)
            tc:RegisterEffect(e1)
        end
    end
end