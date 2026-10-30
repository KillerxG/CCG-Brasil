--.sol Sorceress
--Scripted by Codex
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	c:EnableUnsummonable()
	--(1) Ritual Monsters cannot be destroyed by the opponent's card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.indtg)
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	--(2) Use 1 non-Pendulum monster from the Extra Deck as Ritual Material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetTargetRange(LOCATION_EXTRA,0)
	e2:SetCondition(function(e) return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)==0 end)
	e2:SetTarget(s.mattg)
	e2:SetValue(1)
	e2:SetLabelObject({s.matcheck})
	c:RegisterEffect(e2)
	--(3) Must be Ritual or Pendulum Summoned
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_REVIVE_LIMIT)
	e3:SetCondition(s.revcon)
	c:RegisterEffect(e3)
	local e3b=Effect.CreateEffect(c)
	e3b:SetType(EFFECT_TYPE_SINGLE)
	e3b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3b:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3b:SetValue(s.splimit)
	c:RegisterEffect(e3b)
	--(4) Can be used as the entire requirement
	Ritual.AddWholeLevelTribute(c,aux.TRUE)
	--(5) Add this card and 1 .sol card from the Deck to the hand
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_EXTRA)
	e5:SetCountLimit(1,{id,1})
	e5:SetCondition(s.thcon)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
end
s.listed_series={0x248}
s.listed_names={777004290}
--(1) Ritual Monsters cannot be destroyed by the opponent's card effects
function s.indtg(e,c)
	return c:IsType(TYPE_RITUAL)
end
--(2) Use 1 non-Pendulum monster from the Extra Deck as Ritual Material
function s.mattg(e,c)
	return c:IsMonster() and not c:IsType(TYPE_PENDULUM) and c:HasLevel() and c:IsAbleToGrave()
end
function s.matcheck(e,tp,sg,rc)
	local ct=sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
	return ct<=1,ct>1
end
--(3) Must be Ritual or Pendulum Summoned
function s.revcon(e)
	return not e:GetHandler():IsLocation(LOCATION_HAND|LOCATION_EXTRA)
end
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL or (st&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
--(4) Can be used as the entire requirement
--Handled by Ritual.AddWholeLevelTribute
--(5) Add this card and 1 .sol card from the Deck to the hand
function s.thcon(e)
	return e:GetHandler():IsFaceup()
end
function s.thfilter(c)
	return c:IsSetCard(0x248) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.SendtoHand(c,nil,REASON_EFFECT)==0 or not c:IsLocation(LOCATION_HAND) then return end
	if not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) or not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then Duel.ConfirmCards(1-tp,tc) end
end
