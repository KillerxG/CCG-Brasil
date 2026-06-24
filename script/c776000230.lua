--Uria, Lord of Searing Flames
--Scripted by KillerxG
local s,id=GetID()
Duel.LoadScript("proc_divine_hierarchy_mod.lua")
function s.initial_effect(c)	
	--Divine Hierarchy Rank 2
	DivineHierarchyMod.Register(c,2)
	--Cannot be Normal Summoned/Set
	c:EnableReviveLimit()
	--You can only control 1
	c:SetUniqueOnField(1,0,id)
	--(1)Cannot Special Summon except by its own Effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	--(2)Special Summon itself from hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--(3)Gains 1000 ATK/DEF for each Trap in the GYs
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_SINGLE)
	e3a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3a:SetCode(EFFECT_UPDATE_ATTACK)
	e3a:SetRange(LOCATION_MZONE)
	e3a:SetValue(function(e,c) return 1000*Duel.GetMatchingGroupCount(Card.IsTrap,0,LOCATION_GRAVE,LOCATION_GRAVE,nil) end)
	c:RegisterEffect(e3a)
	local e3b=e3a:Clone()
	e3b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3b)
	--(4)Destroy S/T
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	e4:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E|TIMING_SSET)
	c:RegisterEffect(e4)
	
	--(6)Revive
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e9:SetCode(EVENT_TO_GRAVE)
	e9:SetOperation(s.spr)
	c:RegisterEffect(e9)
end
--(2)Special Summon itself from hand
function s.spfilter(c,tp)
	return c:IsTrap() and c:IsAbleToGraveAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD,0,nil)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-3 and #g>2 and aux.SelectUnselectGroup(g,e,tp,3,3,aux.ChkfMMZ(1),0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD,0,nil)
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
--(4)Destroy S/T
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsSpellTrap() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	Duel.SetChainLimit(aux.FALSE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

--(6)Revive
function s.spr(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ph=Duel.GetCurrentPhase()
	if not c:IsReason(REASON_BATTLE+REASON_EFFECT) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	if Duel.IsTurnPlayer(tp) and ph==PHASE_MAIN1 then
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(s.risecon2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_MAIN1+RESET_SELF_TURN,2)
	else
		e1:SetCondition(s.risecon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_MAIN1+RESET_SELF_TURN,1)
	end
	e1:SetCost(s.risecost)
	e1:SetTarget(s.risetarget)
	e1:SetOperation(s.riseop)
	c:RegisterEffect(e1)
end
function s.trapfilter(c)
	return c:IsTrap() and c:IsDiscardable()
end
function s.risecon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY)
end
function s.risecon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) and Duel.GetTurnCount()~=e:GetLabel()
end
function s.risecost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.trapfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,s.trapfilter,1,1,REASON_COST+REASON_DISCARD)
end
function s.risetarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,1,tp,true,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.atcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)>1
end
function s.riseop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,1,tp,tp,true,false,POS_FACEUP)>0 then
		
	end
end