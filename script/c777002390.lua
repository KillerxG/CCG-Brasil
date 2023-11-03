--Northern Guild - Yorika
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Special Summon this card from your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--(2)Special Summon or attach a "Northern Guild"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.atcon)
	e2:SetTarget(s.attg)
	e2:SetOperation(s.atop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
	--(3)Unaffected by monsters
	local e4a=Effect.CreateEffect(c)
	e4a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4a:SetCode(EVENT_CHAIN_SOLVING)
	e4a:SetRange(LOCATION_MZONE)
	e4a:SetOperation(s.immop)
	c:RegisterEffect(e4a)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.immcon)
	e4:SetValue(s.immval)
	e4:SetLabelObject(e4a)
	c:RegisterEffect(e4)
end
--(1)Special Summon this card from your hand
function s.atkfilter(c)
	return c:IsFaceup() and c:GetAttack()~=c:GetBaseAttack()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
--(2)Special Summon or attach a "Northern Guild"
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_XYZ) and c:IsPreviousLocation(LOCATION_OVERLAY)
end
function s.gepdfilter(c,e,tp,ft)
	return c:IsSetCard(0x280) and c:IsMonster() and ((ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
		or Duel.IsExistingMatchingCard(s.attfilter,tp,LOCATION_MZONE,0,1,nil,e))
end
function s.attfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and not c:IsImmuneToEffect(e)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return Duel.IsExistingMatchingCard(s.gepdfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp,ft) end
	e:SetLabel(Duel.IsBattlePhase() and 1 or 0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
function s.numbfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x280)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local tc=Duel.SelectMatchingCard(tp,s.gepdfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp,ft):GetFirst()
	if not tc then return end
	local spchk=ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	local attchk=Duel.IsExistingMatchingCard(s.attfilter,tp,LOCATION_MZONE,0,1,nil,e)
	if not (spchk or attchk) then return end
	local op=Duel.SelectEffect(tp,
		{spchk,aux.Stringid(id,2)},
		{attchk,aux.Stringid(id,3)})
	local success_chk=nil
	if op==1 and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		success_chk=true
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local oc=Duel.SelectMatchingCard(tp,s.attfilter,tp,LOCATION_MZONE,0,1,1,nil,e):GetFirst()
		if oc then
			success_chk=true
			Duel.HintSelection(oc,true)
			Duel.Overlay(oc,tc)
		end
	end
	local ng=Duel.GetMatchingGroup(s.numbfilter,tp,LOCATION_MZONE,0,1,nil)
	if success_chk and e:GetLabel()==1 and #ng>0 then
		local c=e:GetHandler()
		Duel.BreakEffect()
		for sc in ng:Iter() do
			--Increase ATK
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(sc:GetAttack()*2)
			sc:RegisterEffect(e1)
		end
	end
end
--(3)Unaffected by monsters
function s.immcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,777002610),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.immop(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(e:GetHandler():GetAttack())
end
function s.immval(e,te)
	if te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_MONSTER) then
		local atk=e:GetLabelObject():GetLabel()
		local tc=te:GetHandler()
		if tc:GetRank()>0 then
			return tc:GetAttack()<atk
		elseif tc:HasLevel() then
			return tc:GetAttack()<atk
		elseif tc:GetLink()>0 then
			return tc:GetAttack()<atk
		else return false end
	else return false end
end