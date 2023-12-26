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
	return (c:GetOriginalLevel(13) and c:IsAttack(3500) and c:IsDefense(3000)) and not c:IsPublic()
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
	--Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
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
	if tc and tc:IsCode(777000680) and Duel.IsPlayerCanSpecialSummonMonster(tp,777000685,0x300,TYPES_TOKEN,500,500,1,RACE_ILLUSION,ATTRIBUTE_FIRE) then
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
	if tc and tc:IsCode(777001670) and Duel.IsPlayerCanSpecialSummonMonster(tp,777001675,0x301,TYPES_TOKEN,500,500,1,RACE_ILLUSION,ATTRIBUTE_LIGHT) then
		local token=Duel.CreateToken(tp,777001675)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777001675)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777001675)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		if Duel.SpecialSummonComplete() then
			local x=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,777001675)
			local ct=Duel.SendtoGrave(x,REASON_EFFECT)
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
	--Phantom Gunners
	if tc and tc:IsCode(777000960) and Duel.IsPlayerCanSpecialSummonMonster(tp,777000965,0x302,TYPES_TOKEN,500,500,1,RACE_ILLUSION,ATTRIBUTE_DARK) then
		local token=Duel.CreateToken(tp,777000965)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777000965)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777000965)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		if Duel.SpecialSummonComplete() then
			local x=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,777000965)
			local ct=Duel.SendtoGrave(x,REASON_EFFECT)
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
	--Shinigami
	if tc and tc:IsCode(777001470) and Duel.IsPlayerCanSpecialSummonMonster(tp,777001475,0x304,TYPES_TOKEN,500,500,1,RACE_ILLUSION,ATTRIBUTE_DARK) then
		local token=Duel.CreateToken(tp,777001475)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777001475)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777001475)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		if Duel.SpecialSummonComplete() then
			local x=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,777001475)
			local ct=Duel.SendtoGrave(x,REASON_EFFECT)
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
	--Timerx
	if tc and tc:IsCode(777001150) and Duel.IsPlayerCanSpecialSummonMonster(tp,777001155,0x305,TYPES_TOKEN,500,500,1,RACE_ILLUSION,ATTRIBUTE_EARTH) then
		local token=Duel.CreateToken(tp,777001155)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777001155)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777001155)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		if Duel.SpecialSummonComplete() then
			local x=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,777001155)
			local ct=Duel.SendtoGrave(x,REASON_EFFECT)
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
	--Sky Wind
	if tc and tc:IsCode(777001490) and Duel.IsPlayerCanSpecialSummonMonster(tp,777001495,0x306,TYPES_TOKEN,500,500,1,RACE_ILLUSION,ATTRIBUTE_WIND) then
		local token=Duel.CreateToken(tp,777001495)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777001495)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777001495)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		if Duel.SpecialSummonComplete() then
			local x=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,777001495)
			local ct=Duel.SendtoGrave(x,REASON_EFFECT)
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
	--Silver Fangs
	if tc and tc:IsCode(777001320) and Duel.IsPlayerCanSpecialSummonMonster(tp,777001325,0x307,TYPES_TOKEN,500,500,1,RACE_ILLUSION,ATTRIBUTE_LIGHT) then
		local token=Duel.CreateToken(tp,777001325)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777001325)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777001325)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		if Duel.SpecialSummonComplete() then
			local x=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,777001325)
			local ct=Duel.SendtoGrave(x,REASON_EFFECT)
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
	--Warbeast
	if tc and tc:IsCode(777001840) and Duel.IsPlayerCanSpecialSummonMonster(tp,777001845,0x308,TYPES_TOKEN,500,500,1,RACE_ILLUSION,ATTRIBUTE_WATER) then
		local token=Duel.CreateToken(tp,777001845)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777001845)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777001845)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		if Duel.SpecialSummonComplete() then
			local x=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,777001845)
			local ct=Duel.SendtoGrave(x,REASON_EFFECT)
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
	--Cyberclops
	if tc and tc:IsCode(333000040) and Duel.IsPlayerCanSpecialSummonMonster(tp,333000045,0x311,TYPES_TOKEN,500,500,1,RACE_ILLUSION,ATTRIBUTE_FIRE) then
		local token=Duel.CreateToken(tp,333000045)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,333000045)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,333000045)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		if Duel.SpecialSummonComplete() then
			local x=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,333000045)
			local ct=Duel.SendtoGrave(x,REASON_EFFECT)
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end		
	end
	--Rockslash
	if tc and tc:IsCode(777002010) and Duel.IsPlayerCanSpecialSummonMonster(tp,777002015,0x309,TYPES_TOKEN,500,500,1,RACE_ILLUSION,ATTRIBUTE_EARTH) then
		local token=Duel.CreateToken(tp,777002015)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777002015)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777002015)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		if Duel.SpecialSummonComplete() then
			local x=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,777002015)
			local ct=Duel.SendtoGrave(x,REASON_EFFECT)
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
	--Elementale
	if tc and tc:IsCode(777003130) and Duel.IsPlayerCanSpecialSummonMonster(tp,777003135,0x310,TYPES_TOKEN,500,500,1,RACE_ILLUSION,ATTRIBUTE_WIND) then
		local token=Duel.CreateToken(tp,777003135)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777003135)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777003135)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		if Duel.SpecialSummonComplete() then
			local x=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,777003135)
			local ct=Duel.SendtoGrave(x,REASON_EFFECT)
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
	--Oceanic Storm	
	if tc and tc:IsCode(777003320) and Duel.IsPlayerCanSpecialSummonMonster(tp,777003325,0x312,TYPES_TOKEN,500,500,1,RACE_ILLUSION,ATTRIBUTE_WATER) then
		local token=Duel.CreateToken(tp,777003325)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777003325)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token=Duel.CreateToken(tp,777003325)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		if Duel.SpecialSummonComplete() then
			local x=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,777003325)
			local ct=Duel.SendtoGrave(x,REASON_EFFECT)
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
