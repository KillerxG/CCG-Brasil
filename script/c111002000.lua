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

	--Register Destiny Draw only for this card's owner
	s.register_destiny_draw(tp)

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

function s.register_destiny_draw(p)
	--Register the Rule only for its owner
	local e1=Effect.GlobalEffect()
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(
		EFFECT_FLAG_CANNOT_DISABLE|
		EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PREDRAW)

	--Labels 0/1 identify the owner
	--Labels 2/3 indicate that the Rule was already used
	e1:SetLabel(p)
	e1:SetCondition(s.ddcon)
	e1:SetOperation(s.ddop)
	Duel.RegisterEffect(e1,p)
end

function s.ddcon(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetLabel()
	return p<2
		and tp==p
		and Duel.GetTurnPlayer()==p
		and Duel.GetDrawCount(p)>0
		and Duel.GetFieldGroupCount(
			p,LOCATION_DECK,0)>0
		and Duel.GetLP(1-p)>=Duel.GetLP(p)*2
		and Duel.GetFieldGroupCount(
			p,0,LOCATION_MZONE)>0
end

function s.ddop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetLabel()
	if p>=2 or tp~=p or Duel.GetTurnPlayer()~=p then
		return
	end

	--Using this Rule is optional
	if not Duel.SelectYesNo(
		p,aux.Stringid(id,0)) then
		return
	end

	Duel.Hint(HINT_CARD,0,id)

	--Choose any card from the Deck
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SELECT)
	local g=Duel.SelectMatchingCard(
		p,aux.TRUE,p,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end

	--Consume the once-per-Duel use
	e:SetLabel(p+2)

	--Shuffle, then place the selected card on top
	Duel.ShuffleDeck(p)
	Duel.MoveSequence(tc,0)
end