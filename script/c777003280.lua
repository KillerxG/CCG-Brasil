--Oceanic Storm Assassin - Derik
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Special Summon 1 "Oceanic Ritual" monster from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--(1.1)Enable other location if control bossd
	local e2=e1:Clone()
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.tdcon2)
	c:RegisterEffect(e2)
	--(2)Effect Gain: Discard
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_PAY_LPCOST)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetCondition(s.drcon)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	--(2.1)Check target for effect gain
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.eftg)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
--(1)Special Summon 1 "Oceanic Ritual" monster from the hand
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x312) and c:IsRitualMonster() and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	local c=e:GetHandler()
	if tc and Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)>0
		and c:IsRelateToEffect(e)  then
		Duel.BreakEffect()
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
--(1.1)Enable other location if control boss
function s.tdcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,777003320),tp,LOCATION_MZONE,0,1,nil)
end
--(2.1)Check target for effect gain
function s.eftg(e,c)
	local g=e:GetHandler():GetColumnGroup(0,0)
	return c:IsType(TYPE_RITUAL) and c:IsSetCard(0x312) and c:GetSequence()<5 and g:IsContains(c)
end
--(2)Effect Gain: Discard
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsControler(tp) and rc:IsLocation(LOCATION_MZONE) and rc:IsSetCard(0x312)
		and rc:IsFaceup()
end
function s.spcfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_PENDULUM+TYPE_LINK)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,2)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local g=Duel.GetFieldGroup(p,0,LOCATION_HAND)
	local j=Duel.IsExistingMatchingCard(s.spcfilter,tp,0,LOCATION_MZONE,1,nil)
	if #g>0 then
		local sg=g:RandomSelect(p,1)
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
		g:RemoveCard(sg:GetFirst())
		if Duel.IsExistingMatchingCard(s.spcfilter,tp,0,LOCATION_MZONE,1,nil) then
			Duel.Hint(HINT_SELECTMSG,1-p,HINTMSG_DISCARD)
			sg=g:Select(1-p,1,1,nil)
			Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
		end
	end
end