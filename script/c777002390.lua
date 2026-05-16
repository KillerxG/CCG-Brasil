--Northern Guild - Jack
--Scripted by KillerxG
local s, id = GetID()
function s.initial_effect(c)
    --Link Summon
    c:EnableReviveLimit()
    Link.AddProcedure(c, s.matfilter, 2, 2, s.lcheck)
    --(1)Unaffected
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.immcon)
    e1:SetValue(s.immval)
    c:RegisterEffect(e1)
    --(2)ATK Up
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_ATTACK_ANNOUNCE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.atkcon)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)
	--(3)Special Summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_ATKCHANGE | CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1, id)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end
--Link Summon
function s.matfilter(c)
    return c:IsType(TYPE_EFFECT)
end
function s.lcheck(g, lc, sumtype, tp)
    return g:IsExists(Card.IsSetCard, 1, nil, 0x280)
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
--(2)ATK Up
function s.atkcon(e, tp, eg, ep, ev, re, r, rp)
    local a = Duel.GetAttacker()
    return a and a:IsControler(tp)
end
function s.atkop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard, 0x280), tp, LOCATION_MZONE, 0, nil)    
    for tc in aux.Next(g) do
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(300)
        e1:SetReset(RESET_EVENT | RESETS_STANDARD | RESET_PHASE | PHASE_END, 2)
        tc:RegisterEffect(e1)
    end
end
--(3)Special Summon
function s.lossfilter(c)
    return c:IsFaceup() and c:GetAttack() >= 1000
end
function s.spfilter(c, e, tp)
    return c:IsSetCard(0x280) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    local zone = c:GetLinkedZone(tp) & 0x1f
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.lossfilter(chkc) end
    if chk == 0 then 
        return zone ~= 0 
            and Duel.GetLocationCount(tp, LOCATION_MZONE, tp, LOCATION_REASON_TOFIELD, zone) > 0
            and Duel.IsExistingTarget(s.lossfilter, tp, LOCATION_MZONE, 0, 1, nil)
            and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp) 
    end        
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, s.lossfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    local zone = c:GetLinkedZone(tp) & 0x1f    
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetAttack() >= 1000 then
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(-1000)
        e1:SetReset(RESET_EVENT | RESETS_STANDARD | RESET_PHASE | PHASE_END | RESET_OPPO_TURN, 1)
        tc:RegisterEffect(e1)
        if not tc:IsHasEffect(EFFECT_REVERSE_UPDATE) and zone ~= 0 and Duel.GetLocationCount(tp, LOCATION_MZONE, tp, LOCATION_REASON_TOFIELD, zone) > 0 then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
            local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
            if #g > 0 then
                Duel.BreakEffect()
                Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP, zone)
            end
        end
    end
end