--Butterfly Lady - Tsukiko
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--Xyz Summon
	Xyz.AddProcedure(c,nil,6,2,s.ovfilter,aux.Stringid(id,4))
	c:EnableReviveLimit()
	--(1)This card gains 200 ATK for each monster on the field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	--(2)Negate an attack and make this card gain ATK equal to the attacking monster's until the end of the turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(Cost.DetachFromSelf(1))
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	--(3)Draw 1 card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
--Xyz Summon
function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL,xyzc,SUMMON_TYPE_XYZ,tp)
end
--(1)This card gains 200 ATK for each monster on the field
function s.value(e,c)
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsType,TYPE_MONSTER),0,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())*200
end
--(2)Negate an attack and make this card gain ATK equal to the attacking monster's until the end of the turn
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ac=Duel.GetAttacker()
	if chkc then return chkc==ac end
	if chk==0 then return ac:IsOnField() and ac:IsCanBeEffectTarget(e) end
	Duel.SetTargetCard(ac)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,ac,1,tp,0)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetAttacker()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.NegateAttack() and c:IsRelateToEffect(e) and c:IsFaceup() then
		local atk=tc:GetAttack()
		if atk<=0 then return end
		local prev_atk=c:GetAttack()
		--This card gains ATK equal to that monster's until the end of this turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
		c:RegisterEffect(e1)
		Duel.AdjustInstantly(c)
		if prev_atk>=c:GetAttack() then return end
		if tc:IsAbleToHand() and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
--(3)Draw 1 card
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end