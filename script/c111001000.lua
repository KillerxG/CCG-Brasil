--Dark Signer
--Scripted by Codex
local s,id=GetID()

--Fallback because some EDOPro repositories do not define this constant
local SET_DARK_TUNER_SKILL=SET_DARK_TUNER or 0x1d5

--Cards that can be generated from outside the Duel
s.outside_cards={
	64187086, --Earthbound Immortal Revival
	96907086, --Earthbound Whirlwind
	44710391, --Earthbound Geoglyph
	39967326, --Revival of the Immortals
	82340056, --Offering to the Immortals
	56339050, --Roar of the Earthbound Immortal
	70109009, --Ultimate Earthbound Immortal
	29934351  --Earthbound Wave
}

function s.initial_effect(c)
	--Activate this Skill
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end

s.listed_names={
	64187086,
	96907086,
	44710391,
	39967326,
	82340056,
	56339050,
	70109009,
	29934351
}
s.listed_series={
	SET_EARTHBOUND,
	SET_EARTHBOUND_IMMORTAL,
	SET_DARK_TUNER_SKILL
}

--Activation requirement
function s.revealfilter(c)
	return c:IsMonster()
		and (c:IsSetCard(SET_EARTHBOUND)
			or c:IsSetCard(SET_DARK_TUNER_SKILL))
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp)
		and Duel.GetFlagEffect(tp,id)==0
		and Duel.IsExistingMatchingCard(
			s.revealfilter,tp,LOCATION_HAND,0,1,nil)
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	--Flip the Skill face-up
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	--Reveal 1 "Earthbound" or "Dark Tuner" monster
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(
		tp,s.revealfilter,tp,LOCATION_HAND,0,1,1,nil)
	if #g==0 then return end

	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)

	--Register that the Skill has been activated
	Duel.RegisterFlagEffect(tp,id,0,0,0)

	--Normal Summon Level 5 or higher Tuner monsters
	--without Tributing
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCondition(s.ntcon)
	e1:SetTarget(aux.FieldSummonProcTg(s.nttg))
	Duel.RegisterEffect(e1,tp)

	--Once per turn: Change a monster's Level
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_LVCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetCondition(s.lvcon)
	e2:SetOperation(s.lvop)
	Duel.RegisterEffect(e2,tp)

	--Once per turn, during your End Phase:
	--Generate 1 random listed Spell/Trap
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE|PHASE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(s.outcon)
	e3:SetOperation(s.outop)
	Duel.RegisterEffect(e3,tp)
end

--Normal Summon without Tributing
function s.ntcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(
		c:GetControler(),LOCATION_MZONE)>0
end

function s.nttg(e,c)
	return c:IsMonster()
		and c:IsType(TYPE_TUNER)
		and c:IsLevelAbove(5)
end

--Level-changing effect
function s.lvfilter(c)
	return c:IsFaceup() and c:HasLevel()
end

function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp)
		and Duel.CheckLPCost(tp,1000)
		and Duel.IsExistingMatchingCard(
			s.lvfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

	--Pay 1000 LP
	Duel.PayLPCost(tp,1000)

	--Select the monster
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(
		tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not tc then return end

	Duel.HintSelection(Group.FromCards(tc))

	--Declare a Level from 1 to 10
	local lv=Duel.AnnounceLevel(tp,1,10)

	--Change its Level until the end of this turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(lv)
	e1:SetReset(
		RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
	tc:RegisterEffect(e1)

	--Optionally make it a Tuner
	if not tc:IsType(TYPE_TUNER)
		and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(aux.Stringid(id,6))
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_TUNER)
		e2:SetReset(
			RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		tc:RegisterEffect(e2)
	end
end

--Control an "Earthbound Immortal" during your End Phase
function s.immortalfilter(c)
	return c:IsFaceup()
		and c:IsSetCard(SET_EARTHBOUND_IMMORTAL)
end

function s.outcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp)
		and Duel.IsExistingMatchingCard(
			s.immortalfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.outop(e,tp,eg,ep,ev,re,r,rp)
	--The End Phase effect is optional
	if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		return
	end

	Duel.Hint(HINT_CARD,tp,id)

	--Randomly choose 1 of the listed cards
	local index=Duel.GetRandomNumber(1,#s.outside_cards)
	local code=s.outside_cards[index]
	local tc=Duel.CreateToken(tp,code)
	if not tc then return end

	--Reveal the randomly chosen card to both players
	Duel.Hint(HINT_CARD,tp,code)
	Duel.Hint(HINT_CARD,1-tp,code)

	--Choose whether to add it to the hand or Set it
	local option=0
	if tc:IsSSetable() then
		option=Duel.SelectOption(
			tp,
			aux.Stringid(id,3),
			aux.Stringid(id,4))
	end

	if option==1 then
		--Set it
		if Duel.SSet(tp,tc)>0 then
			return
		end
	end

	--Add it to the hand
	if Duel.SendtoHand(tc,tp,REASON_RULE)>0 then
		Duel.ConfirmCards(1-tp,tc)
	end
end