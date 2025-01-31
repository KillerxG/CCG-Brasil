--Data Paladin - Light Rogue
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Fusion Summon 1 "Data Paladin" Fusion monster using materials from the field, including this card
	local params = {aux.FilterBoolFunction(Card.IsSetCard,0x265),nil,nil,nil,Fusion.ForcedHandler}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e2:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e2)
	--(3)Sin Counter
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.drcon)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
--(1)Special Summon
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x265) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp) and not c:IsCode(id)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	s.announce_filter={TYPE_EXTRA,OPCODE_ISTYPE,OPCODE_NOT}
	local ac=Duel.AnnounceCard(tp,s.announce_filter)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #g>0 then
		Duel.ConfirmCards(tp,g)
		local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		local dg=g:Filter(Card.IsCode,nil,ac)		
		if g:IsExists(Card.IsCode,1,nil,ac) and #dg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then	--check if the declared card is in your opponent's hand		
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local f=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp) -- unique effect of the card
		if #f>0 then
			Duel.SpecialSummon(f,0,tp,tp,false,false,POS_FACEUP)
		end
			if Duel.IsPlayerCanDraw(1-tp) and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND,1,e:GetHandler()) --allow opponent to redraw its hand
				and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then
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
--(3)Sin Counter
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return rc:IsSetCard(0x265) and r & REASON_FUSION == REASON_FUSION
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsMonster()
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 end
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)==0 then return end
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0):RandomSelect(tp,1)
	local tc=g:GetFirst()
	Duel.ConfirmCards(tp,tc)
	Duel.ShuffleHand(1-tp)
	if tc:IsAttribute(ATTRIBUTE_LIGHT) and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 then
		local c=e:GetHandler()
		local f=Duel.GetMatchingGroup(s.cfilter,tp,0,LOCATION_MZONE,nil)
		local tf=f:GetFirst()
		for tf in aux.Next(f) do
		tf:AddCounter(0x1265,1)
	end
	end	
end

