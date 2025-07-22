--Xyz Universal Level
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--(1)Change Level
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--(2)Attach 1 card from the GY to a Xyz Monster you control
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.mattg)
	e2:SetOperation(s.matop)
	c:RegisterEffect(e2)
end
--(1)Change Level
function s.spfilter(c)
	return c:IsType(TYPE_XYZ)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	e:SetLabelObject(g:GetFirst())
end
function s.filter1(c,tp)
	return c:IsLevelAbove(1) and Duel.IsExistingTarget(s.filter2,tp,LOCATION_MZONE,0,1,c,c:GetRace())
end
function s.filter2(c,rac)
	return c:IsLevelAbove(1) and c:IsRace(rac)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g1=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,g1:GetFirst(),g1:GetFirst():GetRace())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	if tc1:IsRelateToEffect(e) and tc1:IsFaceup() and tc2:IsRelateToEffect(e) and tc2:IsFaceup() then
		local lv=e:GetLabelObject():GetRank()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL_FINAL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc1:RegisterEffect(e1)
		local e2=e1:Clone()
		tc2:RegisterEffect(e2)
	end
end
--(2)Attach 1 card from the GY to a Xyz Monster you control
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.atchfilter(c,tp)
	return c:IsControler(tp) or c:IsAbleToChangeControler()
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.xyzfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(s.atchfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,e:GetHandler(),tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local xyzc=Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	e:SetLabelObject(xyzc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
	local tc=Duel.SelectTarget(tp,s.atchfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,e:GetHandler(),tp)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	if #g~=2 then return end
	local tc=g:GetFirst()
	local xyzc=g:GetNext()
	if tc==e:GetLabelObject() then tc,xyzc=xyzc,tc end
	Duel.Overlay(xyzc,tc)
end