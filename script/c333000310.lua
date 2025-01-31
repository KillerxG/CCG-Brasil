--Data Paladin - Inquisitor Leynel
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Summon
	Fusion.AddProcMixRep(c,true,true,s.ffilter,1,1,aux.FilterBoolFunctionEx(Card.IsSetCard,0x265))
	--(1)Banish opponent's card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsFusionSummoned() end)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	--(2)Search 1 "Data Paladin" card
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK+CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMING_BATTLE_START|TIMING_BATTLE_END|TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,id+1)
    e2:SetTarget(s.addtg)
    e2:SetOperation(s.addop)
    c:RegisterEffect(e2)
	--(3)Banish temporaly
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1,id+2)
	e3:SetCondition(s.drcon)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
--Fusion Summon
function s.ffilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_CYBERSE,fc,sumtype,tp)
end
--(1)Banish opponent's card
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g,true)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
--(2)Search 1 "Data Paladin" card
function s.conaddfilter(c)
    return c:IsSetCard(0x265) and c:IsType(TYPE_FUSION) and c:IsAbleToHand()
end
function s.addfilter(c)
    return c:IsSetCard(0x265) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.addfilter2(c)
    return c:IsSetCard(0x265) and c:IsAbleToHand()
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return ((Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil) and not Duel.IsExistingMatchingCard(s.conaddfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()))
		or (Duel.IsExistingMatchingCard(s.addfilter2,tp,LOCATION_DECK,0,1,nil) and Duel.IsExistingMatchingCard(s.conaddfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()))) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	s.announce_filter={TYPE_EXTRA,OPCODE_ISTYPE,OPCODE_NOT}
	local ac=Duel.AnnounceCard(tp,s.announce_filter)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #g>0 then
		Duel.ConfirmCards(tp,g)
		local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		local dg=g:Filter(Card.IsCode,nil,ac)		
		if g:IsExists(Card.IsCode,1,nil,ac) and #dg>0 then	--check if the declared card is in your opponent's hand		
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	if not Duel.IsExistingMatchingCard(s.conaddfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) then
    local d=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #d>0 then
			Duel.SendtoHand(d,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,d)
		end
	end
	if Duel.IsExistingMatchingCard(s.conaddfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) then
		local f=Duel.SelectMatchingCard(tp,s.addfilter2,tp,LOCATION_DECK,0,1,1,nil)
		if #f>0 then
			Duel.SendtoHand(f,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,f)
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
--(3)Banish temporaly
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return rc:IsSetCard(0x265) and r & REASON_FUSION == REASON_FUSION
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	local tc=g:GetFirst()
	if tc and #g>0 then
		Duel.HintSelection(g,true)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,2))
		-- Return to the hand in the opponent's End Phase
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.thcon)
		e1:SetOperation(s.thop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsTurnPlayer(tp) then return false end
	if e:GetLabelObject():GetFlagEffectLabel(id)==e:GetLabel() then return true end
	e:Reset()
	return false
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end
