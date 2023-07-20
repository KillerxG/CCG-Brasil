--East DraBladers - Call
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Ritual Summon
	local e1=Ritual.AddProcGreater({handler=c,filter=s.ritualfil,lv=Card.GetDefense,matfilter=s.filter,
	location=LOCATION_HAND|LOCATION_GRAVE,requirementfunc=Card.GetAttack,desc=aux.Stringid(id,0),stage2=s.stage2})
	c:RegisterEffect(e1)
	--(2)Add this card from GY to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)	
end
--(1)Ritual Summon
function s.ritualfil(c)
	return c:GetDefense()>0 and c:IsRitualMonster()
end
function s.filter(c)
	return c:GetAttack()>0
end
function s.stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	local c=e:GetHandler()
	if not tc:IsLevel(6,9)then return end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,777002425,0,TYPES_TOKEN,0,0,2,RACE_DRAGON,ATTRIBUTE_DARK) 
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
			local token=Duel.CreateToken(tp,777002425)
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_BASE_DEFENSE)
			e1:SetValue(2000)
			token:RegisterEffect(e1)
		end
end
--(2)Add this card from GY to hand
function s.thcfilter(c,tp)
	return c:IsReason(REASON_COST+REASON_EFFECT) and c:IsRitualMonster() and c:GetPreviousControler()==tp 
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.thcfilter,1,nil,tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end