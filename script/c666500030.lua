--Biker.lua
--Scripted by Imp
local s,id=GetID()
function s.initial_effect(c)
	--Extra Link Material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetRange(LOCATION_HAND)
	e0:SetCode(EFFECT_EXTRA_MATERIAL)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetTargetRange(1,0)
	e0:SetOperation(s.extracon)
	e0:SetValue(s.extraval)
	c:RegisterEffect(e0)
	if s.flagmap==nil then
		s.flagmap={}
	end
	if s.flagmap[c]==nil then
		s.flagmap[c]={}
	end
    --Link Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return r&REASON_LOST_TARGET==0 end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCondition(s.condition)
	c:RegisterEffect(e3)
end
--Extra Link Material
function s.extrafilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
function s.extracon(c,e,tp,sg,mg,lc,og,chk)
	return sg:FilterCount(Card.HasFlagEffect,nil,id)<2 and (sg+mg):IsExists(s.extrafilter,1,og,e:GetHandlerPlayer())
end
function s.extraval(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or not sc:IsSetCard(0x660) or Duel.GetFlagEffect(tp,id)>0 then
			return Group.CreateGroup()
		else
			table.insert(s.flagmap[c],c:RegisterFlagEffect(id,0,0,1))
			return Group.FromCards(c)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_LINK == SUMMON_TYPE_LINK and #sg>0 then
			Duel.Hint(HINT_CARD,tp,id)
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		end
	elseif chk==2 then
		for _,eff in ipairs(s.flagmap[c]) do
			eff:Reset()
		end
		s.flagmap[c]={}
	end
end
--Link Summon
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return r&REASON_LOST_TARGET==0 and r==REASON_LINK
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local op=Duel.SelectEffect(tp,
			{true,aux.Stringid(id,1)},
			{tc:IsAbleToHand(),aux.Stringid(id,2)})
		if op==1 then
			Duel.Destroy(tc,REASON_EFFECT)
		else
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
