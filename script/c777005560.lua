--Dark Magician Girl of the Starry Sky
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials
	Fusion.AddProcMix(c,true,true,CARD_DARK_MAGICIAN_GIRL,aux.FilterBoolFunctionEx(Card.IsSetCard,0x254))
	c:AddMustBeFusionSummoned()
	--Special Summon this card (from your Extra Deck) by banishing the above materials from your field and/or GY
	Fusion.AddContactProc(c,s.contactfil,s.contactop,false,nil,1)
	--(1)Add 1 "Black and Purple Wave".
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--(2)Gains 300 ATK for each banished card
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(function() return Duel.GetFieldGroupCount(0,LOCATION_REMOVED,LOCATION_REMOVED)*300 end)
	c:RegisterEffect(e2)
	--(3)Destroy opponent's Card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+1)
	e3:SetCost(Cost.SelfBanish)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	--(4)Grant Effect to Lydia
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetCondition(function(e) return e:GetHandler():IsCode(777005330) end)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
s.listed_names={1784686}
--Special Summon this card (from your Extra Deck) by banishing the above materials from your field and/or GY
function s.contactfil(tp)
	local loc=LOCATION_MZONE|LOCATION_GRAVE
	if Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then loc=LOCATION_MZONE end
	return Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,loc,0,nil)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST|REASON_MATERIAL)
end
--(1)Add 1 "Black and Purple Wave".
function s.thfilter(c)
	return c:IsCode(777005550) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--(3)Destroy opponent's Card
function s.desfilter(c)
	return c:IsFaceup()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.desfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end