--Orichalcos Supremacy
--Scripted by Codex
local s,id=GetID()
function s.initial_effect(c)
	--Activate this Skill
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end
s.listed_names={48179391,777006340,777006350}
--Activate this Skill
function s.sealfilter(c,tp)
	local te=c:GetActivateEffect()
	return c:IsCode(48179391) and te and te:IsActivatable(tp,true,true)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(tp,id)==0
		and Duel.IsExistingMatchingCard(s.sealfilter,tp,LOCATION_HAND,0,1,nil,tp)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Reveal "The Seal of Orichalcos"
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.sealfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if not tc then return end
	Duel.ConfirmCards(1-tp,g)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Your opponent cannot activate cards or effects this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(aux.TRUE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--"The Seal of Orichalcos" is unaffected by card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetTargetRange(LOCATION_FZONE,0)
	e2:SetTarget(s.immtg)
	e2:SetValue(s.immval)
	Duel.RegisterEffect(e2,tp)
	--Once per Duel: Add "Orichalcos Deuteros" and shuffle "Orichalcos Tritos" into the Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCondition(s.outcon)
	e3:SetOperation(s.outop)
	Duel.RegisterEffect(e3,tp)
	--Activate the revealed "The Seal of Orichalcos"
	local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then return end
	local te=tc:GetActivateEffect()
	Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEDOWN,true)
	if tc:IsLocation(LOCATION_FZONE) and te then
		Duel.Activate(te)
	end
end
--"The Seal of Orichalcos" is unaffected by card effects
function s.immtg(e,c)
	return c:IsFaceup() and c:IsCode(48179391)
end
function s.immval(e,te)
	local rc=te:GetOwner()
	return not (te:IsMonsterEffect() and rc and rc:GetOriginalLevel()>=10)
end
--Add "Orichalcos Deuteros" and shuffle "Orichalcos Tritos" into the Deck
function s.outcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(tp,id+1)==0
end
function s.outop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(tp,id+1,0,0,0)
	--Add "Orichalcos Deuteros" to the hand
	local deuteros=Duel.CreateToken(tp,777006340)
	if deuteros and Duel.SendtoHand(deuteros,tp,REASON_RULE)>0 then
		--Duel.ConfirmCards(1-tp,deuteros)
	end
	--Shuffle "Orichalcos Tritos" into the Deck
	local tritos=Duel.CreateToken(tp,777006350)
	if tritos then
		--Duel.Hint(HINT_CARD,tp,777006350)
		--Duel.Hint(HINT_CARD,1-tp,777006350)
		Duel.SendtoDeck(tritos,tp,SEQ_DECKSHUFFLE,REASON_RULE)
	end
end