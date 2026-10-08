--Destiny Draw (Rule CCG)
--Scripted by Codex
local s,id=GetID()

if not id then
	id=111002000
end

function s.initial_effect(c)
	--Remove this Rule Card from the Deck/hand at startup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(
		EFFECT_FLAG_CANNOT_DISABLE|
		EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_STARTUP)
	e1:SetRange(0x5f)
	e1:SetCountLimit(1)
	e1:SetCondition(s.startcon)
	e1:SetOperation(s.startop)
	c:RegisterEffect(e1)
end

function s.startcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)==0
end

function s.startop(e,tp,eg,ep,ev,re,r,rp)
	--Prevent other copies from repeating this operation
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	Duel.Hint(HINT_CARD,0,id)

	--Find every copy owned by this player
	local g=Duel.GetMatchingGroup(
		Card.IsCode,tp,0x7f,0,nil,id)

	--Count copies that occupied the opening hand
	local hand_count=g:FilterCount(
		Card.IsLocation,nil,LOCATION_HAND)

	--Send every copy outside the normal Duel locations
	if #g>0 then
		Duel.SendtoDeck(g,nil,-2,REASON_RULE)
	end

	--Replace copies that were in the opening hand
	if hand_count>0 then
		Duel.Draw(tp,hand_count,REASON_RULE)
	end
end

if not DestinyDrawCCG then
	DestinyDrawCCG={}

	aux.GlobalCheck(DestinyDrawCCG,function()
		DestinyDrawCCG[0]=false
		DestinyDrawCCG[1]=false
	end)

	local function finishsetup()
		--Check before player 0's normal draw
		local e1=Effect.GlobalEffect()
		e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(
			EFFECT_FLAG_CANNOT_DISABLE|
			EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(DestinyDrawCCG.condition)
		e1:SetOperation(DestinyDrawCCG.operation)
		Duel.RegisterEffect(e1,0)

		--Check before player 1's normal draw
		local e2=e1:Clone()
		Duel.RegisterEffect(e2,1)
	end

	function DestinyDrawCCG.condition(e,tp,eg,ep,ev,re,r,rp)
		return not DestinyDrawCCG[tp]
			and Duel.GetDrawCount(tp)>0
			and Duel.GetFieldGroupCount(
				tp,LOCATION_DECK,0)>0
			and Duel.GetLP(1-tp)>=Duel.GetLP(tp)*2
			and Duel.GetFieldGroupCount(
				tp,0,LOCATION_MZONE)>0
	end

	function DestinyDrawCCG.operation(e,tp,eg,ep,ev,re,r,rp)
		--Using this Rule is optional
		if not Duel.SelectYesNo(
			tp,aux.Stringid(id,0)) then
			return
		end

		Duel.Hint(HINT_CARD,0,id)

		--Choose any card from the Deck
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		local g=Duel.SelectMatchingCard(
			tp,aux.TRUE,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if not tc then return end

		--Consume the once-per-Duel use
		DestinyDrawCCG[tp]=true

		--Shuffle, then place the selected card on top
		Duel.ShuffleDeck(tp)
		Duel.MoveSequence(tc,0)
	end

	finishsetup()
end