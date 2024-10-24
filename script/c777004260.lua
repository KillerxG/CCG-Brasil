--Ghost Hunter - Blake
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,1,id)
	--Fusion Summon
	local eff=Fusion.AddProcMixN(c,true,true,s.ffilter,3)
	if not c:IsStatus(STATUS_COPYING_EFFECT) then
		eff[1]:SetValue(s.matfilter)
	end
	--(1)Each player pays LP to Special from GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_MZONE) 
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	--(1.1)Each player pays LP to Special from GY
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(id)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	c:RegisterEffect(e3)
	--(2)Recover
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_RECOVER)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCountLimit(1)
	e4:SetCondition(s.reccon)
	e4:SetTarget(s.rectg)
	e4:SetOperation(s.recop)
	c:RegisterEffect(e4)
end
--Fusion Summon
function s.ffilter(c,fc,sumtype,tp,sub,mg,sg)
	return c:IsRace(RACE_WARRIOR,fc,sumtype,tp) and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetCode(fc,sumtype,tp),fc,tp))
end
function s.fusfilter(c,code,fc,tp)
	return c:IsSummonCode(fc,SUMMON_TYPE_FUSION,tp,code) and not c:IsHasEffect(511002961)
end
function s.matfilter(c,fc,sub,sub2,mg,sg,tp,contact,sumtype)
	if sumtype&SUMMON_TYPE_FUSION~=0 and fc:IsLocation(LOCATION_EXTRA) and not contact then
		return c:IsLocation(LOCATION_ONFIELD+LOCATION_HAND) and c:IsControler(tp)
	end
	return true
end
--(1)Each player pays LP to Special from GY
function s.filter(c)
	return c:GetFlagEffect(id)==0
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filter,0,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SPSUMMON_COST)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCost(s.costchk)
		e1:SetOperation(s.costop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
		e4:SetCode(EVENT_ADJUST)
		e4:SetRange(LOCATION_GRAVE)
		e4:SetLabelObject(e3)
		e4:SetOperation(s.resetop)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e4)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
function s.costchk(e,c,tp)
	local atk=c:GetAttack()
	e:SetLabel(atk)
	return Duel.IsPlayerAffectedByEffect(c:GetControler(),id) and Duel.CheckLPCost(c:GetControler(),atk)
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.PayLPCost(c:GetControler(),e:GetLabel())
	e:SetLabel(0)
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerAffectedByEffect(tp,id) then
		local e3=e:GetLabelObject()
		local e2=e3:GetLabelObject()
		local e1=e2:GetLabelObject()
		e:Reset()
		e1:Reset()
		e2:Reset()
		e3:Reset()
		e:GetHandler():ResetFlagEffect(id)
	end
end
--(2)Recover
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsRace,RACE_ALL),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ct*500)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct*500)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsRace,RACE_ALL),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.Recover(tp,ct*500,REASON_EFFECT)
end