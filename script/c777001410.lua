--Bestial Force - Fubuki
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon Procedure
	Synchro.AddProcedure(c,nil,2,2,Synchro.NonTunerEx(Card.IsRace,RACE_BEASTWARRIOR),1,99)
	--(1)Excavate the top 5 cards of your deck and gain extra attack per Beast-Warrior monster excavated
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.mtcon)
	e1:SetOperation(s.mtop)
	c:RegisterEffect(e1)
	--(2)Destroy then SS Token
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.ctlcon)
	e2:SetTarget(s.ctltg)
	e2:SetOperation(s.ctlop)
	c:RegisterEffect(e2)
	--(3)Pierce
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	e3:SetValue(DOUBLE_DAMAGE)
	c:RegisterEffect(e3)
end
--(1)Excavate the top 5 cards of your deck and gain extra attack per Beast-Warrior monster excavated
function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP() and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.ConfirmDecktop(tp,5)
	local g=Duel.GetDecktopGroup(tp,5)
	local ct=g:FilterCount(Card.IsRace,nil,RACE_BEASTWARRIOR)
	Duel.ShuffleDeck(tp)
	if ct>1 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		e1:SetValue(ct)
		c:RegisterEffect(e1)
	end
end
--(2)Destroy then SS Token
function s.ctlcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsMonsterEffect()
end
function s.ctlfilter(c,tp)
	return c:IsFaceup() and c:IsDestructable() and Duel.GetMZoneCount(1-tp,c,tp)>0
end
function s.ctltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.ctlfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.ctlfilter,tp,0,LOCATION_MZONE,1,nil,tp)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+5,0,TYPES_TOKEN,0,1000,1,RACE_ROCK,ATTRIBUTE_WATER,POS_FACEUP_DEFENSE,1-tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.ctlfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.ctlop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if Duel.Destroy(tc,tp) and Duel.IsPlayerCanSpecialSummonMonster(tp,id+5,0,TYPES_TOKEN,0,1000,1,RACE_ROCK,ATTRIBUTE_WATER,POS_FACEUP_DEFENSE,1-tp) then
		Duel.BreakEffect()
		local token=Duel.CreateToken(tp,id+5)
		Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP)
		--Cannot be tributed
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(3309)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1,true)
			local e2=e1:Clone()
			e2:SetDescription(3310)
			e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
			token:RegisterEffect(e2,true)
			--Cannot be used as synchro material
			local e3=e2:Clone()
			e3:SetDescription(3312)
			e3:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
			token:RegisterEffect(e3,true)
	end
end