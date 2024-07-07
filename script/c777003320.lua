--Captain of Oceanic Storm - Levy
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	c:EnableReviveLimit()
	--(1)Special Summon Condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(0)
	c:RegisterEffect(e0)
	--(2)Special Summon Procedure
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)	
	--(3)Special Summon WATER monster from Extra
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_PAY_LPCOST)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.sp2tg)
	e3:SetOperation(s.sp2op)
	c:RegisterEffect(e3)
	--(4)Opponent pays LP, Special Summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.xyzcon)
	e4:SetOperation(s.xyzop)
	c:RegisterEffect(e4)
	--(5)Destroy Replace
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTarget(s.reptg)
	e5:SetValue(s.repval)
	c:RegisterEffect(e5)
end
--(2)Special Summon Procedure
function s.spfilter(c)
	return c:IsMonster() and c:IsSetCard(0x312) and c:IsAbleToGraveAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,e:GetHandler())
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #rg>2 and aux.SelectUnselectGroup(rg,e,tp,3,3,nil,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=nil
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,c)
	local g=aux.SelectUnselectGroup(rg,e,tp,3,3,nil,1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST)
	g:DeleteGroup()
end
--(3)Special Summon WATER monster from Extra
function s.sp2filter(c,e,tp)
	return c:IsFacedown() and c:IsOriginalAttribute(ATTRIBUTE_WATER) and c:IsOriginalRace(RACE_AQUA+RACE_FISH+RACE_SEASERPENT) and Duel.GetLocationCountFromEx(tp,tp,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sp2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sp2filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.sp2op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_EXTRA,0,nil)==0 then return end
	Duel.ShuffleExtra(tp)
	Duel.ConfirmExtratop(tp,1)
	local tc=Duel.GetExtraTopGroup(tp,1):GetFirst()
	if tc then
		--If its a Fusion Monster
		if tc:IsType(TYPE_FUSION) and tc:IsOriginalRace(RACE_AQUA+RACE_FISH+RACE_SEASERPENT) and Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0 and tc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) then
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)					
		end
		--If its a Synchro Monster
		if tc:IsType(TYPE_SYNCHRO) and tc:IsOriginalRace(RACE_AQUA+RACE_FISH+RACE_SEASERPENT) and Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0 and tc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) then
			Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)			
		end
		--If its a Xyz Monster
		if tc:IsType(TYPE_XYZ) and tc:IsOriginalRace(RACE_AQUA+RACE_FISH+RACE_SEASERPENT) and Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0 and tc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) then
			Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)			
		end
		--If its a Link Monster
		if tc:IsLinkMonster() and tc:IsOriginalRace(RACE_AQUA+RACE_FISH+RACE_SEASERPENT) and Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0 and tc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false) then
			Duel.SpecialSummon(tc,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)
		end
		tc:CompleteProcedure()
	end
end
--(4)Opponent pays LP, Special Summon
function s.filter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:GetReasonPlayer()==1-tp and c:IsSetCard(0x312)
end
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,tp)
end
function s.sp3filter(c,e,tp)
	return (c:IsSetCard(0x312) or c:ListsCode(CARD_UMI)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.xyzfilter(c,e,tp)
	return c:IsSetCard(SET_GUNKAN) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local def=0
	local g=eg:Filter(s.filter,nil,tp)
	for tc in g:Iter() do
		if tc:GetPreviousDefenseOnField()<0 then def=0 end
		def=def+tc:GetPreviousDefenseOnField()
	end
	if not Duel.CheckLPCost(1-tp,def) then return end
	Duel.PayLPCost(1-tp,def)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.sp3filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local hc=Duel.SelectMatchingCard(tp,s.sp3filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
		if Duel.SpecialSummon(hc,0,tp,tp,false,false,POS_FACEUP)>0 then
			
		end
	end
end
--(5)Destroy Replace
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD)
		and c:IsSetCard(0x312) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and Duel.CheckLPCost(tp,800) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		Duel.PayLPCost(tp,800)
		return true
	else return false end
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end