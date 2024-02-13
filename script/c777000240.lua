--Azur Lane - Shinano
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--XYZ Materials
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,s.xyzfilter,nil,2,nil,nil,nil,nil,false,s.xyzcheck)
	--(1)Special Summon 1 "Azur Lane" monster from the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--(2)Make the opponent send 1 card to GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.gycon)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)	
end
--XYZ Materials
function s.xyzfilter(c,xyz,sumtype,tp)
    return c:HasLevel() and c:IsSetCard(0x283)
end
function s.xyzcheck(g,tp,xyz)
    local mg=g:Filter(function(c) return not c:IsHasEffect(511001175) end,nil)
    return #mg==2 and math.abs(mg:GetFirst():GetLevel()-mg:GetNext():GetLevel())==3
end
--(1)Special Summon 1 "Azur Lane" monster from the GY
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x283) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
--(2)Make the opponent send 1 card to GY
function s.group(seq,tp)
	local g=Group.CreateGroup()
	local function optadd(loc,seq,player)
		if not player then player=tp end
		local c=Duel.GetFieldCard(player,loc,seq)
		if c then g:AddCard(c) end
	end
	if seq+1<=4 then optadd(LOCATION_MZONE,seq+1) end
	if seq-1>=0 then optadd(LOCATION_MZONE,seq-1) end
	if seq<5 then
		optadd(LOCATION_SZONE,seq)
		if seq==1 then
			optadd(LOCATION_MZONE,5)
			optadd(LOCATION_MZONE,6,1-tp)
		end
		if seq==3 then
			optadd(LOCATION_MZONE,6)
			optadd(LOCATION_MZONE,5,1-tp)
		end
	elseif seq==5 then
		optadd(LOCATION_MZONE,1)
		optadd(LOCATION_MZONE,3,1-tp)
	elseif seq==6 then
		optadd(LOCATION_MZONE,3)
		optadd(LOCATION_MZONE,1,1-tp)
	end
	return g
end
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsLocation(LOCATION_GRAVE) 
end
function s.gyfilter(c,tp)
	return #(s.group(c:GetSequence(),1-tp))>0
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MMZONE) and s.gyfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.gyfilter,tp,0,LOCATION_MMZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.gyfilter,tp,0,LOCATION_MMZONE,1,1,nil,tp)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local g=s.group(tc:GetSequence(),1-tp)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
			local sg=g:Select(1-tp,1,1,nil)
			Duel.HintSelection(sg,true)
			Duel.SendtoGrave(sg,REASON_RULE,PLAYER_NONE,1-tp)
		end
	end
end