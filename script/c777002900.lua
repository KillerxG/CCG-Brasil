--Azur Lane - Hyuuga
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--(2)Draw and discard
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.con)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end
--(1)Special Summon
function s.filter(c)
	return c:IsFaceup() and c:HasLevel() and c:IsSetCard(0x283)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_GRAVE)
	local lv1=g:GetFirst():GetLevel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	local lv=Duel.AnnounceLevel(tp,1,12,lv1)
	Duel.SetTargetParam(lv)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local lv2=e:GetHandler():GetLevel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)	
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	local c=e:GetHandler()
	--(1.1)Change Level
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(lv)
	tc:RegisterEffect(e1)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if not tc:IsImmuneToEffect(e1) and c:IsRelateToEffect(e) then
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) 
			and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil,lv2)then
			local tf=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),lv):GetFirst()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(tf:GetLevel())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
		end	
	end
end
--(2)Draw and discard
function s.con(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  return c:IsReason(REASON_COST) and re:IsHasType(0x7e0) and re:IsActiveType(TYPE_MONSTER)
  and c:IsPreviousLocation(LOCATION_OVERLAY) and re:GetHandler():IsSetCard(0x283)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local h1=Duel.Draw(tp,2,REASON_EFFECT)
	if h1>0 or h2>0 then Duel.BreakEffect() end
	local sealbool=false
	if h1>0 then
		Duel.ShuffleHand(tp)
		if Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)>0 then
			local dc=Duel.GetOperatedGroup():GetFirst()
			if dc:IsSetCard(0x283) then sealbool=true end
		end
	end
	if sealbool and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
	and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		local zone=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,0)
		if tp==1 then
				zone=((zone&0xffff)<<16)|((zone>>16)&0xffff)
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE_FIELD)
		e1:SetValue(zone)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		Duel.RegisterEffect(e1,tp)
	end
end