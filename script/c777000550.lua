--Arknight - Exusiai
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--(2)Link Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end
--(1)Special Summon
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x289) and c:IsType(TYPE_LINK) and c:IsControler(tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
--(2)Link Summon 
function s.spfilter2(c,fg,minmat,maxmat)
	return  c:IsSetCard(0x289) and c:IsLinkBelow(3) and c:IsLinkSummonable(nil,fg,minmat,maxmat)
end
function s.rescon(sg,e,tp,mg)
	return Duel.GetMatchingGroupCount(s.spfilter2,tp,LOCATION_EXTRA,0,nil,sg,#sg,#sg)>0
end
function s.filtercheck(c,e,tp)
	return c:IsCanBeLinkMaterial() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0x289)
		and c:IsLocation(LOCATION_GRAVE)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	Duel.PayLPCost(tp,2000)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local fg=Duel.GetMatchingGroup(s.filtercheck,tp,LOCATION_GRAVE,0,nil,e,tp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if chk==0 then return ft>0 and Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_LINK)>0
		and aux.SelectUnselectGroup(fg,e,tp,1,ft,s.rescon,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local fg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filtercheck),tp,LOCATION_GRAVE,0,nil,e,tp)
	if ft<1 or not Duel.IsPlayerCanSpecialSummonCount(tp,2) then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local g=aux.SelectUnselectGroup(fg,e,tp,1,ft,s.rescon,1,tp,HINTMSG_SPSUMMON,s.rescon,nil,false)
	if not g or #g==0 then return end
	local c=e:GetHandler()
	for tc in aux.Next(g) do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
	Duel.SpecialSummonComplete()
	local tg=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA,0,nil,g,#g,#g)
	if #tg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=tg:Select(tp,1,1,nil)
		local sc=sg:GetFirst()
		Duel.LinkSummon(tp,sc,nil,g,#g,#g)
	end
end