--Cheat Code Talker
--Scripted by Imp
local s,id=GetID()
function s.initial_effect(c)
    --Link Summon
	Link.AddProcedure(c,nil,2,3,s.lcheck)
	c:EnableReviveLimit()
    --Increase ATK
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_UPDATE_ATTACK)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_EMZONE)
	e0:SetValue(s.atkval)
	c:RegisterEffect(e0)
    --Set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
end
--Link Summon
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsRace,1,nil,RACE_CYBERSE,lc,sumtype,tp)
end
 --Increase ATK
function s.atkval(e,c)
	return c:GetLinkedGroup():FilterCount(aux.FilterBoolFunction(Card.IsMonster),nil)*500
end
--Set
function s.setfilter(c)
	return (c:IsSetCard(0x352) or c:IsSetCard(0x118) and c:IsSpellTrap()) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end