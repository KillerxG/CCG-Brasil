--Cheat Code Kuraish
--Scripted by Imp
local s,id=GetID()
function s.initial_effect(c)
    c:SetSPSummonOnce(id)
   	--Link Summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_CYBERSE),2,2)
	c:EnableReviveLimit()
	--Can treat "Cheat Code" monsters in your hand as Link Material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_EXTRA_MATERIAL)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_SET_AVAILABLE)
	e0:SetRange(LOCATION_EMZONE+LOCATION_REMOVED)
	e0:SetTargetRange(1,0)
	e0:SetCountLimit(1)
	e0:SetOperation(aux.TRUE)
	e0:SetValue(s.extraval)
	c:RegisterEffect(e0)
	--Send to GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
end
--Can treat "Cheat Code" monsters in your hand as Link Material
function s.matfilter(c)
	return c:IsSetCard(0x352) and c:IsMonster()
end
function s.extraval(chk,summon_type,e,...)
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or not (sc and sc:IsRace(RACE_CYBERSE)) then
			return Group.CreateGroup()
		else
			Duel.RegisterFlagEffect(tp,id,0,0,1)
			return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND,0,nil)
		end
	elseif chk==2 then
		Duel.ResetFlagEffect(e:GetHandlerPlayer(),id)
	end
end
--Send to GY
function s.ctfilter(c)
	return c:IsSetCard(0x352) and c:IsType(TYPE_FUSION) or c:IsType(TYPE_LINK)
end
function s.tgfilter(c)
	return c:IsSetCard(0x352) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(s.ctfilter,tp,LOCATION_MZONE,0,nil)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	if ct==0 or #g==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,aux.dncheck,1,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(sg,REASON_EFFECT)
end