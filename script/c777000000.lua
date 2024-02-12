--Idrakian Force
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Token
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
--Idrakian Force
function s.cfilter(c)
	return c:IsSetCard(0x313) and not c:IsPublic()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>2 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp,LOCATION_MZONE)<3 then return end
	--Draconic
	if tc and tc:IsCode(777000680) and Duel.IsPlayerCanSpecialSummonMonster(tp,777000685,0x313,TYPES_TOKEN,0,0,1,RACE_WARRIOR,ATTRIBUTE_DARK) then
		local token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		if Duel.SpecialSummonComplete() then
			local x=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,777000685)
			local ct=Duel.SendtoGrave(x,REASON_EFFECT)
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end		
	end
	--Thunder Force
	if tc and tc:IsCode(777001670) and Duel.IsPlayerCanSpecialSummonMonster(tp,777000685,0x313,TYPES_TOKEN,0,0,1,RACE_WARRIOR,ATTRIBUTE_DARK) then
		local token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		if Duel.SpecialSummonComplete() then
			local x=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,777000685)
			local ct=Duel.SendtoGrave(x,REASON_EFFECT)
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
	--Phantom Gunners
	if tc and tc:IsCode(777000960) and Duel.IsPlayerCanSpecialSummonMonster(tp,777000685,0x313,TYPES_TOKEN,0,0,1,RACE_WARRIOR,ATTRIBUTE_DARK) then
		local token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		if Duel.SpecialSummonComplete() then
			local x=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,777000685)
			local ct=Duel.SendtoGrave(x,REASON_EFFECT)
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
	--Shinigami
	if tc and tc:IsCode(777001470) and Duel.IsPlayerCanSpecialSummonMonster(tp,777000685,0x313,TYPES_TOKEN,0,0,1,RACE_WARRIOR,ATTRIBUTE_DARK) then
		local token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		if Duel.SpecialSummonComplete() then
			local x=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,777000685)
			local ct=Duel.SendtoGrave(x,REASON_EFFECT)
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
	--Timerx
	if tc and tc:IsCode(777001150) and Duel.IsPlayerCanSpecialSummonMonster(tp,777000685,0x313,TYPES_TOKEN,0,0,1,RACE_WARRIOR,ATTRIBUTE_DARK) then
		local token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		if Duel.SpecialSummonComplete() then
			local x=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,777000685)
			local ct=Duel.SendtoGrave(x,REASON_EFFECT)
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
	--Sky Wind
	if tc and tc:IsCode(777001490) and Duel.IsPlayerCanSpecialSummonMonster(tp,777000685,0x313,TYPES_TOKEN,0,0,1,RACE_WARRIOR,ATTRIBUTE_DARK) then
		local token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		if Duel.SpecialSummonComplete() then
			local x=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,777000685)
			local ct=Duel.SendtoGrave(x,REASON_EFFECT)
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
	--Silver Fangs
	if tc and tc:IsCode(777001320) and Duel.IsPlayerCanSpecialSummonMonster(tp,777000685,0x313,TYPES_TOKEN,0,0,1,RACE_WARRIOR,ATTRIBUTE_DARK) then
		local token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		if Duel.SpecialSummonComplete() then
			local x=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,777000685)
			local ct=Duel.SendtoGrave(x,REASON_EFFECT)
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
	--Warbeast
	if tc and tc:IsCode(777001840) and Duel.IsPlayerCanSpecialSummonMonster(tp,777000685,0x313,TYPES_TOKEN,0,0,1,RACE_WARRIOR,ATTRIBUTE_DARK) then
		local token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		if Duel.SpecialSummonComplete() then
			local x=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,777000685)
			local ct=Duel.SendtoGrave(x,REASON_EFFECT)
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
	--Cyberclops
	if tc and tc:IsCode(333000040) and Duel.IsPlayerCanSpecialSummonMonster(tp,777000685,0x313,TYPES_TOKEN,0,0,1,RACE_WARRIOR,ATTRIBUTE_DARK) then
		local token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		if Duel.SpecialSummonComplete() then
			local x=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,777000685)
			local ct=Duel.SendtoGrave(x,REASON_EFFECT)
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end		
	end
	--Rockslash
	if tc and tc:IsCode(777002010) and Duel.IsPlayerCanSpecialSummonMonster(tp,777000685,0x313,TYPES_TOKEN,0,0,1,RACE_WARRIOR,ATTRIBUTE_DARK) then
		local token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		if Duel.SpecialSummonComplete() then
			local x=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,777000685)
			local ct=Duel.SendtoGrave(x,REASON_EFFECT)
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
	--Elementale
	if tc and tc:IsCode(777003130) and Duel.IsPlayerCanSpecialSummonMonster(tp,777000685,0x313,TYPES_TOKEN,0,0,1,RACE_WARRIOR,ATTRIBUTE_DARK) then
		local token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		if Duel.SpecialSummonComplete() then
			local x=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,777000685)
			local ct=Duel.SendtoGrave(x,REASON_EFFECT)
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
	--Oceanic Storm	
	if tc and tc:IsCode(777003320) and Duel.IsPlayerCanSpecialSummonMonster(tp,777000685,0x313,TYPES_TOKEN,0,0,1,RACE_WARRIOR,ATTRIBUTE_DARK) then
		local token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777000685)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		if Duel.SpecialSummonComplete() then
			local x=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,777000685)
			local ct=Duel.SendtoGrave(x,REASON_EFFECT)
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
