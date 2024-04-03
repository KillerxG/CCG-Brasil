--Rockslash Guardian
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.sumcon)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
	--(2)Destroy 1 S/T your opponent controls
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
--(1)Special Summon
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return r&REASON_EFFECT~=0 and ep~=tp
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
--(2)Destroy 1 S/T your opponent controls
function s.dmgfilter(c)
	return c:IsSetCard(0x309) and c:IsFaceup()
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return r&REASON_EFFECT~=0 and ep~=tp
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_SZONE)
	if chk==0 then return #g>0 end
	local ebg=Duel.GetMatchingGroup(s.dmgfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	local dam=ebg:GetClassCount(Card.GetCode)*200
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tg=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_SZONE,1,1,nil)
	if #tg==0 then return end
	Duel.HintSelection(tg,true)
	if Duel.Destroy(tg,REASON_EFFECT)>0 then
		local g=Duel.GetMatchingGroup(s.dmgfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
		if #g==0 then return end
		local dam=g:GetClassCount(Card.GetCode)*200
		Duel.BreakEffect()
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end