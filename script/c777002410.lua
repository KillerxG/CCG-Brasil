--Northern Guild - Ayre
--Scripted by KillerxG
local s, id = GetID()
function s.initial_effect(c)
    --Xyz Summon
    c:EnableReviveLimit()
    Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsSetCard, 0x280), 7, 2)
    --(1)Unaffected
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.immcon)
    e1:SetValue(s.immval)
    c:RegisterEffect(e1)
	--(2)Protect Field Spell from target
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_ONFIELD, 0)
    e2:SetCondition(s.protcon)
    e2:SetTarget(s.prottg)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)
    --(3)Protect Field Spell from destruction
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_ONFIELD, 0)
    e3:SetCondition(s.protcon)
    e3:SetTarget(s.prottg)
    e3:SetValue(aux.indoval)
    c:RegisterEffect(e3)
    --(4)Take control
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_CONTROL)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetHintTiming(0, TIMINGS_CHECK_MONSTER | TIMING_END_PHASE)
    e4:SetCountLimit(1, id)
    e4:SetCost(s.ctrlcost)
    e4:SetTarget(s.ctrltg)
    e4:SetOperation(s.ctrlop)
    c:RegisterEffect(e4)
	--(5)Attach
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 1))
    e5:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_PHASE | PHASE_END)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1, id + 1)
    e5:SetCondition(s.atchcon)
    e5:SetTarget(s.atchtg)
    e5:SetOperation(s.atchop)
    c:RegisterEffect(e5)
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
--(2 & 3)Protect Field Spell from target and destruction
function s.protcon(e)
    return e:GetHandler():GetOverlayCount() > 0
end

function s.prottg(e, c)
    return c:IsFaceup() and c:IsCode(777002610)
end
--(4)Take control
function s.ctrlcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():CheckRemoveOverlayCard(tp, 1, REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp, 1, 1, REASON_COST)
end
function s.ctrlfilter(c, atk)
    return c:IsFaceup() and c:GetAttack() < atk and c:IsControlerCanBeChanged()
end
function s.ctrltg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    local atk = c:GetAttack()    
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1 - tp) and s.ctrlfilter(chkc, atk) end
    if chk == 0 then return Duel.IsExistingTarget(s.ctrlfilter, tp, 0, LOCATION_MZONE, 1, nil, atk) end    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONTROL)
    local g = Duel.SelectTarget(tp, s.ctrlfilter, tp, 0, LOCATION_MZONE, 1, 1, nil, atk)
    Duel.SetOperationInfo(0, CATEGORY_CONTROL, g, 1, 0, 0)
end
function s.ctrlop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and c:IsRelateToEffect(e) and c:IsFaceup() then
        if tc:GetAttack() < c:GetAttack() then
            Duel.GetControl(tc, tp)
        end
    end
end
--(5)Attach
function s.atchcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == tp
end
function s.atchfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x280)
end
function s.atchtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.atchfilter(chkc) end
    local c = e:GetHandler()
    if chk == 0 then return c:IsType(TYPE_XYZ) and Duel.IsExistingTarget(s.atchfilter, tp, LOCATION_REMOVED, 0, 1, nil) end    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_XMATERIAL)
    Duel.SelectTarget(tp, s.atchfilter, tp, LOCATION_REMOVED, 0, 1, 1, nil)
end
function s.atchop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) then
        Duel.Overlay(c, tc)
    end
end