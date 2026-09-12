-- Queen of Sky Wind - Serena
-- Scripted by Codex
--[[ Effects:
	E0: Cannot be Normal Summoned/Set. This card's Divine Hierarchy Rank is 1.
	E1: Your opponent cannot target cards you control with card effects, except this card, also your opponent's monsters cannot target monsters for attacks, except this one.
	E2: Once per turn, during your Main Phase, when a card or effect is activated that targets this card (Quick Effect): You can increase this card's Hierarchy Rank by 1.
	E3: Once per turn (Quick Effect): You can target 1 monster you control; destroy all monsters your opponent controls with an ATK lower than this card's current ATK, also destroy all Spell/Traps your opponent controls.
	E4: Once per turn, if this card would be destroyed by battle or card effect, you can destroy 1 other WIND or Pendulum monster from your hand or field instead.
]]
local s,id=GetID()
Duel.LoadScript("proc_divine_hierarchy_mod.lua")
function s.initial_effect(c)
	--Divine Hierarchy Rank 1
	DivineHierarchyMod.Register(c,1)
	--Cannot be Normal Summoned/Set
	c:EnableReviveLimit()
	--(1a)The opponent cannot target your other cards with card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(s.eftg)
	e1:SetValue(s.eflimit)
	c:RegisterEffect(e1)
	--(1b)The opponent's monsters cannot attack your other monsters
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_FIELD)
	e1b:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1b:SetRange(LOCATION_MZONE)
	e1b:SetTargetRange(0,LOCATION_MZONE)
	e1b:SetValue(s.atlimit)
	c:RegisterEffect(e1b)
	--(2)Increase this card's Hierarchy Rank when an effect targets it during your Main Phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.hrcon)
	e2:SetOperation(s.hrop)
	c:RegisterEffect(e2)
	--(3)Destroy the opponent's monsters with lower ATK and all their Spells/Traps
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	--(4)Destroy another WIND or Pendulum monster instead of destroying this card
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.desreptg)
	e4:SetOperation(s.desrepop)
	c:RegisterEffect(e4)
end
--(1)Force the opponent to target/attack this card instead of your other cards
function s.eftg(e,c)
	return c~=e:GetHandler()
end
function s.eflimit(e,re,rp)
	return rp==1-e:GetHandlerPlayer()
end
function s.atlimit(e,c)
	return c~=e:GetHandler()
end
--(2)Increase this card's Hierarchy Rank when it becomes an effect target
function s.hrcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return Duel.GetTurnPlayer()==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
		and g and g:IsContains(e:GetHandler())
end
function s.hrop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		DivineHierarchyMod.IncreaseRank(c,1,RESET_EVENT|RESETS_STANDARD)
	end
end
--(3)Destroy the opponent's monsters with lower ATK and all their Spells/Traps
function s.owntgfilter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
function s.desfilter(c,atk)
	return c:IsDestructable() and (c:IsSpellTrap()
		or (c:IsFaceup() and c:IsMonster() and c:GetAttack()<atk))
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.owntgfilter(chkc,e) end
	local atk=e:GetHandler():GetAttack()
	if chk==0 then return Duel.IsExistingTarget(s.owntgfilter,tp,LOCATION_MZONE,0,1,nil,e)
		and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil,atk) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.owntgfilter,tp,LOCATION_MZONE,0,1,1,nil,e)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil,atk)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFaceup() then return end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil,c:GetAttack())
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
--(4)Destroy another WIND or Pendulum monster instead of destroying this card
function s.repfilter(c)
	return c:IsMonster() and (c:IsAttribute(ATTRIBUTE_WIND) or c:IsType(TYPE_PENDULUM))
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED) and c:IsDestructable()
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE|REASON_EFFECT)
		and not c:IsReason(REASON_REPLACE)
		and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,c) end
	return Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,3))
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,c)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT|REASON_REPLACE)
	end
end
