--Naikardian's Invasion
--Scripted by Codex
local s,id=GetID()
function s.initial_effect(c)
	--(1)Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_series={0x317}

--(1)Activate 1 of these effects
function s.ritfilter(c)
	return c:IsSetCard(0x317)
end
function s.nmfilter(c,e,tp,rc)
	return c:IsType(TYPE_NORMAL) and rc:ListsCode(c:GetCode())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.revfilter(c,e,tp)
	return c:IsSetCard(0x317) and c:IsType(TYPE_RITUAL) and not c:IsPublic()
		and Duel.IsExistingMatchingCard(s.nmfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local params={lvtype=RITPROC_GREATER,filter=s.ritfilter}
	local b1=not Duel.HasFlagEffect(tp,id)
		and Ritual.Target(params)(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=not Duel.HasFlagEffect(tp,id+1) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	elseif op==2 then
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local rc=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
		Duel.ConfirmCards(1-tp,rc)
		Duel.ShuffleHand(tp)
		e:SetLabelObject(rc)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
		Duel.SetPossibleOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,rc,1,tp,LOCATION_HAND)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		local params={lvtype=RITPROC_GREATER,filter=s.ritfilter}
		Ritual.Operation(params)(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		local rc=e:GetLabelObject()
		if not rc or not rc:IsLocation(LOCATION_HAND) or not rc:IsControler(tp)
			or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local nc=Duel.SelectMatchingCard(tp,s.nmfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,rc):GetFirst()
		if not nc or Duel.SpecialSummon(nc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		local params={
			lvtype=RITPROC_GREATER,
			filter=function(c) return c==rc end,
			forcedselection=function(e,tp,g,sc) return g:IsContains(nc) end
		}
		if Ritual.Target(params)(e,tp,eg,ep,ev,re,r,rp,0)
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Ritual.Operation(params)(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end
