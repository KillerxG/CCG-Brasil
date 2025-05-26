--Sparkling Angel of Inquisition
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	c:EnableReviveLimit()
	--Synchro Summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99,s.matfilter)
	--(1)Cannot be targeted by effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_EMZONE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--(2)Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
	--(3)Change the levels of monsters
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_LVCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetTarget(s.lvtg)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)
end
--Synchro Summon
function s.matfilter(c,scard,sumtype,tp)
	return c:IsLevelAbove(5,scard,sumtype,tp)
end
--(2)Special Summon
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
function s.filter(c,e,tp,ft)
	local lv=c:GetOriginalLevel()
	return lv>0 and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c) and (ft>0 or c:GetSequence()<5)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,lv)
end
function s.spfilter(c,e,tp,lv)
	return c:IsType(TYPE_TUNER) and c:GetLevel()==lv and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return ft>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,e,tp,ft)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil,e,tp,ft)
	e:SetLabel(g:GetFirst():GetOriginalLevel())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,lv)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1,fid)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.descon)
		e1:SetOperation(s.desop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
--(3)Change the levels of monsters
function s.lvfilter(c,e)
	return c:HasLevel() and c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsType,1,nil,TYPE_TUNER)
end
s.nlvfilter=aux.NOT(Card.IsLevel)
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local gg=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_MZONE,0,nil,e)
	if chk==0 then return aux.SelectUnselectGroup(gg,e,tp,2,2,s.rescon,0) end
	local g1,g2=gg:Split(Card.IsType,nil,TYPE_TUNER)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	local lv=Duel.AnnounceNumber(tp,s.get_declarable_levels(g1,g2))
	local g=gg:Match(s.nlvfilter,nil,lv)
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(tg)
	e:SetLabel(lv)
	Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,tg,2,tp,lv)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e):Filter(Card.IsFaceup,nil)
	if #tg==0 then return end
	local lv=e:GetLabel()
	for tc in tg:Iter() do
		if not tc:IsLevel(lv) then
			--Its Level becomes the declared Level
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
function s.get_declarable_levels(g1,g2)
	local opts={}
	for lv=2,5 do
		local ct=g1:FilterCount(s.nlvfilter,nil,lv)
		if ct>1 or (ct>0 and g2:IsExists(s.nlvfilter,1,nil,lv)) then
			table.insert(opts,lv)
		end
	end
	return table.unpack(opts)
end