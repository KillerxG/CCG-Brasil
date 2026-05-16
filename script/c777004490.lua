--Ginsetsu, Great Fox
--Scripted by KillerxG
local s, id = GetID()
function s.initial_effect(c)
    --(1)Spirit Return
    Spirit.AddProcedure(c, EVENT_SPSUMMON_SUCCESS)
	--(2)Special Summon itself
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON | CATEGORY_TOHAND | CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
	--(3)Special Summon Token
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON | CATEGORY_TOKEN)
    e3:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY | EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1, id + 1)
    e3:SetTarget(s.tokentg)
    e3:SetOperation(s.tokenop)
    c:RegisterEffect(e3)
end
--(2)Special Summon itself
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
        and Duel.IsExistingTarget(Card.IsFaceup, tp, LOCATION_MZONE, 0, 1, nil) end        
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local g = Duel.SelectTarget(tp, Card.IsFaceup, tp, LOCATION_MZONE, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
    Duel.SetPossibleOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, 0)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()    
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
            local b1 = tc:IsAbleToHand()
            local b2 = tc:GetAttack() >= 1100            
            if not b1 and not b2 then return end            
            local op = 0
            if b1 and b2 then
                op = Duel.SelectOption(tp, aux.Stringid(id, 2), aux.Stringid(id, 3))
            elseif b1 then
                op = Duel.SelectOption(tp, aux.Stringid(id, 2))
            else
                op = Duel.SelectOption(tp, aux.Stringid(id, 3)) + 1
            end            
            if op == 0 then
                Duel.SendtoHand(tc, nil, REASON_EFFECT)
            else
                local e1 = Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_ATTACK)
                e1:SetValue(-1100)
                e1:SetReset(RESET_EVENT | RESETS_STANDARD)
                tc:RegisterEffect(e1)
            end
        end
    end
end
--(3)Special Summon Token
function s.tokentg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() and chkc ~= c end
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingTarget(Card.IsFaceup, tp, LOCATION_MZONE, 0, 1, c) end        
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, Card.IsFaceup, tp, LOCATION_MZONE, 0, 1, 1, c)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOKEN, nil, 1, tp, 0)
end
function s.tokenop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end    
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        local token = Duel.CreateToken(tp, id + 5)        
        if Duel.SpecialSummonStep(token, 0, tp, tp, false, false, POS_FACEUP) then
            local c = e:GetHandler()            
            --Copy Name
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CHANGE_CODE)
            e1:SetValue(tc:GetCode())
            e1:SetReset(RESET_EVENT | RESETS_STANDARD)
            token:RegisterEffect(e1, true)
			--Copy Race
            local e2 = Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_CHANGE_RACE)
            e2:SetValue(tc:GetRace())
            e2:SetReset(RESET_EVENT | RESETS_STANDARD)
            token:RegisterEffect(e2, true)
            --Copy Attribute
            local e3 = Effect.CreateEffect(c)
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
            e3:SetValue(tc:GetAttribute())
            e3:SetReset(RESET_EVENT | RESETS_STANDARD)
            token:RegisterEffect(e3, true)            
            --Copy Level
            if tc:HasLevel() then
                local e4 = Effect.CreateEffect(c)
                e4:SetType(EFFECT_TYPE_SINGLE)
                e4:SetCode(EFFECT_CHANGE_LEVEL)
                e4:SetValue(tc:GetLevel())
                e4:SetReset(RESET_EVENT | RESETS_STANDARD)
                token:RegisterEffect(e4, true)
            end            
            --Copy ATK
            local e5 = Effect.CreateEffect(c)
            e5:SetType(EFFECT_TYPE_SINGLE)
            e5:SetCode(EFFECT_SET_BASE_ATTACK)
            e5:SetValue(tc:GetAttack())
            e5:SetReset(RESET_EVENT | RESETS_STANDARD)
            token:RegisterEffect(e5, true)
            --Copy DEF
            local e6 = Effect.CreateEffect(c)
            e6:SetType(EFFECT_TYPE_SINGLE)
            e6:SetCode(EFFECT_SET_BASE_DEFENSE)
            e6:SetValue(tc:GetDefense())
            e6:SetReset(RESET_EVENT | RESETS_STANDARD)
            token:RegisterEffect(e6, true)            
            Duel.SpecialSummonComplete()
        end
    end
end