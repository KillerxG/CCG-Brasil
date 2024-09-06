--FGO Ruler, Amor Caren
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--(1)Add Counter
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	--(2)Sum Limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetCondition(s.excon)
	c:RegisterEffect(e2)
	--(3)ATK Up
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetCondition(s.condtion)
	e3:SetValue(1000)
	c:RegisterEffect(e3)
	--(5)SQ Counter
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_COUNTER)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS+CATEGORY_COUNTER)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e5:SetCountLimit(1)
	e5:SetTarget(s.pcttg)
	e5:SetOperation(s.pctop)
	c:RegisterEffect(e5)
	--(5)SQ Counter
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_COUNTER)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS+CATEGORY_COUNTER)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetCountLimit(1)
	e6:SetTarget(s.pcttg)
	e6:SetOperation(s.pctop)
end
s.listed_names={777002210}
--(1)Add Counter
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanAddCounter(0x1295,1) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x1295,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x1295,1)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:AddCounter(0x1295,1) then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,c:GetFieldID())
		--Effect to counter
		--Halve ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetAttack()/2)
		tc:RegisterEffect(e1)
		--Must attack this card, if able
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_MUST_ATTACK)
		e2:SetTargetRange(0,LOCATION_MZONE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetTarget(s.musttg)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_MUST_ATTACK_MONSTER)
		e3:SetValue(function(e,c) return c==e:GetHandler() end)
		c:RegisterEffect(e3)
		--Cannot be used as material for a Fusion/Synchro/Xyz/Link Summon
		local e4=Effect.CreateEffect(c)
		e4:SetDescription(aux.Stringid(id,1))
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CLIENT_HINT)
		e4:SetCode(EFFECT_CANNOT_BE_MATERIAL)
		e4:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
		tc:RegisterEffect(e4)
	end
end
function s.musttg(e,c)
	return c:GetFlagEffectLabel(id) and c:GetFlagEffectLabel(id)==e:GetHandler():GetFieldID()
end
--(2)Sum Limit
function s.excon(e)
	return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,777002210),e:GetHandlerPlayer(),LOCATION_FZONE,0,1,nil)
end
--(3)ATK Up
function s.spcfilter(c)
	return c:IsFaceup() and c:GetCounter(0x1295)>0
end
function s.condtion(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.spcfilter,0,0,LOCATION_MZONE,1,nil)
end
--(5)SQ Counter
--(6)SQ Counter
function s.pcttg(e,tp,eg,ep,ev,re,r,rp,chk)
  local tc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
  if chk==0 then return tc and tc:IsFaceup() and tc:IsSetCard(0x294) end
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
end
function s.pctop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
  if tc and tc:IsFaceup() and tc:IsSetCard(0x294) then
    tc:AddCounter(0x1294,3)
  end
end