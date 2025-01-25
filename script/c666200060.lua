--Noct Frost Jurmungandr
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x353),11,2,nil,nil,99)
	--(1)Banish it if detached
	aux.GlobalCheck(s,function()
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
		ge1:SetTargetRange(LOCATION_OVERLAY,LOCATION_OVERLAY)
		ge1:SetTarget(aux.TargetBoolFunction(Card.IsCode,id))
		ge1:SetValue(LOCATION_REMOVED)
		Duel.RegisterEffect(ge1,0)
	end)
	--(1)Unaffected
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.immval)
	c:RegisterEffect(e1)
	--(2)Apply one of these effects OR both of them
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	--(3)Shuffle banished cards
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+1)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e4)
	--(4)Register if it's Special Summoned with "Heart of Noct Frost"
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetOperation(s.regop)
	c:RegisterEffect(e5)
	--(5)Gain Effect of overlays
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_ADJUST)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(function(e) return e:GetHandler():HasFlagEffect(id) end)
	e6:SetOperation(s.copyop)
	c:RegisterEffect(e6)
end
--(1)Unaffected
function s.immval(e,re)
	local c=e:GetHandler()
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g or not g:IsContains(c)
end
--(2)Apply one of these effects OR both of them
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	local b2=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	local b3=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	if chk==0 then return (#b1>0 or #b2>0 or #b3>0) and Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT) end
	e:SetLabel(Duel.IsBattlePhase() and 1 or 0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,b1,#b1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,b2,#b2,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,b3,#b3,tp,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	local b2=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	local b3=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	local bp=e:GetLabel()==1
	local op=nil
	if not bp then
		op=Duel.SelectEffect(tp,
			{#b1>0 and Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT),aux.Stringid(id,1)},
			{#b2>0 and Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT),aux.Stringid(id,2)},
			{#b3>0 and Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT),aux.Stringid(id,3)})
	end
	local breakeffect=false
	if (op and op==1) or (bp and #b1>0 and (not (#b2>0 or #b3>0) or Duel.SelectYesNo(tp,aux.Stringid(id,1)))) then
		--Banish all other monsters on the field
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
		if #g>0 then
		Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_EFFECT)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		b2=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	end
		breakeffect=true
	end
	if (op and op==2) or (bp and #b2>0 and (not (breakeffect or #b3>0) or Duel.SelectYesNo(tp,aux.Stringid(id,2)))) then
		--Banish all S/T on the field
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_SZONE,LOCATION_SZONE,e:GetHandler())
		if #g>0 then
		Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_EFFECT)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		b3=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
		end
		breakeffect=true
	end
	if (op and op==3) or (bp and #b3>0 and (not breakeffect or Duel.SelectYesNo(tp,aux.Stringid(id,3)))) then
		--Banish all cards in both GYs
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,e:GetHandler())
		if #g>0 then
		Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_EFFECT)
		if breakeffect then Duel.BreakEffect() end
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
--(3)Shuffle banished cards
function s.filter(c)
	return c:IsAbleToDeck()
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,e:GetHandler()) end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
--(4)Register if it's Special Summoned with "Heart of Noct Frost"
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsCode(666200120) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~RESET_TEMP_REMOVE,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,5))
	end
end
--(5)Gain Effect of overlays
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetOverlayGroup():Filter(Card.IsType,nil,TYPE_XYZ+TYPE_LINK)
	g:Remove(s.codefilterchk,nil,e:GetHandler())
	if c:IsFacedown() or #g<=0 then return end
	repeat
		local tc=g:GetFirst()
		local code=tc:GetOriginalCode()
		local cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD,1)
		c:RegisterFlagEffect(code,RESET_EVENT+RESETS_STANDARD,0,0)
		local e0=Effect.CreateEffect(c)
		e0:SetCode(id)
		e0:SetLabel(code)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e0,true)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ADJUST)
		e1:SetRange(LOCATION_MZONE)
		e1:SetLabel(cid)
		e1:SetLabelObject(e0)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetOperation(s.resetop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
		g:Remove(s.codefilter,nil,code)
	until #g<=0
end
function s.codefilter(c,code)
	return c:IsOriginalCode(code) and c:IsType(TYPE_XYZ+TYPE_LINK)
end
function s.codefilterchk(c,sc)
	return sc:GetFlagEffect(c:GetOriginalCode())>0
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetOverlayGroup():Filter(Card.IsType,nil,TYPE_XYZ+TYPE_LINK)
	if not g:IsExists(s.codefilter,1,nil,e:GetLabelObject():GetLabel()) or c:IsDisabled() then
		c:ResetEffect(e:GetLabel(),RESET_COPY)
		c:ResetFlagEffect(e:GetLabelObject():GetLabel())
	end
end