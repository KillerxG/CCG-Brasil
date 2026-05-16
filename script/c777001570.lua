--Twilight Angel
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum Summon
	Pendulum.AddProcedure(c)
	--(1)Pendulum Effect
	--(1.1)Fusion Summon 1 Pendulum Fusion Monster
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsType,TYPE_PENDULUM),nil,s.fextra)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)	
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)	
	--(2)Monster Effects
	--(2.1)Special Summon this card from your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
--(1.1)Fusion Summon 1 Pendulum Fusion Monster
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_PZONE,0,nil)
end
--(2.1)Special Summon this card from your hand
function s.desfilter(c)
	return c:IsType(TYPE_PENDULUM) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD|LOCATION_HAND,0,c)
	if chk==0 then return #g>=1 and aux.SelectUnselectGroup(g,e,tp,1,1,aux.ChkfMMZ(1),0)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD|LOCATION_HAND,0,c)
	if #g<1 then return end
	local dg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_DESTROY)
	if #dg==1 and Duel.Destroy(dg,REASON_EFFECT)==1 and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		c:CompleteProcedure()
	end
end