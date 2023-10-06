--Obscure Raid Striker
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Send 1 Warrior or "Obscure Raid" monster from your Deck to GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--(2)ATK Down and burn
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+1)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
--(1)Send 1 Warrior or "Obscure Raid" monster from your Deck to GY
function s.tgfilter(c)
	return (c:IsRace(RACE_WARRIOR) or c:IsSetCard(0x281)) and c:IsMonster() and c:IsAbleToGrave() and not c:IsCode(id)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) and tc:IsSetCard(0x281)
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(8)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
--(2)ATK Down and burn
function s.fld_fil(c)
	return c:IsFaceup() and c:IsMonster()
end
function s.grv_fil(c)
	return c:IsAbleToRemove() and c:IsSetCard(0x281) and c:IsMonster() and aux.SpElimFilter(c,true)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,69832741) and Duel.IsExistingTarget(s.fld_fil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) 
	and Duel.IsExistingMatchingCard(s.grv_fil,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SelectTarget(tp,s.fld_fil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.grv_lvl_sum(c)
	return c:GetLevel()*200
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local tg=Duel.GetFieldGroup(tp,LOCATION_GRAVE,0):Filter(s.grv_fil,nil)
	if tc:IsRelateToEffect(e) and #tg>0 then
		if not Duel.Remove(tg,nil,REASON_EFFECT) then return end
		local i=tg:Filter(Card.IsLocation,nil,LOCATION_REMOVED):GetSum(s.grv_lvl_sum)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-i)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetOperation(s.dmg_op)
		e2:SetLabel(i)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.dmg_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,e:GetLabel(),REASON_EFFECT)
end