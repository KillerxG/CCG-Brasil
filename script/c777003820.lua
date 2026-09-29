--Fatale Succubus - Isabella
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,nil,2,nil,nil,Xyz.InfiniteMats,nil,false,s.xyzcheck)
	--(1)Extra Ritual Material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE)
	e1:SetTarget(s.mttg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--(2)Add 1 "Fatale" card from your Deck to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e) return e:GetHandler():IsXyzSummoned() end)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--(3)Attach opponent's monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	--(4)Attach monsters from your opponent's Extra Deck as material
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.ovcon)
	e4:SetCost(s.ovcost)
	e4:SetOperation(s.ovop)
	c:RegisterEffect(e4)
end
s.listed_names={777003750}
--Xyz Summon
function s.xyzcheck(g,tp)
  local mg=g:Filter(function(c) return not c:IsHasEffect(511001175) end,nil)
  return mg:GetClassCount(Card.GetDefense)==1 
end
--(1)Extra Ritual Material
function s.mttg(e,c)
	return e:GetHandler():GetOverlayGroup():IsContains(c)
end
--(2)Add 1 "Fatale" card from your Deck to your hand
function s.thfilter(c)
	return c:IsSetCard(0x286) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--(3)Attach opponent's monster
function s.filter(c,tp)
	return c:IsPosition(POS_FACEUP) and not c:IsType(TYPE_TOKEN) and c:IsAbleToChangeControler()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(c,tc,true)
	end
end
--(4)Attach monsters from your opponent's Extra Deck as material
function s.lilithfilter(c)
	return c:IsFaceup() and c:IsCode(777003750)
end
function s.ovcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.lilithfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.ovfilter(c)
	return c:IsMonster()
end
function s.ovrescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)==#sg
end
function s.ovcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=c:GetOverlayCount()
	local g=Duel.GetMatchingGroup(s.ovfilter,tp,0,LOCATION_EXTRA,nil)
	if chk==0 then
		return ct>0 and aux.SelectUnselectGroup(g,e,tp,ct,ct,s.ovrescon,0)
	end
	e:SetLabel(ct)
	Duel.SendtoGrave(c:GetOverlayGroup(),REASON_COST)
end
function s.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
	local ct=e:GetLabel()
	local g=Duel.GetMatchingGroup(s.ovfilter,tp,0,LOCATION_EXTRA,nil)
	if not aux.SelectUnselectGroup(g,e,tp,ct,ct,s.ovrescon,0) then return end
	Duel.ConfirmCards(tp,g)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local sg=aux.SelectUnselectGroup(g,e,tp,ct,ct,s.ovrescon,1,tp,HINTMSG_XMATERIAL)
	if #sg>0 then
		Duel.Overlay(c,sg)
	end
end