--West Royal Dragon - Devil Irya
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Summon
	Fusion.AddProcMix(c,true,true,777003710,777003750)
	--(1)Change Name
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(777003710)
	c:RegisterEffect(e1)
	--(3)ATK Down
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(s.atktg2)
	e3:SetValue(-1000)
	c:RegisterEffect(e3)
	--(4)Destroy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)	
end
s.listed_names={777003710,777003750}
--Fusion Summon procedure
function s.matfilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_DRAGON,fc,sumtype,tp) and c:IsLevelAbove(6)
end
--(3)ATK Down
function s.atktg2(e,c)
	return c:IsFaceup() and not e:GetHandler():GetColumnGroup():IsContains(c)
end
--(4)Destroy
function s.desfilter(c,g)
	return g:IsContains(c)
end
function s.desfilter2(c,s,p)
	local seq=c:GetSequence()
	return seq<5 and c:IsControler(p) and math.abs(seq-s)==1
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,c:GetColumnGroup())
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lg=c:GetColumnGroup()
	if c:IsRelateToEffect(e) then
		local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,lg)
		if #g==0 then return end
		Duel.BreakEffect()
		local tc=nil
		if #g==1 then
			tc=g:GetFirst()
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			tc=g:Select(tp,1,1,nil):GetFirst()
		end
		local seq=tc:GetSequence()
		local dg=Group.CreateGroup()
		if seq<5 then dg=Duel.GetMatchingGroup(s.desfilter2,tp,0,LOCATION_MZONE,nil,seq,tc:GetControler()) end
		if Duel.Destroy(tc,REASON_EFFECT)~=0 and #dg>0 then
			if Duel.Destroy(dg,REASON_EFFECT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then 
				Duel.MoveSequence(e:GetHandler(),math.log(Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0),2))
			end			
		end
	end
end