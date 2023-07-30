--Okami - Lechku and Nechku
--Scripted by Leonardofake
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x444),4,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
	c:EnableReviveLimit()
	--(1)Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--(2)Effect Gain
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsCode,444000000))
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetCondition(s.mtcon)
	e2:SetOperation(s.mtop)
	e2:SetValue(s.defval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetValue(s.defval2)
	c:RegisterEffect(e3)
end
--Xyz Summon
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSetCard(0x444,lc,SUMMON_TYPE_XYZ,tp) and c:HasLevel()
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	return true
end
--(1)Special Summon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ch=Duel.GetCurrentChain(true)-1
	if ch<=0 then return false end
	local cplayer=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_CONTROLER)
	local ceff=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_EFFECT)
	if re:GetHandler():IsDisabled() or not Duel.IsChainDisablable(ev) then return false end
	return ep==1-tp and cplayer==tp and ceff:GetHandler():IsSetCard(0x444) and ceff:GetHandler():IsMonster()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsXyzSummonable() end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsXyzSummonable() then
		Duel.XyzSummon(tp,c,nil)
	end
end
--(2)Effect Gain
function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSetCard()==0x444 and c:IsType(TYPE_XYZ)
end
function s.deffilter(c)
	return (c:IsSpell() or c:IsTrap())
end
function s.defval(e,c)
	return Duel.GetMatchingGroupCount(s.deffilter,c:GetControler(),LOCATION_GRAVE,LOCATION_GRAVE,nil)*100
end
function s.deffilter2(c)
	return (c:IsSpell() or c:IsTrap()) and c:IsSetCard(0x444) and c:IsFaceup()
end
function s.defval2(e,c)
	return Duel.GetMatchingGroupCount(s.deffilter2,c:GetControler(),LOCATION_REMOVED,LOCATION_REMOVED,nil)*200
end 
