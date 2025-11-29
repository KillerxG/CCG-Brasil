--Magician Girl Redirect
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--(1)Can be activated from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e1:SetCondition(s.actcon)
	c:RegisterEffect(e1)
	--(2)Redirect damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
	--(3)Destroy cards your opponent controls, up to the number of "Dark Magician Girl" in your GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==1-tp end)
	e3:SetCost(Cost.SelfBanish)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_DARK_MAGICIAN_GIRL}
--(1)Can be activated from the hand
function s.actfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x20a2)
end
function s.actcon(e)
	return Duel.IsExistingMatchingCard(s.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
--(2)Redirect damage
function s.bpendfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_DARK_MAGICIAN_GIRL)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp==1-Duel.GetTurnPlayer()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg and tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	Duel.SetTargetCard(tg)
	local dam=tg:GetAttack()
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if Duel.NegateAttack() then
			if Duel.Damage(1-tp,tc:GetAttack(),REASON_EFFECT) and Duel.IsExistingMatchingCard(s.bpendfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) then
				Duel.BreakEffect()
				Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE|PHASE_BATTLE_STEP,1)
			end
		end
	end
end
--(3)Destroy cards your opponent controls, up to the number of "Dark Magician Girl" in your GY
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,nil,CARD_DARK_MAGICIAN_GIRL)
		and Duel.IsExistingMatchingCard(Card.IsDestructable,tp,0,LOCATION_ONFIELD,1,nil) end 
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp,chk)
	local max_ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE+LOCATION_MZONE,0,nil,CARD_DARK_MAGICIAN_GIRL)
	if max_ct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,0,LOCATION_ONFIELD,1,max_ct,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end