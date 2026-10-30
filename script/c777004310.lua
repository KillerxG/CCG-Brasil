--.sol Gunner
--Scripted by Codex
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	c:EnableUnsummonable()
	--(1) Destroy all Spells/Traps, then place 2 Ritual Pendulum Monsters in the Pendulum Zones
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--(2) Must be Ritual or Pendulum Summoned
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_REVIVE_LIMIT)
	e2:SetCondition(s.revcon)
	c:RegisterEffect(e2)
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_SINGLE)
	e2b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2b:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2b:SetValue(s.splimit)
	c:RegisterEffect(e2b)
	--(3) Can be used as the entire requirement
	Ritual.AddWholeLevelTribute(c,aux.TRUE)
	--(4) Draw 2 cards, then discard 1 card if Tributed
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_RELEASE)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.drtg)
	e4:SetOperation(s.drop)
	c:RegisterEffect(e4)
	--(5) ATK Up
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetRange(LOCATION_PZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(function(_,c) return c:IsRitualMonster() end)
	e5:SetValue(function(_,c) return c:GetLevel()*100 end)
	c:RegisterEffect(e5)
end
s.listed_names={777004290}
s.listed_series={0x248}
--(1) Destroy all Spells/Traps, then place 2 Ritual Pendulum Monsters in the Pendulum Zones
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.pzfilter(c)
	return c:IsSetCard(0x248) and c:IsType(TYPE_RITUAL) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
		and (not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup())
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if Duel.Destroy(g,REASON_EFFECT)==0 or not (Duel.CheckLocation(tp,LOCATION_PZONE,0) and Duel.CheckLocation(tp,LOCATION_PZONE,1))
		or not Duel.IsExistingMatchingCard(s.pzfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_EXTRA,0,2,nil)
		or not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local sg=Duel.SelectMatchingCard(tp,s.pzfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_EXTRA,0,2,2,nil)
	if #sg~=2 then return end
	Duel.MoveToField(sg:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	Duel.MoveToField(sg:GetNext(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
end
--(2) Must be Ritual or Pendulum Summoned
function s.revcon(e)
	return not e:GetHandler():IsLocation(LOCATION_HAND|LOCATION_EXTRA)
end
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL or (st&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
--(3) Can be used as the entire requirement
--Handled by Ritual.AddWholeLevelTribute
--(4) Draw 2 cards, then discard 1 card if Tributed
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetPossibleOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,ct=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,ct,REASON_EFFECT)==ct then
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT|REASON_DISCARD)
	end
end
