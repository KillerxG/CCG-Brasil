--West Royal Dragon - Annie
--Scripted by KillerxG
local s, id = GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()    
    --(1)Search Ritual Spell
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_RECOVER)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.thcost)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)    
    --(2)Destroy opponent's card
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+1)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)    
    --(3)Draw
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_RECOVER)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+2)
    e3:SetCondition(s.drcon)
    e3:SetTarget(s.drtg)
    e3:SetOperation(s.drop)
    c:RegisterEffect(e3)
end
s.listed_names={777003940,777003720,id}
--(1)Search Ritual Spell
function s.thcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return not c:IsPublic() end
    Duel.ConfirmCards(1-tp, c)
end
function s.thfilter(c)
    return c:IsRitualSpell() and c:IsAbleToHand()
end
function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    Duel.SetPossibleOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, 1000)
end
function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1-tp, g)
        if g:GetFirst():IsCode(777003720) then
            Duel.Recover(tp, 1000, REASON_EFFECT)
        end
    end
end
--(2)Destroy opponent's card
function s.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
    if chk == 0 then return Duel.IsExistingTarget(nil, tp, 0, LOCATION_ONFIELD, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, nil, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
    Duel.SetPossibleOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, 0)
end
function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        local is_mon = tc:IsMonster()
        local atk = tc:GetBaseAttack()
        if atk < 0 then atk = 0 end
        if Duel.Destroy(tc, REASON_EFFECT) > 0 and is_mon and atk > 0 then
            Duel.Recover(tp, math.floor(atk / 2), REASON_EFFECT)
        end
    end
end
--(3)Draw
function s.drcon(e, tp, eg, ep, ev, re, r, rp)
    return ep == tp
end
function s.drtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDraw(tp, 1) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
    Duel.SetPossibleOperationInfo(0, CATEGORY_HANDES, nil, 0, tp, 1)
end
function s.revfilter(c)
    return c:IsRitualMonster(TYPE_RITUAL) and not c:IsPublic() and not c:IsCode(id)
end
function s.drop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    if Duel.Draw(p,d,REASON_EFFECT) > 0 then
        local b1 = Duel.GetFieldGroupCount(tp, LOCATION_HAND, 0) > 0
        local b2 = Duel.IsExistingMatchingCard(s.revfilter, tp, LOCATION_HAND, 0, 1, nil)        
        if not b1 and not b2 then return end        
        local op = 0
        if b1 and b2 then
            op = Duel.SelectOption(tp, aux.Stringid(id, 3), aux.Stringid(id, 4))
        elseif b1 then
            op = Duel.SelectOption(tp, aux.Stringid(id, 3))
        else
            op = Duel.SelectOption(tp, aux.Stringid(id, 4)) + 1
        end        
        if op == 0 then
            Duel.DiscardHand(tp, nil, 1, 1, REASON_EFFECT | REASON_DISCARD)
        else
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
            local rg = Duel.SelectMatchingCard(tp, s.revfilter, tp, LOCATION_HAND, 0, 1, 1, nil)
            if #rg > 0 then
                Duel.ConfirmCards(1-tp, rg)
                Duel.ShuffleHand(tp)
                local tc = rg:GetFirst()
                if c:IsRelateToEffect(e) and c:IsFaceup() then
                    local e1 = Effect.CreateEffect(c)
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                    e1:SetCode(EFFECT_CHANGE_CODE)
                    e1:SetValue(tc:GetCode())
                    e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
                    c:RegisterEffect(e1)
                end
            end
        end
    end
end
