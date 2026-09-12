-- King of Thunder Force - Zeus
-- Scripted by Codex
--[[ Effects:
	E0: Cannot be Normal Summoned/Set. This card's Divine Hierarchy Rank is 2.
	E1: During your Battle Phase, if this card destroys an opponent's monster by battle: You can toss a coin and call it; if you call right, this card can attack again in a row.
	E2: Once per turn: You can toss a coin and call it; if you call right, increase this card's Hierarchy Rank by 1.
	E3: Once per turn (Quick Effect): You can toss a coin 3 times and destroy cards your opponent controls, up to the number of heads, then if the result was 3 heads, you can draw 3 cards.
	E4: Once per turn, if this card would be destroyed by battle or card effect, you can reduce the Level of 1 other monster you control by 3 instead.
]]
local s,id=GetID()
Duel.LoadScript("proc_divine_hierarchy_mod.lua")
function s.initial_effect(c)
	DivineHierarchyMod.Register(c,2)
	c:EnableReviveLimit()
	--(1)Toss a coin to attack again after destroying a monster by battle
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--(2)Toss a coin to increase this card's Hierarchy Rank
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_COIN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.hrtg)
	e2:SetOperation(s.hrop)
	c:RegisterEffect(e2)
	--(3)Toss 3 coins, destroy cards up to the number of heads, and possibly draw 3 cards
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_COIN|CATEGORY_DESTROY|CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e3:SetTarget(s.cointg)
	e3:SetOperation(s.coinop)
	c:RegisterEffect(e3)
	--(4)Reduce another monster's Level by 3 instead of destroying this card
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
s.toss_coin=true
--(1)Toss a coin to attack again after destroying a monster by battle
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return Duel.GetTurnPlayer()==tp and c==Duel.GetAttacker() and bc
		and bc:IsPreviousControler(1-tp) and c:CanChainAttack()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local call=Duel.AnnounceCoin(tp)
	local result=Duel.TossCoin(tp,1)
	if call==result and c:IsRelateToEffect(e) and c:CanChainAttack() then
		Duel.ChainAttack()
	end
end
--(2)Toss a coin to increase this card's Hierarchy Rank
function s.hrtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.hrop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
	local call=Duel.AnnounceCoin(tp)
	local result=Duel.TossCoin(tp,1)
	if call==result then
		DivineHierarchyMod.IncreaseRank(c,1,RESET_EVENT|RESETS_STANDARD)
	end
end
--(3)Toss 3 coins, destroy cards up to the number of heads, and possibly draw 3 cards
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,3)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,3,1-tp,LOCATION_ONFIELD)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
function s.desfilter(c)
	return c:IsDestructable()
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local heads=Duel.CountHeads(Duel.TossCoin(tp,3))
	if heads>0 then
		local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
		local ct=math.min(heads,#g)
		if ct>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local dg=g:Select(tp,1,ct,nil)
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
	if heads==3 and Duel.IsPlayerCanDraw(tp,3)
		and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.BreakEffect()
		Duel.Draw(tp,3,REASON_EFFECT)
	end
end
--(4)Reduce another monster's Level by 3 instead of destroying this card
function s.lvfilter(c,e)
	return c:IsFaceup() and c:HasLevel() and c:GetLevel()>3 and not c:IsImmuneToEffect(e)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE|REASON_EFFECT)
		and not c:IsReason(REASON_REPLACE)
		and Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,0,1,c,e) end
	return Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,3))
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	local g=Duel.SelectMatchingCard(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,c,e)
	local tc=g:GetFirst()
	if tc then
		tc:UpdateLevel(-3,RESET_EVENT|RESETS_STANDARD,c)
	end
end
