--Sky Wind Angel
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum Summon
	Pendulum.AddProcedure(c)
	--Synchro Summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsSetCard,0x306),1,99)
	c:EnableReviveLimit()
	--(1)Pendulum Effect
	--(1.1)"Sky Wind" monsters you control cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(s.btcon)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x306))
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--(1.2)Special Summon itself
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--(2)Monster Effect
	--(2.1)Additional Attack
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	--(2.2)Double BP
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_BECOME_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+2)
	e4:SetCondition(function(e,tp,eg) return eg:IsContains(e:GetHandler()) and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_BP_TWICE) end)
	e4:SetOperation(s.doublebattlephase)
	c:RegisterEffect(e4)
	--(2.3)Place itself in P-Zone
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_EXTRA)
	e5:SetCountLimit(1,id+3)
	e5:SetCondition(s.pencon)
	e5:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.CheckPendulumZones(tp) end end)
	e5:SetOperation(s.penop)
	c:RegisterEffect(e5)
end
--(1.1)"Sky Wind" monsters you control cannot be destroyed by battle
function s.cfilter1(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(777001490)
end
function s.btcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end
--(1.2)Special Summon itself
function s.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsMonster()
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(s.cfilter2,1,nil) and Duel.GetMZoneCount(tp,sg)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,LOCATION_ONFIELD,0,nil,e)
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,0,tp) end
	local tg=aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,1,tp,HINTMSG_DESTROY,s.rescon)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,#tg,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 then return end
	local ct=Duel.Destroy(tg,REASON_EFFECT)
	if ct==0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		
	end
	Duel.SpecialSummonComplete()
end
--(2.1)Additional Attack
function s.filter(c)
	return c:GetSequence()<5
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_SZONE,0,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	local ct=Duel.SendtoHand(g,nil,REASON_EFFECT)
	if ct>0 and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(ct)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
	end
end
--(2.2)Double BP
function s.doublebattlephase(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,EFFECT_BP_TWICE) then return end
	local turn_ct=Duel.GetTurnCount()
	local ct=Duel.IsTurnPlayer(tp) and Duel.IsBattlePhase() and 2 or 1
	--You can conduct your next Battle Phase twice
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_BP_TWICE)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	e1:SetCondition(function() return ct==1 or Duel.GetTurnCount()~=turn_ct end)
	e1:SetReset(RESET_PHASE|PHASE_BATTLE|RESET_SELF_TURN,ct)
	Duel.RegisterEffect(e1,tp)
end
--(2.3)Place itself in P-Zone
function s.pencon(e)
	return e:GetHandler():IsLocation(LOCATION_EXTRA) and e:GetHandler():IsFaceup()
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end