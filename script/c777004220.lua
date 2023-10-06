--Obscure Raid Gate
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Grant multiple effects to 1 "Obscure Raid" Fusion or Xyz monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(TIMING_STANDBY_PHASE|TIMING_BATTLE_START)
	c:RegisterEffect(e1)
	--(2)Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
--(1)Grant multiple effects to 1 "Obscure Raid" Fusion or Xyz monster
function s.selfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x281) and c:IsType(TYPE_FUSION+TYPE_XYZ) and c:GetFlagEffect(id)==0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.selfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	local tc=Duel.SelectMatchingCard(tp,s.selfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not tc then return end
	Duel.HintSelection(tc,true)
	if tc:GetFlagEffect(id)==0 and tc:IsCode(777004090) then
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
		--Can Attack all
		local e1=Effect.CreateEffect(tc)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetValue(1)
		e1:SetCode(EFFECT_ATTACK_ALL)
		--e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)		
	end
	if tc:GetFlagEffect(id)==0 and tc:IsCode(777004110) then
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
		local e2=Effect.CreateEffect(tc)
		e2:SetDescription(aux.Stringid(id,1))
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetRange(LOCATION_MZONE)
		e2:SetTargetRange(0,LOCATION_MZONE)
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(-1000)
		tc:RegisterEffect(e2)
	end
	if tc:GetFlagEffect(id)==0 and tc:IsCode(777004080) then
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
		local e3=Effect.CreateEffect(tc)
		e3:SetDescription(aux.Stringid(id,2))
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_IMMUNE_EFFECT)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e3:SetRange(LOCATION_MZONE)
		e3:SetValue(s.efilter)
		--e3:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		tc:RegisterEffect(e3)
	end
	if tc:GetFlagEffect(id)==0 and tc:IsCode(777004100) then
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
		local e4=Effect.CreateEffect(tc)
		e4:SetDescription(aux.Stringid(id,3))
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetRange(LOCATION_MZONE)
		e4:SetTargetRange(0,LOCATION_MZONE)
		e4:SetCode(EFFECT_SET_ATTACK_FINAL)
		e4:SetValue(0)
		tc:RegisterEffect(e4)
	end
end
function s.efilter(e,re)
	return e:GetOwnerPlayer()==1-re:GetOwnerPlayer()
end
--(2)Special Summon
function s.filter(c,e,tp)
	return c:IsSetCard(0x281) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc,e,tp) end
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetTargetCards(e)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<#sg or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local c=e:GetHandler()
	for tc in sg:Iter() do
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e2,true)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CHANGE_LEVEL)
			e3:SetValue(8)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3,true)
		end
	end
	Duel.SpecialSummonComplete()
end