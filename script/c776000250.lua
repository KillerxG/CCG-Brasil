--Hamon, Lord of Striking Thunder
--Scripted by KillerxG
local s,id=GetID()
Duel.LoadScript("proc_divine_hierarchy_mod.lua")
function s.initial_effect(c)	
	--Divine Hierarchy Rank 1
	DivineHierarchyMod.Register(c,1)
	--Cannot be Normal Summoned/Set
	c:EnableReviveLimit()
	--You can only control 1
	c:SetUniqueOnField(1,0,id)
	--(1)Cannot Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	--(2)Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)	
	--(3)Limit batlle target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetCondition(s.atcon)
	e3:SetValue(s.atlimit)
	c:RegisterEffect(e3)
	--(4)Inflict 1000 damage to your opponent
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.damcon)
	e4:SetTarget(s.damtg)
	e4:SetOperation(s.damop)
	c:RegisterEffect(e4)
	--(5)Self Bomb
	local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e5:SetCode(EVENT_SUMMON_SUCCESS)
    e5:SetOperation(s.regop)
    c:RegisterEffect(e5)
    local e6=e5:Clone()
    e6:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e6)
    local e7=e5:Clone()
    e7:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e7)
	local e8=Effect.CreateEffect(c)
    e8:SetDescription(aux.Stringid(id,1))
    e8:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE)
    e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e8:SetRange(LOCATION_MZONE)
    e8:SetCode(EVENT_PHASE+PHASE_END)
    e8:SetCountLimit(1)
    e8:SetCondition(s.gycon)
    e8:SetTarget(s.gytg)
    e8:SetOperation(s.gyop)
    c:RegisterEffect(e8)
	--(6)Attack in defense
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE)
	e9:SetCode(EFFECT_DEFENSE_ATTACK)
	e9:SetValue(1)
	c:RegisterEffect(e9)
end
--(2)Special Summon
function s.spfilter(c)
	return c:IsSpell() and c:IsAbleToGraveAsCost() and not c:IsType(TYPE_FIELD)
end
function s.exfilter(c)
	return s.spfilter(c) or (c:IsFacedown() and (c:IsSpell() and not c:IsType(TYPE_FIELD)) and c:IsAbleToGraveAsCost())
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=nil
	if Duel.IsPlayerAffectedByEffect(tp,54828837) then
		g=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_ONFIELD,0,nil)
	else
		g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD,0,nil)
	end
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-3 and #g>2 and aux.SelectUnselectGroup(g,e,tp,3,3,aux.ChkfMMZ(1),0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local g=nil
	if Duel.IsPlayerAffectedByEffect(tp,54828837) then
		g=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_ONFIELD,0,nil)
	else
		g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD,0,nil)
	end
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,aux.ChkfMMZ(1),1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	local dg=sg:Filter(Card.IsFacedown,nil)
	if #dg>0 then
		Duel.ConfirmCards(1-tp,dg)
	end
	if #sg==3 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
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
--(3)Limit batlle target
function s.atcon(e)
	return e:GetHandler():IsDefensePos()
end
function s.atlimit(e,c)
	return c~=e:GetHandler()
end
--(4)Inflict 1000 damage to your opponent
function s.damconfilter(c,opp)
	return c:IsMonster() and c:IsControler(opp)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.damconfilter,1,nil,1-tp)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,1,tp,1-tp,1000)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	Duel.Damage(1-tp,d,REASON_EFFECT)
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