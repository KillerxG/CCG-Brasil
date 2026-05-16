--Northern Guild - Anna
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon
	Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x280),1,1,Synchro.NonTuner(nil),1,99)
	--(1)Alternative Synchro Summon
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SYNCHRO_LEVEL)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_IGNORE_IMMUNE)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetTargetRange(LOCATION_MZONE,0)
    e0:SetTarget(s.linktg)
    e0:SetValue(2)
    c:RegisterEffect(e0)
    local e0b=e0:Clone()
    e0b:SetCode(EFFECT_ADD_TYPE)
    e0b:SetValue(TYPE_TUNER)
    c:RegisterEffect(e0b)
	--(2)Unaffected
	local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.immcon)
    e1:SetValue(s.immval)
    c:RegisterEffect(e1)
	--(3)Change opponent1s monster ATK to 700
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(TIMING_BATTLE_START, TIMING_BATTLE_START)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.atkcon)
    e2:SetCost(s.atkcost)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)
	--(4)Revive then change battle target
	local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_ATTACK_ANNOUNCE)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,id+1)
    e3:SetCondition(s.spcon)
    e3:SetCost(s.spcost)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end
--(1)Alternative Synchro Summon
function s.linktg(e, c)
    return c:IsType(TYPE_LINK) and c:GetLink()==2
end
--(2)Unaffected
function s.immcon(e)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,777002610),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function s.immval(e, te)
    local tc = te:GetHandler()
    return te:IsActiveType(TYPE_MONSTER) and tc:GetControler() ~= e:GetHandlerPlayer() 
        and tc:GetBaseAttack() < e:GetHandler():GetAttack()
end
--(3)Change opponent1s monster ATK to 700
function s.atkcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetCurrentPhase() == PHASE_BATTLE_START
end

function s.atkcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, nil) end
    Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1, REASON_COST | REASON_DISCARD)
end
function s.atkop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil)
    for tc in aux.Next(g) do
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(700)
        e1:SetReset(RESET_EVENT | RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end
end
--(4)Revive then change battle target
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetAttacker():IsControler(1 - tp)
end
function s.cfilter(c)
    return c:IsAbleToRemoveAsCost()
end
function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_GRAVE, 0, 2, c) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_GRAVE, 0, 2, 2, c)
    Duel.Remove(g, POS_FACEUP, REASON_COST)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        local a = Duel.GetAttacker()
        if a and a:IsRelateToBattle() and not a:IsImmuneToEffect(e) then
            Duel.ChangeAttackTarget(c)
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
            e1:SetValue(1)
            e1:SetReset(RESET_PHASE | PHASE_DAMAGE)
            c:RegisterEffect(e1)
        end
    end
end