-- Empress of Silver Fangs - Kyara
-- Scripted by Codex
--[[ Effects:
	E0: Cannot be Normal Summoned/Set. This card's Divine Hierarchy Rank is 1.
	E1: While your LP is higher than your opponent's LP, your opponent must keep their hand revealed, also you can look at their Set cards at any time.
	E2: Once per turn, during your Main Phase, if you gain LP: You can increase this card's Hierarchy Rank by 1.
	E3: Once per turn, if this card would be destroyed by battle or card effect while your LP is higher than your opponent's LP, you can halve your LP instead.
	E4: Once per turn (Quick Effect): You can target 1 card your opponent controls; destroy it, and if you do, gain 1000 LP.
]]
local s,id=GetID()
Duel.LoadScript("proc_divine_hierarchy_mod.lua")
function s.initial_effect(c)
	--Divine Hierarchy Rank 1
	DivineHierarchyMod.Register(c,1)
	--Cannot be Normal Summoned/Set
	c:EnableReviveLimit()
	--(1)Reveal the opponent's hand and Set cards while your LP is higher
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.pubcon)
	e1:SetTargetRange(0,LOCATION_HAND|LOCATION_ONFIELD)
	c:RegisterEffect(e1)
	--(2)Increase this card's Hierarchy Rank when you gain LP during your Main Phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RECOVER)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.hrcon)
	e2:SetOperation(s.hrop)
	c:RegisterEffect(e2)
	--(3)Halve your LP instead of destroying this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.desreptg)
	e3:SetOperation(s.desrepop)
	c:RegisterEffect(e3)
	--(4)Destroy 1 opponent's card, then gain 1000 LP
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_DESTROY|CATEGORY_RECOVER)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
--(1)Reveal the opponent's hand and Set cards while your LP is higher
function s.pubcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetLP(tp)>Duel.GetLP(1-tp)
end
--(2)Increase this card's Hierarchy Rank when you gain LP during your Main Phase
function s.hrcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ep==tp and Duel.GetTurnPlayer()==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
function s.hrop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		DivineHierarchyMod.IncreaseRank(c,1,RESET_EVENT|RESETS_STANDARD)
	end
end
--(3)Halve your LP instead of destroying this card
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE|REASON_EFFECT)
		and not c:IsReason(REASON_REPLACE)
		and Duel.GetLP(tp)>Duel.GetLP(1-tp) end
	return Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,2))
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetLP(tp,math.ceil(Duel.GetLP(tp)/2))
end
--(4)Destroy 1 opponent's card, then gain 1000 LP
function s.desfilter(c)
	return c:IsDestructable()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.desfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		Duel.Recover(tp,1000,REASON_EFFECT)
	end
end
