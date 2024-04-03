--Rockslash Dragon
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Special Summon this card (from your hand) by sending 1 card from your hand or field to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spproccon)
	e1:SetTarget(s.spproctg)
	e1:SetOperation(s.spprocop)
	c:RegisterEffect(e1)
	--(2)Burn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_ATKCHANGE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	--(3)Destroy 1 monster your opponent controls
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+2)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
--(1)Special Summon this card (from your hand) by sending 1 card from your hand or field to the GY
function s.tgfilter(c,tp,bool)
	local tg_check=nil
	if bool then
		tg_check=c:IsAbleToGrave() and c:IsSetCard(0x309)
	else
		tg_check=c:IsAbleToGraveAsCost() and c:IsSetCard(0x309)
	end
	return tg_check and Duel.GetMZoneCount(tp,c)>0
end
function s.spproccon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,c,tp,false)
	return #rg>0 and aux.SelectUnselectGroup(rg,e,tp,2,2,nil,0)
end
function s.spproctg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local rg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,c,tp,false)
	local g=aux.SelectUnselectGroup(rg,e,tp,2,2,nil,1,tp,HINTMSG_TOGRAVE,nil,nil,true)
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
--(2)Burn
function s.costfilter(c,tp)
	return c:IsMonster() and c:IsRace(RACE_ROCK) and c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,c)
end
function s.tdfilter(c)
	return c:IsSetCard(0x309) and c:IsMonster()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.HintSelection(g,true)
	if Duel.Remove(g,POS_FACEUP,REASON_COST)<1 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,1,2,nil)
	local val=0
	if #g>0 then
		Duel.HintSelection(g,true)
		local bc=g:GetFirst()
		for bc in g:Iter() do
			val=val+(bc:GetLevel()*200)
		end
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		Duel.Damage(p,val,REASON_EFFECT)
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e1)
	end
end
--(3)Destroy 1 monster your opponent controls
function s.dmgfilter(c)
	return c:IsSetCard(0x309) and c:IsFaceup()
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return r&REASON_EFFECT~=0 and ep~=tp
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if chk==0 then return #g>0 end
	local ebg=Duel.GetMatchingGroup(s.dmgfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	local dam=ebg:GetClassCount(Card.GetCode)*200
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tg=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	if #tg==0 then return end
	Duel.HintSelection(tg,true)
	if Duel.Destroy(tg,REASON_EFFECT)>0 then
		local g=Duel.GetMatchingGroup(s.dmgfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
		if #g==0 then return end
		local dam=g:GetClassCount(Card.GetCode)*200
		Duel.BreakEffect()
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end