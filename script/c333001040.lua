--Megarock Blader
--Script fixed by KillerxG
local s,id=GetID()
function s.initial_effect(c)
   c:EnableReviveLimit()  
   --(1)Return card(s) sent to GY
   local e1=Effect.CreateEffect(c)
   e1:SetDescription(aux.Stringid(id,0))
   e1:SetCategory(CATEGORY_TOHAND)
   e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
   e1:SetCode(EVENT_TO_GRAVE)
   e1:SetProperty(EFFECT_FLAG_DELAY)
   e1:SetRange(LOCATION_HAND)
   e1:SetCountLimit(1,id)
   e1:SetCondition(s.thcon)
   e1:SetCost(s.thcost)
   e1:SetTarget(s.thtg)
   e1:SetOperation(s.thop)
   c:RegisterEffect(e1)
   --(2)Send to GY, gain ATK/DEF
   local e2=Effect.CreateEffect(c)
   e2:SetDescription(aux.Stringid(id,1))
   e2:SetCategory(CATEGORY_TOGRAVE)
   e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
   e2:SetType(EFFECT_TYPE_QUICK_O)
   e2:SetCode(EVENT_FREE_CHAIN)
   e2:SetRange(LOCATION_MZONE)
   e2:SetHintTiming(TIMING_DAMAGE_STEP)
   e2:SetCountLimit(1,id+1)
   e2:SetCondition(aux.StatChangeDamageStepCondition)
   e2:SetTarget(s.atktg)
   e2:SetOperation(s.atkop)
   c:RegisterEffect(e2)
   --(3)Reduce ATK, then can destroy
   local e3=Effect.CreateEffect(c)
   e3:SetDescription(aux.Stringid(id,2))
   e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
   e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
   e3:SetCode(EVENT_TO_GRAVE)
   e3:SetProperty(EFFECT_FLAG_DELAY)
   e3:SetCountLimit(1,id+2)
   e3:SetCondition(s.descon)
   e3:SetTarget(s.destg)
   e3:SetOperation(s.desop)
   c:RegisterEffect(e3)
   local e4=Effect.CreateEffect(c)
   e4:SetDescription(aux.Stringid(id,2))
   e4:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
   e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
   e4:SetCode(EVENT_SPSUMMON_SUCCESS)
   e4:SetProperty(EFFECT_FLAG_DELAY)
   e4:SetCountLimit(1,id+2)
   e4:SetCondition(s.descon2)
   e4:SetTarget(s.destg)
   e4:SetOperation(s.desop)
   c:RegisterEffect(e4)
   --(4)Gain name "Minomushi Warrior" while on the field or GY
   local e5=Effect.CreateEffect(c)
   e5:SetType(EFFECT_TYPE_SINGLE)
   e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
   e5:SetCode(EFFECT_ADD_CODE)
   e5:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
   e5:SetValue(46864967)
   c:RegisterEffect(e5)      
end
s.listed_names={46864967}
 --(1)Return card(s) sent to GY
function s.cfilter(c)
    return (c:IsSetCard(0x259) or c:IsCode(46864967)) and c:IsAbleToHand()
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsDiscardable() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=eg:Filter(s.cfilter,nil)
    if chk==0 then return #g>0 end
    Duel.SetTargetCard(g)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    if not tg then return end
    local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
    if #sg>0 then
       Duel.SendtoHand(sg,nil,REASON_EFFECT)
    end
end
--(2)Send to GY, gain ATK/DEF
function s.rockfilter(c)
    return c:IsRace(RACE_ROCK) and c:IsAbleToGrave()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.rockfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.rockfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
       local c=e:GetHandler()
       if c:IsFaceup() and c:IsRelateToEffect(e) then
          -- Aumenta ATK
          local e1=Effect.CreateEffect(c)
          e1:SetType(EFFECT_TYPE_SINGLE)
          e1:SetCode(EFFECT_UPDATE_ATTACK)
          e1:SetValue(700)
          e1:SetReset(RESET_EVENT+RESETS_STANDARD)
          c:RegisterEffect(e1)
          -- Aumenta DEF
          local e2=Effect.CreateEffect(c)
          e2:SetType(EFFECT_TYPE_SINGLE)
          e2:SetCode(EFFECT_UPDATE_DEFENSE)
          e2:SetValue(700)
          e2:SetReset(RESET_EVENT+RESETS_STANDARD)
          c:RegisterEffect(e2)
       end
    end
end
--(3)Reduce ATK, then can destroy
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return re and (re:GetHandler():IsSetCard(0x259) or re:GetHandler():IsCode(46864967)) and re:GetHandler()~=e:GetHandler()
end
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
    return re and (re:GetHandler():IsSetCard(0x259) or re:GetHandler():IsCode(46864967)) and re:GetHandler()~=e:GetHandler()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,0,1-tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,1-tp,LOCATION_MZONE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local def=c:GetDefense()
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    for tc in aux.Next(g) do
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(-def)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end
    Duel.BreakEffect()
    local dg=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:GetAttack()==0 end, tp, 0, LOCATION_MZONE, nil)
    if #dg>0 then
       Duel.Destroy(dg,REASON_EFFECT)
    end
end
