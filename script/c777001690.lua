--Thunder Force Primal
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Material
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x301),5,2,s.ovfilter,aux.Stringid(id,0))
	c:EnableReviveLimit()
	--(1)Attach Material
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.DetachFromSelf(1,1,nil))
	e1:SetTarget(s.atttg)
	e1:SetOperation(s.attop)
	c:RegisterEffect(e1)
	--(2)Multi Attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e2:SetValue(s.raval)
	c:RegisterEffect(e2)
	--(3)If your "Thunder Force" Monster battles an opponent's monster, any battle damage it inflicts to your opponent is doubled
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(s.zeuscon)
	e3:SetTarget(function(e,c) local bc=c:GetBattleTarget() return c:IsSetCard(0x301) and bc and bc:IsControler(1-e:GetHandlerPlayer()) end)
	e3:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e3)
end
--Xyz Material
function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsSetCard(0x301) and c:IsType(TYPE_XYZ,xyzc,SUMMON_TYPE_XYZ,tp) and c:GetRank()==4
end
--(1)Attach Material
function s.attfilter1(c,e)
	return c:IsSetCard(0x301) and not c:IsImmuneToEffect(e)
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.attfilter1,tp,LOCATION_DECK,0,1,nil,e)
		and e:GetHandler():IsType(TYPE_XYZ) end
end
function s.attfilter2(c,e)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN) and not c:IsImmuneToEffect(e)
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local exg=Duel.SelectMatchingCard(tp,s.attfilter1,tp,LOCATION_DECK,0,1,1,nil,e)
	if #exg==0 then return end
	Duel.Overlay(c,exg)
	--Attach 1 other face-up monster
	local g=Duel.GetMatchingGroup(s.attfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,c,e)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if not tc then return end
		Duel.HintSelection(tc,true)
		Duel.BreakEffect()
		Duel.Overlay(c,tc,true)
	end
end
--(2)Multi Attack
function s.raval(e,c)
	local oc=e:GetHandler():GetOverlayCount()
	return math.max(0,oc)
end
--(3)If your "Thunder Force" Monster battles an opponent's monster, any battle damage it inflicts to your opponent is doubled
function s.zeusfilter1(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(777001670)
end
function s.zeuscon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.zeusfilter1,tp,LOCATION_MZONE,0,1,nil)
end