--Cosmic Storm Gryphon
--Scripted by KillerxG 
local s,id=GetID() 
function s.initial_effect(c) 
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.mfilter,1,1)
	c:SetSPSummonOnce(id)
	--(1)Normal Summon 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(3,id)
	e1:SetCondition(s.gspcon)
	e1:SetTarget(s.gsptg)
	e1:SetOperation(s.gspop)
	c:RegisterEffect(e1)
	--(2)Cannot Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.sumlimit)
	c:RegisterEffect(e2)
 end 
s.listed_card_types={TYPE_GEMINI}
--(1)Normal Summon 
function s.gspconfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_GEMINI) and c:IsSummonPlayer(tp)
end
function s.gspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.gspconfilter,1,nil,tp) and e:GetHandler():GetSequence()>4
end
function s.filter(c)
	return c:IsType(TYPE_GEMINI) and c:IsSummonable(true,nil)
end
function s.gsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.gspop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end
--(2)Cannot Special Summon
function s.sumlimit(e,c)
	return not (c:IsType(TYPE_GEMINI) or c:ListsCardType(TYPE_GEMINI) 
		or c:IsCode(64463828) or c:IsCode(96029574) or c:IsCode(38026562))
end