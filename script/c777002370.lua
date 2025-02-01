--Jellycrew Helmsman
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	--(1)Draw
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.srcost)
	e1:SetTarget(s.srtg)
	e1:SetOperation(s.srop)
	c:RegisterEffect(e1)
    --(2)Tribute monsters
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_RELEASE)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.trtg)
	e2:SetOperation(s.trop)
	c:RegisterEffect(e2)
end
s.listed_names={777002340}
--(1)Draw
function s.srcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsType,1,true,nil,e:GetHandler(),TYPE_MONSTER) end
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsType,1,1,true,nil,e:GetHandler(),TYPE_MONSTER)
	Duel.Release(g,REASON_COST)
end
function s.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.filter(c)
	return c:IsRitualSpell() and c:IsAbleToHand()
end
function s.srop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)    
	Duel.BreakEffect()
    if Duel.IsExistingMatchingCard(Card.IsRitualMonster,tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
        if g:GetCount()>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end
--(2)Tribute monsters
function s.evilcond(c)
	return c:IsFaceup() and c:IsRitualMonster() and c:IsSetCard(0x293)
end
function s.trtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsReleasableByEffect() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsReleasableByEffect,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local fc=Duel.IsExistingMatchingCard(s.evilcond,tp,LOCATION_MZONE,0,1,nil)
	local ct=1
	if fc then ct=2 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectTarget(tp,Card.IsReleasableByEffect,tp,LOCATION_MZONE,LOCATION_MZONE,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,#g,0,0)
end
function s.trop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.Release(g,REASON_EFFECT)
	end
end