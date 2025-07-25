--Typeblood_Forsaken.lua 
--Scripted by Imp
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	--Xyz Summoning Procedure
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x660),4,2,s.ovfilter,aux.Stringid(id,0),Xyz.InfiniteMats)
	--Attach ("Typeblood_Lycanthrope.lua")
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,1))
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetRange(LOCATION_MZONE)
	e0:SetHintTiming(0,TIMING_END_PHASE)
	e0:SetCountLimit(1,id)
	e0:SetTarget(s.mttg)
	e0:SetOperation(s.mtop)
	c:RegisterEffect(e0)
	--Banish ("Typeblood_Lycanthrope.lua")
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id+1)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_QUICK_O)
	e2:SetCondition(function(e) return e:GetHandler():IsSetCard(0x660) end)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCondition(s.matcon)
	e3:SetOperation(s.matop)
	c:RegisterEffect(e3)
	--Negate ("Typeblood_Lycanthrope.lua")
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.negcon)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCondition(s.negcon2)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_BE_MATERIAL)
	e6:SetCondition(s.matcon)
	e6:SetOperation(s.matop2)
	c:RegisterEffect(e6)
end
--Xyz Summoning Procedure
function s.ovfilter(c,tp,sc)
	return c:IsSetCard(0x660,sc,SUMMON_TYPE_XYZ,tp) and c:IsFaceup() and not c:HasLevel()
end
--Attach ("Typeblood_Lycanthrope.lua")
function s.mtfilter(c,e)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN) and c:IsSetCard(0x660) and not c:IsImmuneToEffect(e)
end
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(s.mtfilter,tp,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,0,1,e:GetHandler(),e) end
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,s.mtfilter,tp,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,e:GetHandler(),e)
	local tc=g:GetFirst()
	if tc then
		Duel.Overlay(c,tc,true)
	end
end
--Banish ("Typeblood_Lycanthrope.lua")
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsMonsterEffect() and re:GetHandler():IsRelateToEffect(re)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x660) and c:IsType(TYPE_XYZ)
	and c:GetOverlayCount()>0
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) and rc:IsAbleToRemove() and not rc:IsLocation(LOCATION_REMOVED) end
	Duel.SetTargetCard(rc)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,rc:GetControler(),rc:GetLocation())
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)
	local xyzg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=xyzg:GetFirst()
	if not tc then return end
	Duel.HintSelection(xyzg)
	local mg=tc:GetOverlayGroup()
	local ct=#mg
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
	local sg=mg:Select(tp,1,1,nil)
	if #sg>0 and Duel.SendtoGrave(sg,REASON_EFFECT)>0
	and tc:GetOverlayCount()<ct then
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(e) then
		Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
	end
end
end
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	if not rc:IsSetCard(0x660) then return end
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,2))
	e7:SetCategory(CATEGORY_REMOVE)
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetCode(EVENT_CHAINING)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1,id+1)
	e7:SetCondition(s.rmcon)
	e7:SetTarget(s.rmtg)
	e7:SetOperation(s.rmop)
	rc:RegisterEffect(e7)
end
--Negate ("Typeblood_Lycanthrope.lua")
function s.xyzfilter2(c)
	return c:IsSetCard(0x660) and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0 and c:IsFaceup()
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.xyzfilter2,tp,LOCATION_MZONE,0,nil)
	return rp==1-tp and re:IsMonsterEffect() and Duel.IsChainDisablable(ev)
	and #g>0 and Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT,g)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
   local c=e:GetHandler()
   local g=Duel.GetMatchingGroup(s.xyzfilter2,tp,LOCATION_MZONE,0,nil)
	if (Duel.GetFlagEffect(tp,id)==0 and #g>0 and Duel.SelectEffectYesNo(tp,c)) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.Hint(HINT_CARD,0,id)
		Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_EFFECT,g)
		Duel.NegateEffect(ev)
	end
end
function s.negcon2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.xyzfilter2,tp,LOCATION_MZONE,0,nil)
	return rp==1-tp and re:IsMonsterEffect() and Duel.IsChainDisablable(ev)
		and #g>0 and Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT,g)
		and e:GetHandler():IsSetCard(0x660)
end
function s.matop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	if not rc:IsSetCard(0x660) then return end
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,3))
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_CHAIN_SOLVING)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCondition(s.negcon)
	e8:SetOperation(s.negop)
	rc:RegisterEffect(e8)
end