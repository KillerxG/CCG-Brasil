--Cheat Code Kuraish
--Scripted by Imp
local s,id=GetID()
function s.initial_effect(c)
   	--Link Summon
	Link.AddProcedure(c,nil,2,2,s.lcheck)
	c:EnableReviveLimit()
	--Immune
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_EMZONE)
    e0:SetValue(1)
    c:RegisterEffect(e0)
	--Send to GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.tgcost)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
end
--Link Summon
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0x352,lc,sumtype,tp)
end
--Send to GY
function s.tgfilter(c)
	return c:IsSetCard(0x352) and c:IsAbleToGrave()
end
function s.cfilter(c,ct)
	return c:IsLinkMonster()and c:IsLinkBelow(ct) and c:IsAbleToRemoveAsCost()
end
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil):GetClassCount(Card.GetCode)
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,ct) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,ct):GetFirst()
	Duel.Remove(rc,POS_FACEUP,REASON_COST)
	e:SetLabel(rc:GetLink())
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,e:GetLabel(),tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,ct,ct,aux.dncheck,1,tp,HINTMSG_TOGRAVE)
	if #sg>0 then
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end