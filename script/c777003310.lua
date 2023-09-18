--Oceanic Storm Icy Pixie
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--(1)Increase ATK/DEF per multiples of 300
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.atkcost)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--(2)Special Summon S/T Zone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--(3)Special Summon Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1,id+1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	--(4)Special summon procedure (from hand)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SPSUMMON_PROC)
	e4:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e4:SetRange(LOCATION_HAND)
	e4:SetCondition(s.rtcon)
	e4:SetTarget(s.rttg)
	e4:SetOperation(s.rtop)
	c:RegisterEffect(e4)
	--(4.1)Special summon procedure (from hand) buffed
	local e5=e4:Clone()
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCondition(s.tdcon2)
	c:RegisterEffect(e5)
end
--(1)Increase ATK/DEF per multiples of 500
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(id)==0
		and Duel.CheckLPCost(tp,300) end
	local lp=Duel.GetLP(tp)
	local m=math.floor(math.min(lp,1500)/300)
	local t={}
	for i=1,m do
		t[i]=i*300
	end
	local ac=Duel.AnnounceNumber(tp,table.unpack(t))
	Duel.PayLPCost(tp,ac)
	e:SetLabel(ac)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()	
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(e:GetLabel())
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
end
--(2)Special Summon S/T Zone
function s.spfilter(c,e,sp)
	return (c:IsFaceup() and c:IsSetCard(0x312) and c:IsOriginalType(TYPE_MONSTER)) and c:IsCanBeSpecialSummoned(e,0,sp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
--(2)Special Summon Deck
function s.filter(c,e,tp)
	return c:IsSetCard(0x312) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
--(4)Special summon procedure (from hand)
function s.spfilter(c)
	return c:IsMonster() and c:IsReleasable() and c:IsLevelAbove(1) and c:HasLevel()
end
function s.rescon(sg,e,tp,mg)
	if #sg>1 then
		return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:GetSum(Card.GetLevel)>=4 and not sg:IsExists(Card.IsLevelAbove,1,nil,4)
	else
		return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:GetSum(Card.GetLevel)>=4
	end
end
function s.rtcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,e:GetHandler())
	return aux.SelectUnselectGroup(rg,e,tp,1,99,s.rescon,0)
end
function s.breakcon(sg,e,tp,mg)
	return sg:GetSum(Card.GetLevel)>=4
end
function s.rttg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,e:GetHandler())
	local mg=aux.SelectUnselectGroup(rg,e,tp,1,99,s.rescon,1,tp,HINTMSG_RELEASE,s.breakcon,s.breakcon,true)
	if #mg>0 then
		mg:KeepAlive()
		e:SetLabelObject(mg)
		return true
	end
	return false
end
function s.rtop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end
--(4.1)Enable other location if control boss
function s.tdcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,e:GetHandler())
	return aux.SelectUnselectGroup(rg,e,tp,1,99,s.rescon,0) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,777003320),tp,LOCATION_MZONE,0,1,nil)
	
end