-- Okami - Ninetales
-- Scripted by Leonardofake & Imp
local s,id=GetID()
function s.initial_effect(c)
    --Special Summon
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e0:SetRange(LOCATION_HAND)
    e0:SetCondition(s.spcon)
    e0:SetTarget(s.sptg)
    e0:SetOperation(s.spop)
    c:RegisterEffect(e0) 
    --Unaffected
	local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.unfilter)
    c:RegisterEffect(e1)
    --ATK Change
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(s.atkval2)
	c:RegisterEffect(e3)
end
--Special Summon
function s.spfilter(c,ft)
    return c:IsAbleToGraveAsCost() and (ft>0 or c:GetSequence()<5)
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_SZONE,LOCATION_SZONE,nil,ft)
    return ft>-1 and #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,nil,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
    local c=e:GetHandler()
    local g=nil
    local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_SZONE,LOCATION_SZONE,nil,Duel.GetLocationCount(tp,LOCATION_MZONE))
    local g=aux.SelectUnselectGroup(rg,e,tp,1,1,nil,1,tp,HINTMSG_TOGRAVE,nil,nil,true)
    if #g>0 then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=e:GetLabelObject()
    if not g then return end
    Duel.SendtoGrave(g,REASON_COST)
    g:DeleteGroup()
end 
--Unaffected
function s.unfilter(e,te)
    return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
--ATK Change
function s.atkfilter(c)
    return c:IsMonster()
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_GRAVE,LOCATION_GRAVE,nil)*100
end
function s.atkfilter2(c)
    return c:IsMonster() and c:IsSetCard(0x444) and c:IsFaceup()
end
function s.atkval2(e,c)
    return Duel.GetMatchingGroupCount(s.atkfilter2,c:GetControler(),LOCATION_REMOVED,LOCATION_REMOVED,nil)*200
end 