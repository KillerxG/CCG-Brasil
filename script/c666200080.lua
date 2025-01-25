--Noct Frost Pirarucu
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x353),3,2,nil,nil,99)
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
	--(2)Redirect destroyed monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)
	--(3)Search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e3)
	--(4)Special Summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,id+1)
	e4:SetTarget(s.xyztg)
	e4:SetOperation(s.xyzop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e5)
	--(5)Register if it's Special Summoned with "Heart of Noct Frost"
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	e7:SetOperation(s.regop)
	c:RegisterEffect(e7)
	--(6)Gain Effect of overlays
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_ADJUST)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCondition(function(e) return e:GetHandler():HasFlagEffect(id) end)
	e8:SetOperation(s.copyop)
	c:RegisterEffect(e8)
end
--(3)Search
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_COST) end
	Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_COST)
end
function s.thfilter(c)
	return c:IsSetCard(0x353) and c:IsFaceup() and c:IsAbleToHand() and not c:IsCode(id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--(4)Special Summon
function s.matfilter(c,e)
  return c:IsFaceup() and c:IsLevel(1) and c:IsSetCard(0x353) and c:IsCanBeEffectTarget(e)
end
function s.xyzfilter(c,e,tp)
  return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x353) and c:IsRank(5) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
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
--(5)Register if it's Special Summoned with "Heart of Noct Frost"
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsCode(666200120) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~RESET_TEMP_REMOVE,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
	end
end
--(6)Gain Effect of overlays
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