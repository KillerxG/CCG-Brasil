--Shinigami
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--(1)Swap Curses
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--(2)Tribute
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_RELEASE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.reltg)
	e3:SetOperation(s.relop)
	c:RegisterEffect(e3)
	--(3)Force Activation
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_POSITION)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.target)
	e4:SetOperation(s.activate)
	c:RegisterEffect(e4)
end
--(1)Swap Curses
function s.thfilter(c,tp,e)
	return c:IsAbleToHand() and c:IsFacedown()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.thfilter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,0,LOCATION_SZONE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,0,LOCATION_SZONE,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.tffilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSetCard(0x304b) and not c:IsForbidden()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
		local g=Duel.SelectMatchingCard(tp,s.tffilter,tp,LOCATION_DECK,0,tp,tp,e,tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tf=Duel.SelectMatchingCard(tp,s.tffilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tf and Duel.MoveToField(tf,tp,1-tp,LOCATION_SZONE,POS_FACEUP,true) then
		end
	end
end
--(2)Tribute
function s.filter2(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsReleasableByEffect()
end
function s.reltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil) end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
function s.relop(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE+LOCATION_HAND,0,nil)
		if #mg>0 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			local sg=mg:Select(tp,1,1,nil)
			Duel.Release(sg,REASON_EFFECT)			
		end
end
--(3)Force Activation
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.filter(c,e,tp,eg,ep,ev,re,r,rp)
	local te=c:GetActivateEffect()
	if not te or not (te:IsActivatable(c:GetControler()) or c:IsStatus(STATUS_SET_TURN)) then return false end
	local condition=te:GetCondition()
	local cost=te:GetCost()
	local target=te:GetTarget()
	if te:GetCode()==EVENT_FREE_CHAIN then
		return (not condition or condition(te,c:GetControler(),eg,ep,ev,re,r,rp)) 
			and (not cost or cost(te,c:GetControler(),eg,ep,ev,re,r,rp,0))
			and (not target or target(te,c:GetControler(),eg,ep,ev,re,r,rp,0))
	elseif te:GetCode()==EVENT_CHAINING then
		return (not condition or condition(te,c:GetControler(),Group.FromCards(e:GetHandler()),tp,0,e,r,tp)) 
			and (not cost or cost(te,c:GetControler(),Group.FromCards(e:GetHandler()),tp,0,e,r,tp,0))
			and (not target or target(te,c:GetControler(),Group.FromCards(e:GetHandler()),tp,0,e,r,tp,0))
	else
		local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
		return res and (not condition or condition(te,c:GetControler(),teg,tep,tev,tre,tr,trp)) 
			and (not cost or cost(te,c:GetControler(),teg,tep,tev,tre,tr,trp,0))
			and (not target or target(te,c:GetControler(),teg,tep,tev,tre,tr,trp,0))
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
	local g=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.HintSelection(g)
		Duel.ChangePosition(tc,0,0,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE)
		if tc:IsLocation(LOCATION_SZONE) and s.filter(tc,e,tp,eg,ep,ev,re,r,rp) then
			local tpe=tc:GetType()
			local te=tc:GetActivateEffect()
			local tg=te:GetTarget()
			local co=te:GetCost()
			local op=te:GetOperation()
			Duel.ClearTargetCard()
			Duel.Hint(HINT_CARD,0,tc:GetCode())
			tc:CreateEffectRelation(te)
			if (tpe&TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 then
				tc:CancelToGrave(false)
			end
			if te:GetCode()==EVENT_FREE_CHAIN then
				if co then co(te,tc:GetControler(),eg,ep,ev,re,r,rp,1) end
				if tg then tg(te,tc:GetControler(),eg,ep,ev,re,r,rp,1) end
			elseif te:GetCode()==EVENT_CHAINING then
				if co then co(te,tc:GetControler(),Group.FromCards(c),tp,0,e,r,tp,1) end
				if tg then tg(te,tc:GetControler(),Group.FromCards(c),tp,0,e,r,tp,1) end
			else
				local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
				if co then co(te,tc:GetControler(),teg,tep,tev,tre,tr,trp,1) end
				if tg then tg(te,tc:GetControler(),teg,tep,tev,tre,tr,trp,1) end
			end
			Duel.BreakEffect()
			local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
			if g then
				local etc=g:GetFirst()
				while etc do
					etc:CreateEffectRelation(te)
					etc=g:GetNext()
				end
			end
			if te:GetCode()==EVENT_FREE_CHAIN then
				if op then op(te,tc:GetControler(),eg,ep,ev,re,r,rp) end
			elseif te:GetCode()==EVENT_CHAINING then
				if op then op(te,tc:GetControler(),Group.FromCards(c),tp,0,e,r,tp) end
			else
				local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
				if op then op(te,tc:GetControler(),teg,tep,tev,tre,tr,trp) end
			end
			if g and tc:IsType(TYPE_EQUIP) and not tc:GetEquipTarget() then
				Duel.Equip(tp,tc,g:GetFirst())
			end
			tc:ReleaseEffectRelation(te)
			if etc then	
				etc=g:GetFirst()
				while etc do
					etc:ReleaseEffectRelation(te)
					etc=g:GetNext()
				end
			end
		else
			Duel.ChangePosition(tc,POS_FACEDOWN,POS_FACEDOWN,0,0)
		end
	end
end