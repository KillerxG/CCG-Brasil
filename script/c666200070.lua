--Noct Frost Kraken
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x353),7,2,nil,nil,99)
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
	--(2)Cannot attack other "Noct Frost" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetValue(s.atlimit)
	c:RegisterEffect(e1)
	--(3)Cannot target with effects other "Noct Frost" monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.tgtg)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--(4)Change Battle Target
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.cbcon)
	e3:SetCost(s.cbcost)
	e3:SetTarget(s.cbtg)
	e3:SetOperation(s.cbop)
	c:RegisterEffect(e3)
	--(5)Change Effect Target
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.cecon)
	e4:SetCost(s.cecost)
	e4:SetTarget(s.cetg)
	e4:SetOperation(s.ceop)
	c:RegisterEffect(e4)
	--(6)Special Summon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCountLimit(1,id+1)
	e5:SetTarget(s.xyztg)
	e5:SetOperation(s.xyzop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e6)
	--(7)Register if it's Special Summoned with "Heart of Noct Frost"
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	e7:SetOperation(s.regop)
	c:RegisterEffect(e7)
	--(8)Gain Effect of overlays
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_ADJUST)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCondition(function(e) return e:GetHandler():HasFlagEffect(id) end)
	e8:SetOperation(s.copyop)
	c:RegisterEffect(e8)
end
--(2)Cannot attack other "Noct Frost" monsters
function s.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x353) and c~=e:GetHandler()
end
--(3)Cannot target with effects other "Noct Frost" monsters
function s.tgtg(e,c)
	return c~=e:GetHandler() and c:IsSetCard(0x353)
end
--(4)Change Battle Target
function s.cbcon(e,tp,eg,ep,ev,re,r,rp)
	return r~=REASON_REPLACE
end
function s.cbcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_COST) end
	Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_COST)
end
function s.cbfilter(c,at)
	return c:IsFaceup() and at:IsContains(c)
end
function s.cbtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local at=Duel.GetAttacker():GetAttackableTarget()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cbfilter(chkc,at) end
	if chk==0 then return Duel.IsExistingTarget(s.cbfilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),at) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.cbfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),at)
end
function s.cbop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and not Duel.GetAttacker():IsImmuneToEffect(e) then
		Duel.ChangeAttackTarget(tc)
	end
end
--(5)Change Effect Target
function s.cecon(e,tp,eg,ep,ev,re,r,rp)
	if e==re or rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and #g==1 and g:GetFirst()==e:GetHandler()
end
function s.cecost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_COST) end
	Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_COST)
end
function s.cefilter(c,ct)
	return c:IsFaceup() and Duel.CheckChainTarget(ct,c)
end
function s.cetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cefilter(chkc,ev) end
	if chk==0 then return Duel.IsExistingTarget(s.cefilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),ev) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.cefilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),ev)
end
function s.ceop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.ChangeTargetCard(ev,Group.FromCards(tc))
	end
end
--(6)Special Summon
function s.matfilter(c,e)
  return c:IsFaceup() and c:IsLevel(1) and c:IsSetCard(0x353) and c:IsCanBeEffectTarget(e)
end
function s.xyzfilter(c,e,tp)
  return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x353) and c:IsRank(9) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.rescon(sg,e,tp,mg)
  return sg:GetClassCount(Card.GetCode)==#sg
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return false end
  local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.matfilter),tp,LOCATION_REMOVED+LOCATION_GRAVE,0,nil,e)
  if chk==0 then return Duel.GetLocationCountFromEx(tp)>0 and aux.SelectUnselectGroup(tg,e,tp,1,99,nil,0)
  and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
  local g=aux.SelectUnselectGroup(tg,e,tp,1,99,nil,1,tp,HINTMSG_TARGET)
  Duel.SetTargetCard(g)
  e:SetLabel(#g)
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if Duel.GetLocationCountFromEx(tp)<=0 then return end
  local mat=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
  local ct=e:GetLabel()
  if mat:GetCount()~=ct then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
  local tc=g:GetFirst()
  if tc and Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
    Duel.Overlay(tc,mat+c)
    tc:CompleteProcedure()
  end
end
--(7)Register if it's Special Summoned with "Heart of Noct Frost"
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsCode(666200120) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~RESET_TEMP_REMOVE,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
	end
end
--(8)Gain Effect of overlays
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