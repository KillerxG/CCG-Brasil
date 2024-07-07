--Oceanic Storm Walker
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Special Summon itself
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_PAY_LPCOST)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--(2)Special Summon 1 WATER mosnter from GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,5))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PAY_LPCOST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
	--(3)Add Name
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetCost(s.copycost)
	e3:SetTarget(s.copytg)
	e3:SetOperation(s.copyop)
	c:RegisterEffect(e3)
end
--(1)Special Summon itself
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
--(2)Increase ATK/DEF per multiples of 600
function s.filter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
--(3)Add Name
function s.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1 = Duel.CheckLPCost(tp,600)
	local b2 = Duel.CheckLPCost(1-tp,600) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsOriginalCode,777003320),tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	local g=(op==1)
	if op==1 then
		--here you pay the cost
		Duel.PayLPCost(tp,600)
	elseif op==2 then
		--here you make the opponent pay it
		Duel.PayLPCost(1-tp,600)
	end
end
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	s.announce_filter={TYPE_SKILL+TYPE_ACTION+TYPE_PLUS+TYPE_MINUS+TYPE_PLUSMINUS+TYPE_ARMOR,OPCODE_ISTYPE,TYPE_SKILL+TYPE_ACTION+TYPE_PLUS+TYPE_MINUS+TYPE_PLUSMINUS+TYPE_ARMOR,OPCODE_ISTYPE,OPCODE_AND,OPCODE_NOT}
	local cg=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
	Duel.SetTargetParam(cg)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local cg=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	--(2.1)Gain Name
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(cg)
	c:RegisterEffect(e1)
	--(2.2)Register The Hint
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,4))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2,true)
	--(2.3)Lock Summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,5),nil)
	--(2.4)Lizard check
	aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)
end
--(2.3)Lock Summon
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER) and c:IsLocation(LOCATION_EXTRA)
end
--(2.4)Lizard check
function s.lizfilter(e,c)
	return not c:IsOriginalAttribute(ATTRIBUTE_WATER)
end