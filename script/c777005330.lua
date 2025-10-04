--Lydia, Demon Witch of the Starry Sky
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--Xyz Summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x254),9,2,s.ovfilter,aux.Stringid(id,0))
	c:EnableReviveLimit()
	--(1)Change positions and ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE|PHASE_BATTLE_START)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.DetachFromSelf(1))
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	--(2)Attach
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) end)
	e2:SetTarget(s.xyztg)
	e2:SetOperation(s.xyzop)
	c:RegisterEffect(e2)
end
--Xyz Summon
function s.ovfilter(c,tp,sc)
	return c:IsFaceup() and c:IsSetCard(SET_DDD,sc,SUMMON_TYPE_XYZ,tp)
end
function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsType(TYPE_FUSION,xyzc,SUMMON_TYPE_XYZ,tp) and c:IsSetCard(0x254,xyzc,SUMMON_TYPE_XYZ,tp)
end
--(1)Change positions and ATK/DEF
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetMatchingGroup(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,nil)
	if #tg>0 and Duel.ChangePosition(tg,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)>0 then
		local og=Duel.GetOperatedGroup():Filter(Card.IsFaceup,nil)
		for tc in aux.Next(og) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
			e2:SetValue(0)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
		if c:IsRelateToEffect(e) then
		--Set Link monster's ATK to 0
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,2))
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e3:SetRange(LOCATION_MZONE)
		e3:SetTargetRange(0,LOCATION_MZONE)
		e3:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_LINK))
		e3:SetValue(0)
		e3:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e3)
	end
end
--(2)Attach
function s.xyzfilter(c)
	return c:IsSetCard(0x254) and c:IsMonster() and c:IsFaceup()
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.xyzfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
	local g=Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_REMOVED,0,1,1,nil)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		Duel.Overlay(c,tc)
	end
end