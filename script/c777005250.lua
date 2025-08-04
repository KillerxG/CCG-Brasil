--MonGal Flesh Altar
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--(1)Ritual Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_names={777005190}
--(1)Ritual Summon
function s.deckmatfilter(c)
	return c:IsCode(777005230) and c:IsReleasableByEffect()
end
function s.extragroup(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.deckmatfilter,tp,LOCATION_DECK,0,nil)
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_DECK)
	mat:Sub(mat2)
	Duel.ReleaseRitualMaterial(mat)
	Duel.SendtoGrave(mat2,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL|REASON_RELEASE)
end
function s.tributelimit(e,tp,g,sc)
	return #g<=3,#g>3
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local params1={lvtype=RITPROC_EQUAL,filter=aux.FilterBoolFunction(Card.IsCode,777005190),location=LOCATION_DECK,matfilter=aux.FilterBoolFunction(Card.IsRace,RACE_FIEND)}
	local params2={lvtype=RITPROC_EQUAL,filter=aux.FilterBoolFunction(Card.IsCode,777005190),matfilter=aux.FilterBoolFunction(Card.IsRace,RACE_FIEND),extrafil=s.extragroup,extraop=s.extraop,forcedselection=s.tributelimit}
	local b1=not Duel.HasFlagEffect(tp,id) and Ritual.Target(params1)(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=not Duel.HasFlagEffect(tp,id+1) and Ritual.Target(params2)(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,1)},
			{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
		Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
	elseif op==2 then
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
		Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_DECK)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		local params1={lvtype=RITPROC_EQUAL,filter=aux.FilterBoolFunction(Card.IsCode,777005190),location=LOCATION_DECK,matfilter=aux.FilterBoolFunction(Card.IsRace,RACE_FIEND)}
		Ritual.Operation(params1)(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		local params2={lvtype=RITPROC_EQUAL,filter=aux.FilterBoolFunction(Card.IsCode,777005190),matfilter=aux.FilterBoolFunction(Card.IsRace,RACE_FIEND),extrafil=s.extragroup,extraop=s.extraop,forcedselection=s.tributelimit}
		Ritual.Operation(params2)(e,tp,eg,ep,ev,re,r,rp)
	end
end
