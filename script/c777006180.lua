--
--Scripted by KillerxG
local s,id=GetID()
Duel.LoadScript("proc_divine_hierarchy_mod.lua")
function s.initial_effect(c)
	--Synchro Summon
	Synchro.AddProcedure(c,s.tunerfilter,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--Divine Hierarchy Rank 1
	DivineHierarchyMod.Register(c,1)
	--(1)Attack Twice
	local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EXTRA_ATTACK)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    --(2)Bounce
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
	--(3)Recycle
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_PHASE + PHASE_END)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id + 1)
    e3:SetCondition(s.epcon)
    e3:SetTarget(s.rocktg)
    e3:SetOperation(s.rockop)
    c:RegisterEffect(e3)
end
s.material={777006250}
--Synchro Summon
function s.tunerfilter(c,lc,stype,tp)
	return c:IsSummonCode(lc,stype,tp,777006250) or c:IsHasEffect(777006280)
end
--(2)Bounce
function s.thfilter(c)
    return c:IsAbleToHand()
end
function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1 - tp) and s.thfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.thfilter, tp, 0, LOCATION_MZONE, 1, nil) end    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RTOHAND)
    local g = Duel.SelectTarget(tp, s.thfilter, tp, 0, LOCATION_MZONE, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, 0)
end
function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc, tp, REASON_EFFECT)
    end
end
--(3)Recycle
function s.epcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == tp
end
function s.rockfilter(c)
    return c:IsRace(RACE_YOKAI) and c:IsAbleToHand()
end
function s.rocktg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.rockfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.rockfilter, tp, LOCATION_GRAVE, 0, 1, nil) end    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectTarget(tp, s.rockfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, tp, LOCATION_GRAVE)
end
function s.rockop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        if Duel.SendtoHand(tc, nil, REASON_EFFECT) > 0 then
            Duel.ConfirmCards(1 - tp, tc)
        end
    end
end