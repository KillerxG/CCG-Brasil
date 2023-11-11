--Elemental Dragon - Zephyr
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WIND),1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--Material check
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.matcheck)
	c:RegisterEffect(e0)
	--(1)Shuffle other monsters on field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.bancon)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	--(2)ATK/DEF Up for WIND monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_WIND))
	e2:SetValue(s.datkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--(3)ATK/DEF Down for EARTH monsters
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_EARTH))
	e4:SetValue(s.latkval)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
	--(4)Change Attribute to WIND or Special
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_EXTRA)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_SET_AVAILABLE)
	e6:SetCountLimit(1,id)
	e6:SetCost(s.cost)
	e6:SetCondition(s.condition)
	e6:SetTarget(s.target)
	e6:SetOperation(s.activate)
	c:RegisterEffect(e6)
	--(5)Turn monster into WIND
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,3))
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	e7:SetRange(LOCATION_EXTRA)
	e7:SetCondition(s.attcon)
	e7:SetTarget(s.atttg)
	e7:SetOperation(s.attop)
	c:RegisterEffect(e7)
end
--Material check
function s.matcheck(e,c)
	local mg=c:GetMaterial()
	if #mg>0 and #mg==mg:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_WIND) then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~(RESET_TOFIELD|RESET_LEAVE),EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,5))
	end
end
--(1)Shuffle other monsters on field
function s.bancon(e)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:HasFlagEffect(id)
end
function s.fiwlter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	if #g>0 then
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) then 
		--Allow you to Special Summons a mosnter from your hand 
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.fiwlter,tp,LOCATION_HAND,0,1,nil,e,tp)
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g1=Duel.SelectMatchingCard(tp,s.fiwlter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			Duel.SpecialSummonStep(g1:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
		end
			--Allow your opponent to Special Summons a mosnter from its hand 
			if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.fiwlter,1-tp,LOCATION_HAND,0,1,nil,e,1-tp)
			and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
			local g2=Duel.SelectMatchingCard(1-tp,s.fiwlter,1-tp,LOCATION_HAND,0,1,1,nil,e,1-tp)
			Duel.SpecialSummonStep(g2:GetFirst(),0,1-tp,1-tp,false,false,POS_FACEUP)
			end
			Duel.SpecialSummonComplete()
		end
	end
end
--(2)ATK Up for WIND monsters
function s.datkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsAttribute,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,nil,ATTRIBUTE_WIND)*200
end
--(3)ATK Down for EARTH monsters
function s.latkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsAttribute,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,nil,ATTRIBUTE_WIND)*-200
end
--(4)Change Attribute to WIND or Special
function s.cfilter(c)
	return (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_FIEND)) and c:IsRitualMonster() and not c:IsPublic()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEDOWN)
end
function s.filter(c,e,tp)
	return c:IsMonster() and c:IsType(TYPE_TUNER)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	if g:GetFirst():IsMonster() and g:GetFirst():IsAttribute(ATTRIBUTE_WIND) then
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	else
		
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	Duel.SendtoGrave(c,REASON_EFFECT)
	if not tc:IsRelateToEffect(e) then return end
	Duel.SendtoExtraP(c,tp,REASON_EFFECT)
	if tc:IsMonster() and not tc:IsAttribute(ATTRIBUTE_WIND) then
		local e1=Effect.CreateEffect(e:GetHandler())		
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(ATTRIBUTE_WIND)
		tc:RegisterEffect(e1)
	elseif (tc:IsMonster() and tc:IsAttribute(ATTRIBUTE_WIND) and Duel.IsPlayerCanDiscardDeck(tp,1)) then
		Duel.ConfirmDecktop(tp,1)
		local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
		Duel.DisableShuffleCheck()
	if tc:IsType(TYPE_MONSTER) and not c:IsType(TYPE_TUNER) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then		
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		end
	end
end
--(5)Turn monster into WIND
function s.attcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP)
end
function s.attfilter(c,tp)
	return c:IsFaceup() and not c:IsAttribute(ATTRIBUTE_WIND)
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return eg:IsExists(s.attfilter,1,nil,tp) end
	local g=eg:Filter(s.attfilter,nil,tp)
	Duel.SetTargetCard(eg)
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(s.attfilter,nil,tp)
	for eg in eg:Iter() do
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(ATTRIBUTE_WIND)
		eg:RegisterEffect(e2)
		Duel.SendtoGrave(c,REASON_EFFECT)
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
