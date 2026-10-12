--Spectral Hunter Spectros
--Scripted by Codex
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon procedure
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),7,2)
	c:EnableReviveLimit()
	--"Spectral Hunter" Traps can be activated the turn they were Set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetTarget(s.acttarget)
	c:RegisterEffect(e1)
	--Detach 1 material, then Set 1 "Spectral Hunter" monster from the Deck or GY as a Trap
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.setcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	--Banish 1 other "Spectral Hunter" monster, then Set this card as a Trap
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_LEAVE_GRAVE|CATEGORY_SET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.selfsetcost)
	e3:SetTarget(s.selfsettg)
	e3:SetOperation(s.selfsetop)
	c:RegisterEffect(e3)
	--Special Summon this card, attach 1 target, and Set the other target as a Trap
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_SET)
	e4:SetType(EFFECT_TYPE_ACTIVATE|EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.listed_series={0x250}

function s.acttarget(e,c)
	return c:IsSetCard(0x250) and c:IsTrap()
end

function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.setfilter(c)
	return c:IsSetCard(0x250) and c:IsMonster()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local f=aux.NecroValleyFilter(s.setfilter)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(f,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local f=aux.NecroValleyFilter(s.setfilter)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,f,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if not tc or not Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEDOWN,true) then return end
	if tc:IsPreviousLocation(LOCATION_DECK) then
		Duel.ConfirmCards(1-tp,tc)
	end
	s.register_trap_effect(tc)
end

function s.selfsetcostfilter(c)
	return c:IsSetCard(0x250) and c:IsMonster() and c:IsAbleToRemoveAsCost()
end
function s.selfsetcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.selfsetcostfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,s.selfsetcostfilter,tp,LOCATION_GRAVE,0,1,1,c):GetFirst()
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
end
function s.selfsettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SET,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
function s.selfsetop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0
		or not Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEDOWN,true) then return end
	s.register_trap_effect(c)
	--It can be activated this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e1)
end

function s.register_trap_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetValue(TYPE_TRAP)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e1)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFacedown() and c:IsType(TYPE_TRAP)
		and (not c:IsStatus(STATUS_SET_TURN) or c:IsHasEffect(EFFECT_TRAP_ACT_IN_SET_TURN))
end
function s.tgfilter(c,e)
	return not c:IsType(TYPE_TOKEN) and c:IsCanBeEffectTarget(e)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc,e) end
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_MZONE,2,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_MZONE,2,2,nil,e)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SET,g,1,1-tp,LOCATION_MZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e)
		or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local g=Duel.GetTargetCards(e):Filter(function(tc,e)
		return tc:IsLocation(LOCATION_MZONE) and not tc:IsImmuneToEffect(e)
	end,nil,e)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local oc=g:Select(tp,1,1,nil):GetFirst()
	if not oc then return end
	Duel.Overlay(c,oc,true)
	local tc=(g-oc):GetFirst()
	if tc and Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0
		and Duel.MoveToField(tc,tp,1-tp,LOCATION_SZONE,POS_FACEDOWN,true) then
		s.register_trap_effect(tc)
	end
end
