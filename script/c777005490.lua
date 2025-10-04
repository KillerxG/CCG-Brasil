--Forest Legion Conjuration
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--(1)Special Summon Token
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.sptkcon)
	e1:SetTarget(s.sptktg)
	e1:SetOperation(s.sptkop)
	c:RegisterEffect(e1)
	--(2)Excavate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
--(1)Activate
function s.confilter(c)
	return c:IsTrap() or c:IsMonster()
end
function s.sptkcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_GRAVE,0,1,nil)
end
function s.sptktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,777005485,0,TYPES_TOKEN,500,500,2,RACE_PLANT,ATTRIBUTE_EARTH,POS_FACEUP) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.sptkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,777005485,0,TYPES_TOKEN,500,500,0,RACE_PLANT,ATTRIBUTE_EARTH,POS_FACEUP) then
		local token=Duel.CreateToken(tp,777005485)
		if Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP) then
		local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,0x255),tp,LOCATION_MZONE,0,nil)
			for tc in aux.Next(g) do
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(500)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
		end
	end
end
--(2)Excavate
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>3 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c)
	return c:IsSetCard(0x255) and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<4 then return end
	Duel.ConfirmDecktop(tp,4)
	local g=Duel.GetDecktopGroup(tp,4):Match(s.thfilter,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
	Duel.ShuffleDeck(tp)
end