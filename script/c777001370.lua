--King of Thunder Force - Zeus
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	--(1)Special Summon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.FALSE)
	c:RegisterEffect(e0)
	--(2)Special Summon itself from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--(3)Cannot be destroyed by battle by Level/Rank/Link Rating lower than itself
	local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetValue(s.indval)
    c:RegisterEffect(e2)
	--(4)Level up for Level 9 or lower "Thunder Force"
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_LVCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.lvupcon)
	e3:SetTarget(s.lvuptg)
	e3:SetOperation(s.lvupop)
	c:RegisterEffect(e3)
	--(5)Conduct next BP Twice
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TOSS_COIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(function(e,tp) return not Duel.IsPlayerAffectedByEffect(tp,EFFECT_BP_TWICE) end)
	e4:SetOperation(s.doublebattlephase)
	c:RegisterEffect(e4)
	--(6)Choose coin toss result
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(2)
	e5:SetCondition(s.coincon1)
	e5:SetOperation(s.coinop1)
	c:RegisterEffect(e5)
end
--(2)Special Summon itself from the hand
function s.selfspfilter(c)
	return c:IsSetCard(0x301) and c:IsMonster() and c:IsFaceup()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(s.selfspfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,nil)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>=3 and g:GetClassCount(Card.GetCode)>=3
end
--(3)Cannot be destroyed by battle by Level/Rank/Link Rating lower than itself
function s.indval(e,c)
    local tc=c
    if not tc or not tc:IsFaceup() then return false end    
    local rating=0
    if tc:IsType(TYPE_XYZ) then
        rating=tc:GetRank()
    elseif tc:IsType(TYPE_LINK) then
        rating=tc:GetLink()
    elseif tc:IsType(TYPE_MONSTER) and not tc:IsType(TYPE_XYZ+TYPE_LINK) then
        rating=tc:GetLevel()
    else
        return false
    end    
    return rating>0 and rating<e:GetHandler():GetLevel()
end
--(4)Level up for Level 9 or lower "Thunder Force"
function s.lvupcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(aux.NOT(Card.IsSummonPlayer),1,nil,tp)
end
function s.cfilter(c,tp)
    return c:IsControler(1-tp)
end
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.lvlfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x301) and c:GetLevel()>0 and c:GetLevel()<=9
end
function s.lvuptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.lvlfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.lvupop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.lvlfilter,tp,LOCATION_MZONE,0,nil)
    for tc in aux.Next(g) do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_LEVEL)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end
end
--(5)Conduct next BP Twice
function s.doublebattlephase(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,EFFECT_BP_TWICE) then return end
	local turn_ct=Duel.GetTurnCount()
	local ct=Duel.IsTurnPlayer(tp) and Duel.IsBattlePhase() and 2 or 1
	--You can conduct your next Battle Phase twice
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,5))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_BP_TWICE)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	e1:SetCondition(function() return ct==1 or Duel.GetTurnCount()~=turn_ct end)
	e1:SetReset(RESET_PHASE|PHASE_BATTLE|RESET_SELF_TURN,ct)
	Duel.RegisterEffect(e1,tp)
end
--(6)Choose coin toss result
function s.coincon1(e,tp,eg,ep,ev,re,r,rp)
	local ex,eg,et,cp,ct=Duel.GetOperationInfo(ev,CATEGORY_COIN)
	if ex and ct>0 then
		e:SetLabelObject(re)
		return true
	else return false end
end
function s.coinop1(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TOSS_COIN_NEGATE)
	e1:SetCondition(s.coincon2)
	e1:SetOperation(s.coinop2)
	e1:SetLabel(ev)
	e1:SetLabelObject(e:GetLabelObject())
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)
end
function s.coincon2(e,tp,eg,ep,ev,re,r,rp)
	return re==e:GetLabelObject() and Duel.GetCurrentChain()==e:GetLabel()
end
function s.coinop2(e,tp,eg,ep,ev,re,r,rp)
	local res={}
	for i=1,ev do
		table.insert(res,COIN_HEADS)
	end
	Duel.SetCoinResult(table.unpack(res))
end