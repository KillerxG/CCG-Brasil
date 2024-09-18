--Skarlet Warrior - Zayi
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,s.mfilter,s.mfilter2)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit,nil,nil,nil,false)
	--(1)ATK Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkup)
	c:RegisterEffect(e1)
	--(2)Decrease ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.atkdown)
	c:RegisterEffect(e2)
	--(3)Negated activated effects of GY monsters
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.discon)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	--(4)Pay or Destroy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.paycon)
	e4:SetOperation(s.payop)
	c:RegisterEffect(e4)
end
s.listed_card_types={TYPE_SPIRIT}
--Fusion Material
function s.mfilter(c,sc,st,tp)
	return c:IsAttribute(ATTRIBUTE_DARK,sc,st,tp) and c:IsType(TYPE_LINK,sc,st,tp)
end
function s.mfilter2(c,sc,st,tp)
	return c:IsOriginalAttribute(ATTRIBUTE_DARK,sc,st,tp)
end
--Contact Fusion
function s.matfilter(c,tp)
	return c:IsAbleToGraveAsCost() and (c:IsFaceup() or (c:IsType(TYPE_SPIRIT) and c:IsLocation(LOCATION_HAND)))
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil,tp)
end
function s.contactop(g)
	Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL)
end
--(1)ATK Up
function s.atkupfilter(c)
	return c:GetSequence()<5
end
function s.atkup(e,c)
	return Duel.GetMatchingGroupCount(s.atkupfilter,0,LOCATION_SZONE,LOCATION_SZONE,nil)*200
end
--(2)Decrease ATK
function s.atkdownfilter(c)
	return c:IsMonster() or c:IsSpellTrap()
end
function s.atkdown(e,c)
	return Duel.GetMatchingGroupCount(s.atkdownfilter,0,0,LOCATION_GRAVE,nil)*-200
end
--(3)Negated activated effects of GY monsters
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return rp==1-tp and (re:IsMonsterEffect() or re:IsSpellTrapEffect()) and loc==LOCATION_GRAVE
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
--(4)Pay or Destroy
function s.paycon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.GetTurnPlayer()==tp
end
function s.payop(e,tp,eg,ep,ev,re,r,rp)
  Duel.HintSelection(Group.FromCards(e:GetHandler()))
  if Duel.CheckLPCost(tp,1500) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
    Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
    Duel.PayLPCost(tp,1500)
  else
    Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,3))
    Duel.Destroy(e:GetHandler(),REASON_COST)
  end
end
