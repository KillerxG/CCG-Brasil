--Thunder Force Primal Brute
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Material
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x301),5,2,s.ovfilter,aux.Stringid(id,0))
	c:EnableReviveLimit()
	--(1)Attach Material
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.tgcond)
	e1:SetTarget(s.atttg)
	e1:SetOperation(s.attop)
	c:RegisterEffect(e1)
	--(3)Double ATK
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(s.atkcost)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
	--(4)ATK to 0
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SET_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(s.atktg2)
	e4:SetCondition(s.atkcon2)
	e4:SetValue(0)
	c:RegisterEffect(e4)
end
--Xyz Material
function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsSetCard(0x301) and c:IsType(TYPE_XYZ,xyzc,SUMMON_TYPE_XYZ,tp) and c:GetRank()==4
end
--(1)Attach Material
function s.tgcond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.attfilter1(c,e)
	return c:IsSetCard(0x301) and not c:IsImmuneToEffect(e)
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.attfilter1,tp,LOCATION_DECK,0,1,nil,e)
		and e:GetHandler():IsType(TYPE_XYZ) end
end
function s.attfilter2(c,e)
	return ((c:IsFaceup() and not c:IsType(TYPE_TOKEN)) or (c:IsLocation(LOCATION_GRAVE) and c:IsSetCard(0x301) and c:IsType(TYPE_SPELL+TYPE_TRAP))) and not c:IsImmuneToEffect(e)
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local exg=Duel.SelectMatchingCard(tp,s.attfilter1,tp,LOCATION_DECK,0,1,1,nil,e)
	if #exg==0 then return end
	Duel.Overlay(c,exg)
	--Attach 1 other card
	local g=Duel.GetMatchingGroup(s.attfilter2,tp,LOCATION_GRAVE,LOCATION_MZONE,c,e)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if not tc then return end
		Duel.HintSelection(tc,true)
		Duel.BreakEffect()
		Duel.Overlay(c,tc,true)
	end
end
--(3)Double ATK
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	return bc~=nil and bc:IsControler(1-tp) --and bc:GetAttack()~=bc:GetBaseAttack()
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL+RESET_CHAIN,0,1)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,c,1,tp,c:GetAttack())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(c:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		c:RegisterEffect(e1)
	end
end
--(4)ATK to 0
function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return e:GetHandler():GetOverlayCount()>=3 and ph==PHASE_DAMAGE_CAL
end
function s.atktg2(e,c)
	return c==e:GetHandler():GetBattleTarget()
end