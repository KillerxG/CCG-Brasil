--Data Paladin - King Raizo
--Scripted by KillerxG
local s,id=GetID()
local LOCATION_HAND_DECK_EXTRA_GRAVE=LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE
function s.initial_effect(c)
	--Fusion Summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x265),aux.FilterBoolFunctionEx(Card.IsRace,RACE_CYBERSE),aux.FilterBoolFunctionEx(Card.IsType,TYPE_FUSION))
	--(1)Halve ATK/DEF of your opponent's monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsFusionSummoned() end)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--(2)Place Sin Counter
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.ctcon)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetCondition(s.ctcon2)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_CHAINING)
	e4:SetCondition(s.ctcon3)
	c:RegisterEffect(e4)
	--(3)Banish opponent's monster
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetHintTiming(0,TIMING_MAIN_END|TIMING_BATTLE_START|TIMING_BATTLE_END|TIMINGS_CHECK_MONSTER_E)
	e5:SetCountLimit(1,id)
	e5:SetTarget(s.rmtg)
	e5:SetOperation(s.rmop)
	c:RegisterEffect(e5)
	--(4)Look hand, then Banish
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,3))
	e6:SetCategory(CATEGORY_REMOVE+CATEGORY_TODECK+CATEGORY_DRAW)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_MZONE)
	e6:SetHintTiming(0,TIMING_MAIN_END|TIMING_BATTLE_START|TIMING_BATTLE_END|TIMINGS_CHECK_MONSTER_E)
	e6:SetCountLimit(1,id+1)
	e6:SetTarget(s.pttg)
	e6:SetOperation(s.ptop)
	c:RegisterEffect(e6)
end
--(1)Halve ATK/DEF of your opponent's monsters
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.HasNonZeroAttack,tp,0,LOCATION_MZONE,1,nil)
		or Duel.IsExistingMatchingCard(Card.HasNonZeroDefense,tp,0,LOCATION_MZONE,1,nil) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=tg:GetFirst()
	for tc in aux.Next(tg) do
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk/2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(def/2)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
--(2)Place Sin Counter
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not eg:IsContains(c) and eg:IsExists(Card.IsControler,1,c,1-tp) then return true end
end
function s.ctcon2(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	return at:IsControler(1-tp)
end
function s.ctcon3(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsMonsterEffect()
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc~=c end
	if chk==0 then return not c:HasFlagEffect(id)
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,c) end
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:AddCounter(0x1265,1) then
		local c=e:GetHandler()
		--That monster Loses 200 ATK/DEF
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetCondition(s.atkcon)
		e1:SetValue(s.atkval)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end
function s.atkcon(e)
	return e:GetHandler():GetCounter(0x1265)>0
end
function s.atkval(e,c)
	return c:GetCounter(0x1265)*-200
end
--(3)Banish opponent's monster
function s.rmopfilter(c)
	return c:IsAbleToRemove() and c:IsFaceup() and c:GetCounter(0x1265)>3
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(s.rmopfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.rmopfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,g:GetFirst():GetControler(),LOCATION_HAND_DECK_EXTRA_GRAVE)
end
function s.rmfilter(c,code)
	return c:IsCode(code) and (c:IsLocation(0x43) or aux.SpElimFilter(c,true))
end
function s.conaddfilter(c)
    return c:IsSetCard(0x265) and c:IsType(TYPE_FUSION) and c:IsAbleToHand()
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
		local og=Duel.GetOperatedGroup()
		local rg=Group.CreateGroup()
		local tc=og:GetFirst()
		for tc in aux.Next(og) do
			if Duel.IsExistingMatchingCard(s.conaddfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) then
				local sg=Duel.GetMatchingGroup(s.rmfilter,tc:GetControler(),LOCATION_HAND_DECK_EXTRA_GRAVE,0,nil,tc:GetCode())
				rg:Merge(sg)
			end
		end
		if #rg>0 then
			Duel.BreakEffect()
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
--(4)Look hand, then Banish
function s.pttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	s.announce_filter={TYPE_EXTRA,OPCODE_ISTYPE,OPCODE_NOT}
	local ac=Duel.AnnounceCard(tp,s.announce_filter)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
end

function s.ptop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #g>0 then
		Duel.ConfirmCards(tp,g)
		local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		local dg=g:Filter(Card.IsCode,nil,ac)		
		if g:IsExists(Card.IsCode,1,nil,ac) and #dg>0 then	--check if the declared card is in your opponent's hand		
			if Duel.Remove(dg,POS_FACEUP,REASON_EFFECT)~=0 then
			local og=Duel.GetOperatedGroup()
			local rg=Group.CreateGroup()
			local tf=og:GetFirst()
				for tf in aux.Next(og) do					
				local sg=Duel.GetMatchingGroup(s.rmfilter,tf:GetControler(),LOCATION_HAND_DECK_EXTRA_GRAVE,0,nil,tf:GetCode())
				rg:Merge(sg)			
				end
					if #rg>0 then
						Duel.BreakEffect()
						Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
					end
		end
			
			if Duel.IsPlayerCanDraw(1-tp) and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND,1,e:GetHandler()) --allow opponent to redraw its hand
				and Duel.SelectYesNo(1-tp,aux.Stringid(id,3)) then
				Duel.SetTargetPlayer(tp)
				Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
				Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
				--local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
				local j=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
					if #j==0 then return end
						Duel.SendtoDeck(j,1-tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
						Duel.ShuffleDeck(1-tp)
						Duel.BreakEffect()
						Duel.Draw(1-tp,#j,REASON_EFFECT)
			end
		end
		Duel.ShuffleHand(1-tp)
	end
end
