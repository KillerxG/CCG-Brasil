--Administrator.lua
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
    --Attack Directly
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.target)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(s.target)
	e5:SetCondition(s.condition)
	e5:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e5)
	--Link Summon
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e6:SetCountLimit(1,{id,1})
	e6:SetRange(LOCATION_MZONE)
	e6:SetCost(s.lkcost)
	e6:SetTarget(s.lktg)
	e6:SetOperation(s.lkop)
	c:RegisterEffect(e6)
end
--Link Summon Procedure
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0x660,lc,sumtype,tp)
end
--Attack Directly 
function s.target(e,c)
	return c:IsLinked() and c:IsSetCard(0x660)
end
function s.condition(e)
	local tp=e:GetHandlerPlayer()
	local c=Duel.GetAttacker()
	return Duel.GetAttackTarget()==nil and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 --if there are 0 monsters, it's not attacking directly using this effect
end
--Link Summon
function s.rmfilter(c)
	return c:IsMonster() and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true,false)
end
function s.lkfilter(c,e,tp,ct,g)
	return c:IsSetCard(0x660) and c:IsType(TYPE_LINK) and c:IsLink(ct)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false,POS_FACEUP)
		and Duel.GetLocationCountFromEx(tp,tp,g,c)>0
end
function s.lkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	local nums={}
	for i=1,#g do
		if Duel.IsExistingMatchingCard(s.lkfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,i,g) then
			table.insert(nums,i)
		end
	end
	if chk==0 then return #nums>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	local ct=Duel.AnnounceNumber(tp,table.unpack(nums))
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=g:Select(tp,ct,ct,nil)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	e:SetLabel(ct)
end
function s.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	if not ct then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.lkfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,ct):GetFirst()
	if tc and Duel.SpecialSummon(tc,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)>0 then
		tc:CompleteProcedure()
	end
end