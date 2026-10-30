--.sol Ceremony
--Scripted by Codex
local s,id=GetID()
function s.initial_effect(c)
	--(1) Ritual Summon any Ritual Monster
	Ritual.AddProcGreater{handler=c,extrafil=s.extrafil,extraop=s.extraop,extratg=s.extratg}
	--(2) Add 1 Ritual Monster and this card from the GY to the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={0x248}
--(1) Ritual Summon any Ritual Monster
function s.deckmatfilter(c)
	return c:IsRitualMonster() and c:IsType(TYPE_PENDULUM) and c:HasLevel() and c:IsAbleToExtra()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.deckmatfilter,tp,LOCATION_DECK,0,nil)
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	local deckmat=mat:Filter(Card.IsLocation,nil,LOCATION_DECK)
	mat:Sub(deckmat)
	Duel.ReleaseRitualMaterial(mat)
	if #deckmat>0 then
		Duel.SendtoExtraP(deckmat,tp,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)
	end
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
--(2) Add 1 Ritual Monster and this card from the GY to the hand
function s.thfilter(c)
	return c:IsRitualMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,c):GetFirst()
	if not tc then return end
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) and c:IsRelateToEffect(e) and c:IsAbleToHand() then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
