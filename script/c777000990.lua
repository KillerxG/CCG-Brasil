--Elemental Dragon - Burrow
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_EARTH),1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--Material check
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.matcheck)
	c:RegisterEffect(e0)
	--(1)Chage Battle Positions
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.bancon)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	--(2)ATK/DEF Up for EARTH monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_EARTH))
	e2:SetValue(s.datkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--(3)ATK/DEF Down for WIND monsters
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_WIND))
	e4:SetValue(s.latkval)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
	--(4)Change Attribute to EARTH or add
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
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
	--(5)Turn monster into EARTH
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
	if #mg>0 and #mg==mg:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_EARTH) then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~(RESET_TOFIELD|RESET_LEAVE),EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,5))
	end
end
--(1)Shuffle other monsters on field
function s.bancon(e)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:HasFlagEffect(id)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,nil) end
	local sg=Duel.GetMatchingGroup(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,sg,#sg,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,nil)
	if #sg>0 and Duel.ChangePosition(sg,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)>0 then
		local tg=Duel.GetOperatedGroup()
		local c=e:GetHandler()
		for tc in aux.Next(tg) do
			--Cannot change their battle positions
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3313)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		end
	end
end
--(2)ATK Up for EARTH monsters
function s.datkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsAttribute,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,nil,ATTRIBUTE_EARTH)*200
end
--(3)ATK Down for WIND monsters
function s.latkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsAttribute,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,nil,ATTRIBUTE_EARTH)*-200
end
--(4)Change Attribute to EARTH or add
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
function s.srfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH)  and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	if g:GetFirst():IsMonster() and g:GetFirst():IsAttribute(ATTRIBUTE_EARTH) then
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
	if tc:IsMonster() and not tc:IsAttribute(ATTRIBUTE_EARTH) then
		local e1=Effect.CreateEffect(e:GetHandler())		
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(ATTRIBUTE_EARTH)
		tc:RegisterEffect(e1)
		-----------------------
		elseif (tc:IsMonster() and tc:IsAttribute(ATTRIBUTE_EARTH) and Duel.IsExistingMatchingCard(s.srfilter,tp,LOCATION_DECK,0,1,nil)) then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.srfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #g>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
	end
end
--(5)Turn monster into EARTH
function s.attcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP)
end
function s.attfilter(c,tp)
	return c:IsFaceup() and not c:IsAttribute(ATTRIBUTE_EARTH)
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
		e2:SetValue(ATTRIBUTE_EARTH)
		eg:RegisterEffect(e2)
		Duel.SendtoGrave(c,REASON_EFFECT)
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
