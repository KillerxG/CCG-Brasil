--Northern Guild Quest
--Scripted by KillerxG
local s, id = GetID()
function s.initial_effect(c)
    --(1)Search
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    --(2)Draw 1 card
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BATTLE_DESTROYING)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.drcon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.drtg)
    e2:SetOperation(s.drop)
    c:RegisterEffect(e2)
end
--(1)Search
function s.thfilter1(c)
    return c:IsSetCard(0x280) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thfilter2(c)
    return c:IsCode(777002610) and c:IsAbleToHand()
end
function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter1, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end
function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thfilter1, tp, LOCATION_DECK, 0, 1, 1, nil)    
    if #g > 0 and Duel.SendtoHand(g, nil, REASON_EFFECT) > 0 then
        Duel.ConfirmCards(1 - tp, g)
        local has_field = Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, 777002610), tp, LOCATION_ONFIELD, 0, 1, nil)
        if not has_field and Duel.IsExistingMatchingCard(s.thfilter2, tp, LOCATION_DECK, 0, 1, nil) then
            if Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
                local sg = Duel.SelectMatchingCard(tp, s.thfilter2, tp, LOCATION_DECK, 0, 1, 1, nil)
                if #sg > 0 then
                    Duel.SendtoHand(sg, nil, REASON_EFFECT)
                    Duel.ConfirmCards(1 - tp, sg)
                end
            end
        end
    end
end
--(2)Draw 1 card
function s.cfilter(c, tp)
    local bc = c:GetBattleTarget()
    return c:IsControler(tp) and c:IsSetCard(0x280) and c:IsRelateToBattle() 
        and bc and bc:IsControler(1 - tp) and bc:IsReason(REASON_BATTLE)
end
function s.drcon(e, tp, eg, ep, ev, re, r, rp)
    local has_field = Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, 777002610), tp, LOCATION_ONFIELD, 0, 1, nil)
    return has_field and eg:IsExists(s.cfilter, 1, nil, tp)
end
function s.drtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDraw(tp, 1) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end
function s.drop(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    Duel.Draw(p, d, REASON_EFFECT)
end