--Orichalcos Kyutora
--Scripted by Codex
local s,id=GetID()
function s.initial_effect(c)
	--(1)Place this card in the Spell & Trap Zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.plcost)
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)
	--(2)You take no effect damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CHANGE_DAMAGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,0)
	e2:SetCondition(s.spellcon)
	e2:SetValue(s.damval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e3)
	--(3)You take no battle damage from battles involving 2 monsters
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(1,0)
	e4:SetCondition(s.bdcon)
	e4:SetValue(0)
	c:RegisterEffect(e4)
	--(4)Ritual Summon 1 Ritual Monster
	local ritual_params={lvtype=RITPROC_GREATER,matfilter=s.ritmatfilter,extrafil=s.ritextrafil,location=LOCATION_HAND}
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCondition(s.ritcon)
	e5:SetTarget(Ritual.Target(ritual_params))
	e5:SetOperation(Ritual.Operation(ritual_params))
	c:RegisterEffect(e5)
end
s.listed_names={48179391}
--(1)Place this card in the Spell & Trap Zone
function s.plcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	Duel.PayLPCost(tp,500)
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and not c:IsForbidden() and c:CheckUniqueOnField(tp) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thfilter(c)
	return c:IsCode(48179391) and c:IsAbleToHand()
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0
		or not c:CheckUniqueOnField(tp) then return end
	if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		e1:SetReset(RESET_EVENT+(RESETS_STANDARD&~RESET_TURN_SET))
		c:RegisterEffect(e1)
		if not Duel.GetFieldCard(tp,LOCATION_FZONE,0)
			and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
			if #g>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end
--(2)You take no effect damage
function s.sealfilter(c)
	return c:IsFaceup() and c:IsCode(48179391,110000100,110000101,777006340,777006350)
end
function s.spellcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsContinuousSpell()
		and Duel.IsExistingMatchingCard(s.sealfilter,e:GetHandlerPlayer(),LOCATION_FZONE,0,1,nil)
end
function s.damval(e,re,val,r,rp,rc)
	if (r&REASON_EFFECT)~=0 then return 0
	else return val end
end
--(3)You take no battle damage from battles involving 2 monsters
function s.bdcon(e)
	return s.spellcon(e) and Duel.GetAttacker() and Duel.GetAttackTarget()
end
--(4)Ritual Summon 1 Ritual Monster
function s.ritcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousTypeOnField(TYPE_SPELL) and c:IsPreviousTypeOnField(TYPE_CONTINUOUS)
		and Duel.IsExistingMatchingCard(s.sealfilter,tp,LOCATION_FZONE,0,1,nil)
end
function s.ritmatfilter(c,e,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsReleasableByEffect()
end
function s.ritextrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(Card.IsReleasableByEffect,tp,0,LOCATION_MZONE,nil)
end
