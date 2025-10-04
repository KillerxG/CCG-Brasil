--Warrior Reaper - Sophia
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--(1)Special Summon itself
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spproccon)
	e1:SetTarget(s.spproctg)
	e1:SetOperation(s.spprocop)
	c:RegisterEffect(e1)
	--(2)Synchro Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_BATTLE_END)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.synchtg)
	e2:SetOperation(s.synchop)
	c:RegisterEffect(e2)
	--(3)Effect Gain: You can activate "Majin Reaper" Continuous Trap the turn they are Set
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return (r&REASON_SYNCHRO)==REASON_SYNCHRO and e:GetHandler():GetReasonCard():IsCode(777004920) end)
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)
end
--(1)Special Summon itself
function s.tgfilter(c,tp,bool)
	local tg_check=nil
	if bool then
		tg_check=c:IsAbleToGrave() and c:IsTrap()
	else
		tg_check=c:IsAbleToGraveAsCost() and c:IsTrap()
	end
	return tg_check and Duel.GetMZoneCount(tp,c)>0
end
function s.spproccon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,c,tp,false)
	return #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,nil,0)
end
function s.spproctg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local rg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,c,tp,false)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,nil,1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spprocop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST)
	g:DeleteGroup()
end
--(2)Synchro Summon
function s.synchtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.synchop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
--(3)Effect Gain: You can activate "Majin Reaper" Continuous Trap the turn they are Set
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	--(3.1)You can activate "Majin Reaper" Continuous Trap the turn they are Set
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetTarget(function(e,c) return c:IsSetCard(0x258) and c:IsContinuousTrap() end)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	--(3.2)Add type effect
	if not rc:IsType(TYPE_EFFECT) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
	rc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
end