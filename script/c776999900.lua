-- Master of Rockslash - Haruna
-- Scripted by Codex
--[[ Effects:
	E0: Cannot be Normal Summoned/Set. This card's Divine Hierarchy Rank is 2.
	E1: Once per turn: You can destroy 2 other Rock monsters from your field or hand, and if you do, increase this card's Hierarchy Rank by 1.
	E2: Once per turn (Quick Effect): You can target 1 card your opponent controls; destroy it, and if you do, your opponent takes 1000 damage.
	E3: If a card(s) is sent to your opponent's GY or banished: Inflict 800 damage to your opponent.
	E4: Once per turn, if this card would be destroyed by battle or card effect, you can take 2000 damage instead.
]]
local s,id=GetID()
Duel.LoadScript("proc_divine_hierarchy_mod.lua")
function s.initial_effect(c)
	DivineHierarchyMod.Register(c,2)
	c:EnableReviveLimit()
	--(1)Destroy 2 other Rock monsters to increase this card's Hierarchy Rank
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.hrtg)
	e1:SetOperation(s.hrop)
	c:RegisterEffect(e1)
	--(2)Destroy 1 opponent's card, then inflict 1000 damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY|CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--(3)Inflict 800 damage when a card is sent to the opponent's GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.gydamcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	--(3)Inflict 800 damage when a card is banished
	local e3b=e3:Clone()
	e3b:SetCode(EVENT_REMOVE)
	e3b:SetCondition(s.rmdamcon)
	c:RegisterEffect(e3b)
	--(4)Take 2000 damage instead of destroying this card
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
--(1)Destroy 2 other Rock monsters to increase this card's Hierarchy Rank
function s.hrfilter(c)
	return c:IsMonster() and c:IsRace(RACE_ROCK) and c:IsDestructable()
end
function s.hrtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.hrfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,2,c) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,tp,LOCATION_HAND|LOCATION_MZONE)
end
function s.hrop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.hrfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,c)
	if #g<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=g:Select(tp,2,2,nil)
	if Duel.Destroy(dg,REASON_EFFECT)==2 and c:IsRelateToEffect(e) and c:IsFaceup() then
		DivineHierarchyMod.IncreaseRank(c,1,RESET_EVENT|RESETS_STANDARD)
	end
end
--(2)Destroy 1 opponent's card, then inflict 1000 damage
function s.desfilter(c)
	return c:IsDestructable()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.desfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end
--(3)Inflict 800 damage when a card is sent to the opponent's GY
--(3)Inflict 800 damage when a card is banished
function s.gyfilter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp)
end
function s.gydamcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.gyfilter,1,nil,1-tp)
end
function s.rmdamcon(e,tp,eg,ep,ev,re,r,rp)
	return #eg>0
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,800,REASON_EFFECT)
end
--(4)Take 2000 damage instead of destroying this card
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE|REASON_EFFECT)
		and not c:IsReason(REASON_REPLACE) end
	return Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,3))
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(tp,2000,REASON_EFFECT|REASON_REPLACE)
end
