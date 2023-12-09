--Cheat Code Kuraishita
--Scripted by Imp
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon
	Link.AddProcedure(c,nil,2,3,s.lcheck)
	c:EnableReviveLimit()
	--Immune
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_EMZONE)
    e0:SetValue(aux.tgoval)
    c:RegisterEffect(e0)
    local e1=e0:Clone()
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetValue(aux.indoval)
    c:RegisterEffect(e1)
	--Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
--Link Summon
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0x352,lc,sumtype,tp)
end
--Destroy
function s.costfilter(c)
	return c:IsLinkMonster() and c:IsAbleToRemoveAsCost()
end
function s.spcheck(sg,tp,exg,dg)
	local a=0
	for c in aux.Next(sg) do
		if dg:IsContains(c) then a=a+1 end
		for tc in aux.Next(c:GetEquipGroup()) do
			if dg:IsContains(tc) then a=a+1 end
		end
	end
	return #dg-a>0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
	local sg=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #sg>0 and s.spcheck end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rmg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(rmg,nil,REASON_COST)
	local link=rmg:GetFirst():GetLink()
	e:SetLabel(link)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return true end
	local lnk=e:GetLabel()
	local dg=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,lnk,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetTargetCards(e)
	if #dg>0 then
		Duel.Destroy(dg,REASON_EFFECT)
	end
end