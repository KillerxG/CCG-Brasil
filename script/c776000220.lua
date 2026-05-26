--Obelisk the Tormentor
--Scripted by KillerxG
local s,id=GetID()
Duel.LoadScript("proc_divine_hierarchy_mod.lua")
function s.initial_effect(c)	
	--Divine Hierarchy Rank 1
	DivineHierarchyMod.Register(c,1)
	--You can only control 1
	c:SetUniqueOnField(1,0,id)
	--Summon with 3 tribute
	local e1=aux.AddNormalSummonProcedure(c,true,false,3,3)
	local e2=aux.AddNormalSetProcedure(c)	
	--(1)Cannot Disable Summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e3)
	--(2)Cannot chain Summon
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetOperation(s.sumsuc)
	c:RegisterEffect(e4)
	--(3)Opponent's monsters must attack this card
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_MUST_ATTACK)
    e5:SetRange(LOCATION_MZONE)
    e5:SetTargetRange(0, LOCATION_MZONE)
    c:RegisterEffect(e5)
    local e6 = e5:Clone()
    e6:SetCode(EFFECT_MUST_ATTACK_MONSTER)
    e6:SetValue(s.atkval)
    c:RegisterEffect(e6)
    --(4)Destroy then damage
    local e7 = Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id, 0))
    e7:SetCategory(CATEGORY_DESTROY + CATEGORY_DAMAGE)
    e7:SetType(EFFECT_TYPE_IGNITION)
    e7:SetRange(LOCATION_MZONE)
    e7:SetCountLimit(1)
    e7:SetCost(s.descost)
    e7:SetTarget(s.destg)
    e7:SetOperation(s.desop)
    c:RegisterEffect(e7)
	--(5)Self Bomb
	local e8=Effect.CreateEffect(c)
    e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e8:SetCode(EVENT_SUMMON_SUCCESS)
    e8:SetOperation(s.regop)
    c:RegisterEffect(e8)
    local e9=e8:Clone()
    e9:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e9)
    local e10=e8:Clone()
    e10:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e10)
	local e11=Effect.CreateEffect(c)
    e11:SetDescription(aux.Stringid(id,1))
    e11:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE)
    e11:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e11:SetRange(LOCATION_MZONE)
    e11:SetCode(EVENT_PHASE+PHASE_END)
    e11:SetCountLimit(1)
    e11:SetCondition(s.gycon)
    e11:SetTarget(s.gytg)
    e11:SetOperation(s.gyop)
    c:RegisterEffect(e11)
end
--(1)Opponent's monsters must attack this card
function s.atkval(e, c)
    return c == e:GetHandler()
end
function s.descost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.CheckReleaseGroupCost(tp, nil, 2, false, nil, c) end    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
    local g = Duel.SelectReleaseGroupCost(tp, nil, 2, 2, false, nil, c)
    Duel.Release(g, REASON_COST)
end
function s.destg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, nil) end    
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_ONFIELD, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, e:GetHandler():GetAttack())
end
function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_ONFIELD, nil)
    if #g > 0 and Duel.Destroy(g, REASON_EFFECT) > 0 then
        local c = e:GetHandler()
        if c:IsRelateToEffect(e) and c:IsFaceup() then
            local atk = c:GetAttack()
            if atk > 0 then
                Duel.Damage(1 - tp, atk, REASON_EFFECT)
            end
        end
    end
end
--(5)Self Bomb
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,Duel.GetTurnCount())
end
function s.gycon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return Duel.GetTurnPlayer()==tp 
        and c:GetFlagEffect(id)>0 
        and c:GetFlagEffectLabel(id)~=Duel.GetTurnCount()
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local c=e:GetHandler()
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,c,1,0,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        if c:IsAbleToGrave() then
            Duel.SendtoGrave(c,REASON_EFFECT)
        else
            Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
        end
    end
end