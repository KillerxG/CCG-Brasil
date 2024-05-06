--Twilight Angel of Inquisition
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--Pendulum Summon
	Pendulum.AddProcedure(c)
	--Fusion Material
    Fusion.AddProcMixRep(c,true,true,aux.FilterBoolFunctionEx(Card.IsType,TYPE_PENDULUM),1,99,777001570)
	c:EnableReviveLimit()
	--(1)Pendulum Effect
	--(1.1)Return and place other Scale
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTarget(s.rthtg)
	e1:SetOperation(s.rthop)
	c:RegisterEffect(e1)
	--(2)Monster Effect
	--(2.1)Cannot be destroyed by card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	c:RegisterEffect(e2)
	--(2.2)Multi Attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
	--(2.3)Destroy an opponent's card that activated its effect on the field
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.chdescon)
	e4:SetCost(s.chdescost)
	e4:SetTarget(s.chdestg)
	e4:SetOperation(s.chdesop)
	c:RegisterEffect(e4)
	--(2.4)Special Summon and Place itself into Pendulum Zone
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(s.pencon)
	e5:SetTarget(s.pentg)
	e5:SetOperation(s.penop)
	c:RegisterEffect(e5)
end
--Fusion Material
function s.ffilter(c,fc,sumtype,tp)
	return c:IsType(TYPE_PENDULUM,fc,sumtype,tp) and c:IsOnField()
end
--(1.1)Return and place other Scale
function s.ppzfilter(c)
  return c:IsFaceup()and c:IsRace(RACE_FAIRY) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsAbleToExtra()
  and Duel.IsExistingMatchingCard(s.ppzfilter,tp,LOCATION_EXTRA,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
  if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,tp,0,REASON_EFFECT)~=0 then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local g=Duel.SelectMatchingCard(tp,s.ppzfilter,tp,LOCATION_EXTRA,0,1,1,nil)
    if g:GetCount()>0 then
      Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    end
  end
end
--(2.1)Cannot be destroyed by card effects
function s.valcheck(e,c)
	if c:GetMaterialCount()>=3 then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,5))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetValue(1)
		e1:SetCondition(s.indcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		c:RegisterEffect(e1,true)
	end
end
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
--(2.2)Multi Attack
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(c:GetMaterialCount()-1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
end
--(2.3)Destroy an opponent's card that activated its effect on the field
function s.chdescon(e,tp,eg,ep,ev,re,r,rp)
	local trig_loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return rp==1-tp and trig_loc&LOCATION_ONFIELD>0 and re:GetHandler():IsRelateToEffect(re)
end
function s.chdescostfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsFaceup() and c:IsAbleToHandAsCost()
end
function s.chdescost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.chdescostfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.chdescostfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	Duel.SendtoHand(g,tp,REASON_COST)
end
function s.chdestg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,tp,0)
end
function s.chdesop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
--(2.4)Special Summon and Place itself into Pendulum Zone
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function s.penfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.penfilter,tp,LOCATION_PZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_PZONE)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.penfilter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end