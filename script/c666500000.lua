--Champion.lua
--Scripted by Imp
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	--Link Summon Procedure
	Link.AddProcedure(c,nil,2,2,s.lcheck)
	--Link Up
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_UPDATE_LINK)
	e0:SetRange(LOCATION_EMZONE)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LINK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return (e:GetHandler():GetSequence()==1 or e:GetHandler():GetSequence()==3) end)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Bottom Link Marker
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ADD_LINKMARKER)
	e2:SetRange(LOCATION_EMZONE)
	e2:SetValue(LINK_MARKER_BOTTOM)
	c:RegisterEffect(e2)
	--Top Link Marker
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_ADD_LINKMARKER)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(function(e) return (e:GetHandler():GetSequence()==1 or e:GetHandler():GetSequence()==3) end)
	e3:SetValue(LINK_MARKER_TOP)
	c:RegisterEffect(e3)
	--Unaffected
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(function() return Duel.IsMainPhase() end)
	e4:SetTarget(s.immtg)
	e4:SetValue(s.immval)
	c:RegisterEffect(e4)
    --Destroy 
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,1})
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
end
--Link Summon Procedure
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0x660,lc,sumtype,tp)
end
--Unaffected
function s.immtg(e,c)
	return c:IsLinked() and c:IsSetCard(0x660)
end
function s.immval(e,te)
	return te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and te:IsActivated()
end
--Destroy
function s.desctfilter(c)
	return c:GetMutualLinkedGroupCount()>0
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	if chk==0 then return #dg>0 and Duel.IsExistingMatchingCard(s.desctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(s.desctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if ct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end