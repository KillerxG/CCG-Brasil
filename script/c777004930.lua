--Everlasting Soul Encyclopedia
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --(1)Set/Place Trap
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SET)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
	--(2)Recycle
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(aux.exccon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end
--(1)Set/Place Trap
function s.setfilter(c, is_boss)
    if not (c:IsSetCard(0x258) and c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS)) then return false end
    if is_boss then
        return not c:IsForbidden()
    else
        return c:IsSSetable()
    end
end
function s.revfilter(c, tp)
    if not (c:IsLevel(10) and c:IsType(TYPE_SYNCHRO) and not c:IsPublic()) then return false end
    local is_boss=c:IsCode(777004920)
    return Duel.IsExistingMatchingCard(s.setfilter, tp, LOCATION_DECK, 0, 1, nil, is_boss)
end
function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.revfilter, tp, LOCATION_EXTRA, 0, 1, nil, tp) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)    
    local g = Duel.SelectMatchingCard(tp, s.revfilter, tp, LOCATION_EXTRA, 0, 1, 1, nil, tp)
    Duel.ConfirmCards(1-tp, g)
    if g:GetFirst():IsCode(777004920) then
        e:SetLabel(1)
    else
        e:SetLabel(0)
    end
end
function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_SZONE)>0 end
end
function s.operation(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_SZONE) <= 0 then return end    
    local is_boss = (e:GetLabel() == 1)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOFIELD)    
    local g = Duel.SelectMatchingCard(tp, s.setfilter, tp, LOCATION_DECK, 0, 1, 1, nil, is_boss)
    local tc = g:GetFirst()    
    if tc then
        if is_boss then
            -- "place that card face-up in your Spell & Trap Zone instead"
            Duel.MoveToField(tc, tp, tp, LOCATION_SZONE, POS_FACEUP, true)
        else
            -- "Set 1 Continuous Trap directly from your Deck"
            Duel.SSet(tp, tc)
        end
    end
end
--(2)Recycle
function s.thfilter(c)
    return c:IsSetCard(0x258) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.thfilter, tp, LOCATION_GRAVE, 0, 1, nil) end    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectTarget(tp, s.thfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, 0)
end
function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc, nil, REASON_EFFECT)
        if tc:IsLocation(LOCATION_HAND) then
            Duel.ConfirmCards(1-tp, tc)
        end
    end
end