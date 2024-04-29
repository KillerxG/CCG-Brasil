--Sky Wind Attack
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --(1)DEF Down 1 monster you control and negate the effects of 1 of your opponent's monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.negttg)
	e1:SetOperation(s.negtop)
	c:RegisterEffect(e1)
end
--(1)DEF Down 1 monster you control and negate the effects of 1 of your opponent's monster
function s.cfilter(c,e,tp)
	return ((c:IsControler(tp) and c:GetDefense()>=1000 and c:IsSetCard(0x306)) or (c:IsControler(1-tp) and c:IsNegatableMonster() and c:IsType(TYPE_EFFECT)))
		and c:IsCanBeEffectTarget(e)
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsControler,nil,tp)==1
end
function s.negttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local rg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e,tp)
	if chk==0 then return aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(tg)
	local dg,ng=tg:Split(Card.IsControler,nil,tp)
	e:SetLabelObject(dg:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,ng,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,ng,1,0,0)
end
function s.negtop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g==0 then return end
	local dc=g:GetFirst()
	local negc=g:GetNext()
	if negc==e:GetLabelObject() then dc,negc=negc,dc end
	if dc and dc:IsControler(tp) and dc:UpdateDefense(-1000,RESET_EVENT+RESETS_STANDARD,c)==-1000
		and negc and negc:IsControler(1-tp) and negc:IsFaceup() and negc:IsCanBeDisabledByEffect(e) then
		negc:NegateEffects(e:GetHandler(),RESET_PHASE|PHASE_END)
		if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,777001490),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.AdjustInstantly()
			Duel.BreakEffect()
			Duel.Destroy(negc,REASON_EFFECT)
		end
	end
end