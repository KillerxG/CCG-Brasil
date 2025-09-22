--Bestial Weapon Knuckle Hornet
--Bestial Weapon Knuckle Hornet
--by you
local s,id=GetID()
function s.initial_effect(c)
	--[E1] Procedimento Union (alvo: Guerreiro)
	aux.AddUnionProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR))

	--[E2] Substitui destruição do equipado
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)

	--[E3] Bônus de ATK/DEF enquanto equipado (+300 ATK / +600 DEF)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	local e3b=e3:Clone()
	e3b:SetCode(EFFECT_UPDATE_DEFENSE)
	e3b:SetValue(600)
	c:RegisterEffect(e3b)

	--[E4] Quando o equipado ataca OU vira alvo de ataque: devolve 1 monstro do oponente e 1 "Bestial Weapon" (seu campo/GY) à mão
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetCondition(s.bouncecon1)
	e4:SetTarget(s.bouncetg)
	e4:SetOperation(s.bounceop)
	c:RegisterEffect(e4)
	local e4b=e4:Clone()
	e4b:SetCode(EVENT_BE_BATTLE_TARGET)
	e4b:SetCondition(s.bouncecon2)
	c:RegisterEffect(e4b)

	--double tribute
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e5:SetValue(s.effcon)
	c:RegisterEffect(e5)

	--[E6] Normal/Special: busca OU Invoca Especial (1/turno)
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_SUMMON_SUCCESS)
	e6:SetCountLimit(1,id)
	e6:SetTarget(s.thsptg)
	e6:SetOperation(s.thspop)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e7)
end
-- Somente para monstros Guerreiro
function s.effcon(e,c)
	return c:IsRace(RACE_WARRIOR)
end
-- ===== E4: bounce ao atacar/ser atacado =====
function s.geteq(e) return e:GetHandler():GetEquipTarget() end
function s.bouncecon1(e,tp,eg,ep,ev,re,r,rp)
	local eq=s.geteq(e)
	return eq and Duel.GetAttacker()==eq
end
function s.bouncecon2(e,tp,eg,ep,ev,re,r,rp)
	local eq=s.geteq(e)
	return eq and Duel.GetAttackTarget()==eq
end
function s.bwfilter(c)
	return c:IsSetCard(0x102C) and c:IsAbleToHand()
end
function s.opponfilter(c) 
return c:IsControler(1-tp) and c:IsAbleToHand() 
end
function s.bouncetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		-- permite selecionar novamente os mesmos alvos na checagem
		if chkc:IsControler(1-tp) and chkc:IsOnField() then
			return chkc:IsAbleToHand()
		end
		if chkc:IsControler(tp) and chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) then
			return s.bwfilter(chkc)
		end
		return false
	end
	if chk==0 then
		return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil)
			and Duel.IsExistingTarget(s.bwfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g1=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g2=Duel.SelectTarget(tp,s.bwfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1+g2,0,0,0)
end
function s.bounceop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e) -- pega ambos os alvos que ainda estiverem válidos
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end

-- ===== E6: busca / Special Summon =====
local SWORDHUNTER=51345461
function s.pool(c)
	return c:IsSetCard(0x102C) or c:IsCode(SWORDHUNTER)
end
-- deck -> mão
function s.thfilter(c) return s.pool(c) and c:IsAbleToHand() end
-- deck/gy -> campo
function s.spfilter(c,e,tp)
	return s.pool(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and (Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
			or Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp))
	if chk==0 then return b1 or b2 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thspop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and (Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
			or Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp))
	if not (b1 or b2) then return end
	local op=0 -- 0=ADD, 1=SP
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif b2 then op=1 end

	if op==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	else
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g1=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g1==0 then
			g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		end
		if #g1>0 then
			Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
