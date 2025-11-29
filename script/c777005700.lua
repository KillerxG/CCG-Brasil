--Magician Girl Call
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--(1)Search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)	
	--(2)Fusion Summon 1 Spellcaster Fusion Monster
	local e2=Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),matfilter=aux.FALSE,extrafil=s.fextra,extraop=Fusion.ShuffleMaterial,extratg=s.extratg})
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCost(Cost.SelfBanish)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_DARK_MAGICIAN_GIRL}
--(1)Search
function s.filter(c)
	return (c:ListsCode(CARD_DARK_MAGICIAN_GIRL) or c:IsSetCard(0x20a2))and not c:IsCode(id) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--(2)Fusion Summon 1 Spellcaster Fusion Monster
function s.fextrafil(c)
	return c:IsAbleToDeck() and (c:IsOnField() or c:IsFaceup())
end
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsCode,1,nil,CARD_DARK_MAGICIAN_GIRL)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(s.fextrafil),tp,LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_REMOVED,0,nil),s.fcheck
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_REMOVED)
end