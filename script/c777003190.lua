--Elementale Practicing
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--(1)Flip face-up or face-down any number of monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(2)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
	--(2)Special Summon 1 random face-down monster from your opponent's Extra Deck, or banish it
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_FLIP)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMING_MAIN_END,TIMINGS_CHECK_MONSTER_E)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
--(1)Flip face-up or face-down any number of monsters
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_MZONE,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	local pos=op==1 and POS_FACEUP_DEFENSE or POS_FACEDOWN_DEFENSE
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,tp,pos)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if not op then return end
	local filter=op==1 and Card.IsFacedown or s.posfilter
	local g=Duel.GetMatchingGroup(filter,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	local pos=op==1 and POS_FACEUP_DEFENSE or POS_FACEDOWN_DEFENSE
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	Duel.ChangePosition(g:Select(tp,1,#g,nil),pos)
end
--(2)Special Summon 1 random face-down monster from your opponent's Extra Deck, or banish it
function s.cfilter1(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(777003130)
end
function s.spcon(e,tp,eg)
	local tp=e:GetHandlerPlayer()
	return Duel.IsMainPhase() and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,0,1,nil) and eg:IsExists(s.spconfilter,1,nil,tp)
end
function s.spconfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0x310)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:HasFlagEffect(id) end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.IsPlayerCanSpecialSummon(tp) or Duel.IsPlayerCanRemove(tp))
		and Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_EXTRA,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_EXTRA,nil)
	if #g==0 then return end
	local tc=g:RandomSelect(tp,1):GetFirst()
	if not tc then return end
	Duel.ConfirmCards(tp,tc)
	if Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0
		and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		--It cannot activate its effects this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3302)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		Duel.SpecialSummonComplete()
	else
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end