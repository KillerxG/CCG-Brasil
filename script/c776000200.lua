--The Winged Dragon of Ra
--Scripted by KillerxG
local s,id=GetID()
Duel.LoadScript("proc_divine_hierarchy_mod.lua")
function s.initial_effect(c)	
	--Divine Hierarchy Rank 2
	DivineHierarchyMod.Register(c,2)
	--You can only control 1
	c:SetUniqueOnField(1,0,10000010)
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
	
	--(4)Tribute check
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE)
	e9:SetCode(EFFECT_MATERIAL_CHECK)
	e9:SetValue(s.valcheck)
	c:RegisterEffect(e9)
	--(5)give atk effect only when summon
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_SINGLE)
	e10:SetCode(EFFECT_SUMMON_COST)
	e10:SetOperation(s.facechk)
	e10:SetLabelObject(e9)
	c:RegisterEffect(e10)
	--(6)Destroy opponent's monster
	local e11 = Effect.CreateEffect(c)
    e11:SetDescription(aux.Stringid(id, 2))
    e11:SetCategory(CATEGORY_DESTROY)
    e11:SetType(EFFECT_TYPE_IGNITION)
    e11:SetRange(LOCATION_MZONE)
    e11:SetCountLimit(1)
    e11:SetCost(s.descost)
    e11:SetTarget(s.destg)
    e11:SetOperation(s.desop)
    c:RegisterEffect(e11)
	--(7)Tribute monsters to gain ATK
    local e12 = Effect.CreateEffect(c)
    e12:SetDescription(aux.Stringid(id, 3))
    e12:SetCategory(CATEGORY_ATKCHANGE)
    e12:SetType(EFFECT_TYPE_QUICK_O)
    e12:SetCode(EVENT_FREE_CHAIN)
    e12:SetRange(LOCATION_MZONE)
    e12:SetHintTiming(0, TIMING_BATTLE_START + TIMING_BATTLE_END)
    e12:SetCountLimit(1)
    e12:SetCondition(s.atkcon1)
    e12:SetCost(s.atkcost1)
    e12:SetOperation(s.atkop1)
    c:RegisterEffect(e12)
	--(8)Convert LP to ATK
    local e13 = Effect.CreateEffect(c)
    e13:SetDescription(aux.Stringid(id, 4))
    e13:SetCategory(CATEGORY_ATKCHANGE)
    e13:SetType(EFFECT_TYPE_IGNITION)
    e13:SetRange(LOCATION_MZONE)
    e13:SetCountLimit(1)
    e13:SetCost(s.atkcost2)
    e13:SetOperation(s.atkop2)
    c:RegisterEffect(e13)
end

--(4)Tribute check
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local tc=g:GetFirst()
	local atk=0
	local def=0
	while tc do
		local catk=tc:GetTextAttack()
		local cdef=tc:GetTextDefense()
		atk=atk+(catk>=0 and catk or 0)
		def=def+(cdef>=0 and cdef or 0)
		tc=g:GetNext()
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE-RESET_TOFIELD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		e2:SetValue(def)
		c:RegisterEffect(e2)
	end
end
--(5)give atk effect only when summon
function s.facechk(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(1)
end
--(6)Destroy opponent's monster
function s.descost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 1000) end
    Duel.PayLPCost(tp, 1000)
end
function s.destg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(nil, tp, 0, LOCATION_MZONE, 1, nil) end
    local g = Duel.GetMatchingGroup(nil, tp, 0, LOCATION_MZONE, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end
function s.desop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectMatchingCard(tp, nil, tp, 0, LOCATION_MZONE, 1, 1, nil)
    if #g > 0 then
        Duel.Destroy(g, REASON_EFFECT)
    end
end
--(7)Tribute monsters to gain ATK
function s.atkcon1(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsBattlePhase()
end
function s.atkcost1(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.CheckReleaseGroupCost(tp, nil, 1, false, nil, c) end    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
    local g = Duel.SelectReleaseGroupCost(tp, nil, 1, 99, false, nil, c)
    local atk_sum = 0
    for tc in aux.Next(g) do
        local tatk = tc:GetAttack()
        if tatk < 0 then tatk = 0 end
        atk_sum = atk_sum + tatk
    end
    e:SetLabel(atk_sum)
    Duel.Release(g, REASON_COST)
end
function s.atkop1(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local val = e:GetLabel()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(val)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e1)
    end
end
--(8)Convert LP to ATK
function s.atkcost2(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLP(tp) > 100 end
    local lp = Duel.GetLP(tp)
    local pay = lp - 100
    e:SetLabel(pay)
    Duel.PayLPCost(tp, pay)
end
function s.atkop2(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local val = e:GetLabel()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(val)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e1)
    end
end