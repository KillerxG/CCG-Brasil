--East Wings Impact
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--(1)Place 1 face-up monster in its owner's Spell/Trap Zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.plcon)
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)
	--(2)Special Summon 1 monster that is treated as a Continuous Spell
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
--(1)Place 1 face-up monster in its owner's Spell/Trap Zone
function s.actfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x314) and c:IsType(TYPE_XYZ)
end
function s.plcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsInMainMZone(1-tp) and chkc:IsFaceup() and chkc:IsType(TYPE_EFFECT) end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsType,TYPE_EFFECT),tp,0,LOCATION_MMZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsType,TYPE_EFFECT),tp,0,LOCATION_MMZONE,1,1,nil):GetFirst()
	local dc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,tc:GetSequence())
	if dc then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dc,1,0,0)
	end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsControler(1-tp)) or tc:IsImmuneToEffect(e) then return end
	local seq=tc:GetSequence()
	local dc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,seq)
	if dc and Duel.Destroy(dc,REASON_RULE)>0 and dc:IsMonsterCard() and dc:GetBaseAttack()>0 then
		Duel.SetLP(1-tp,Duel.GetLP(1-tp)-dc:GetBaseAttack())
	end
	if Duel.CheckLocation(1-tp,LOCATION_SZONE,seq)
		and Duel.MoveToField(tc,tp,1-tp,LOCATION_SZONE,POS_FACEUP,tc:IsMonsterCard(),1<<seq) then
		--Treated as a Continuous Spell
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
		tc:RegisterEffect(e1)
	end
end
--(2)Special Summon 1 monster that is treated as a Continuous Spell
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x314) and c:IsType(TYPE_XYZ)
end
function s.bossfilter(c)
	return c:IsFaceup() and c:IsCode(777004820)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsMonsterCard() and c:IsContinuousSpell()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then 
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) 
		if Duel.IsExistingMatchingCard(s.bossfilter,tp,LOCATION_ONFIELD,0,1,nil) and c:IsAbleToHand() then
			Duel.SendtoHand(c,tp,REASON_EFFECT)
		else
			Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
		end
	end
end
