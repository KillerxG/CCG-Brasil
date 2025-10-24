--Elementale Stage
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--(2)Cannot Attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.atktarget)
	c:RegisterEffect(e2)
	--(3)Prevent effect target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.immtg)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	--(4)Allow Attack while in Defense
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DEFENSE_ATTACK)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.atktg)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
--(1)Search
function s.thfilter(c)
	return c:IsMonster() and c:IsSetCard(0x310) and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
--(2)Cannot Attack
function s.atktarget(e,c)
	return (c:GetLevel()>=4 and not c:IsCode(777003130)) or c:GetRank()>=1 or c:GetLink()>=1 
end
--(3)Prevent effect target
function s.immtg(e,c)
	return (c:IsSetCard(0x310) and c:IsFaceup()) or c:IsFacedown()
end
--(4)Allow Attack while in Defense
function s.atktg(e,c)
	return c:IsSetCard(0x310)
end