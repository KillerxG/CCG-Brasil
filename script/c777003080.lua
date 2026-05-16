--Hate Hat Euphoria
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    c:EnableCounterPermit(0x1b9)
    --(1)Inflict 500 damage
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTarget(s.damtg)
    e1:SetOperation(s.damop)
    c:RegisterEffect(e1)
    --(2)Add Euphoria Counter
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_DAMAGE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.ctcon)
    e2:SetOperation(s.ctop)
    c:RegisterEffect(e2)
    --(3)Destroy opponent's monster
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_SZONE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER_E)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)
end
--(1)Inflict 500 damage
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetTargetPlayer(1-tp)
    Duel.SetTargetParam(500)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Damage(p,d,REASON_EFFECT)
end
--(2)Add Euphoria Counter
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    return ep~=tp and (r&REASON_EFFECT)~=0 and re:GetHandler():IsSetCard(0x275)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    e:GetHandler():AddCounter(0x1b9,1)
end
--(3)Destroy opponent's monster
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
    if chk==0 then
        local ct=e:GetHandler():GetCounter(0x1b9)
        return ct>0 and Duel.IsExistingMatchingCard(Card.IsLevel,tp,0,LOCATION_MZONE,1,nil,ct)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local counters=Duel.AnnounceNumber(tp,table.unpack(s.getAvailableLevels(e:GetHandler())))
    e:SetLabel(counters)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,Card.IsLevel,tp,0,LOCATION_MZONE,1,1,nil,counters)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsLevel(e:GetLabel()) then
        e:GetHandler():RemoveCounter(tp,0x1b9,e:GetLabel(),REASON_COST)
        Duel.Destroy(tc,REASON_EFFECT)
    end
end
function s.getAvailableLevels(card)
    local levels={}
    for i=1,card:GetCounter(0x1b9) do
        if Duel.IsExistingMatchingCard(Card.IsLevel,card:GetControler(),0,LOCATION_MZONE,1,nil,i) then
            table.insert(levels,i)
        end
    end
    return levels
end
