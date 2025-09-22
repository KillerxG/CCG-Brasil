--Bestial Weapon Blade Fish
local s,id=GetID()

-- ajustes de arquétipos
local SET_BESTIAL_WEAPON  = 0x102C  -- Bestial Weapon (4140)

function s.initial_effect(c)
	-- [E1] Procedimento Union (equipa em Guerreiro / desequipa e Invoca)
	aux.AddUnionProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR))

	-- [E2] Substituição de destruição do monstro equipado
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)

	-- [E3] Bônus enquanto equipado: +200 ATK / +500 DEF
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(700)
	c:RegisterEffect(e3)
	local e3b=e3:Clone()
	e3b:SetCode(EFFECT_UPDATE_DEFENSE)
	e3b:SetValue(500)
	c:RegisterEffect(e3b)

	-- [E4] Quando o equipado declara ataque: vira o alvo para DEF com a face para baixo e dá perfurante apenas nessa batalha
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_POSITION)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetCondition(s.poscon)
	e4:SetOperation(s.posop)
	c:RegisterEffect(e4)

	--double tribute
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e5:SetValue(s.effcon)
	c:RegisterEffect(e5)

	-- [E6] Se um "Bestial Warrior" é Invocado por Invocação-Normal/Especial:
	-- você pode imediatamente realizar Invocação-Normal da sua mão (Bestial Weapon OU Guerreiro),
	-- depois pode equipar aquele monstro com 1 "Bestial Weapon" da mão/Cemitério. (1/turno)
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_SUMMON+CATEGORY_EQUIP)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_SUMMON_SUCCESS)
	e6:SetRange(LOCATION_MZONE+LOCATION_SZONE)
	e6:SetCountLimit(1,id)
	e6:SetCondition(s.sumcon)
	e6:SetTarget(s.sumtg)
	e6:SetOperation(s.sumop)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e7)
end
-- Somente para monstros Guerreiro
function s.effcon(e,c)
	return c:IsRace(RACE_WARRIOR)
end
-- ========== E4 ==========
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	local eq=e:GetHandler():GetEquipTarget()
	return eq and Duel.GetAttacker()==eq and Duel.GetAttackTarget()~=nil
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not (a and d and d:IsRelateToBattle()) then return end
	if d:IsCanTurnSet() and Duel.ChangePosition(d,POS_FACEDOWN_DEFENSE)>0 then
		-- perfurante apenas para esta batalha
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		a:RegisterEffect(e1)
	end
end

-- ========== E6 ==========
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_BESTIAL_WEAPON) and c:IsSummonPlayer(tp)
end
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.handns_filter(c)
	return (c:IsSetCard(SET_BESTIAL_WEAPON) or c:IsRace(RACE_WARRIOR)) and c:IsSummonable(true,nil)
end
function s.eqfilter(c,tc)
	-- equipamos apenas se o monstro Invocado for Guerreiro (já que os "Bestial Weapon" equipam em Guerreiros)
	return c:IsSetCard(SET_BESTIAL_WEAPON) and c:IsType(TYPE_UNION)
		and tc:IsRace(RACE_WARRIOR)
		and (c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_GRAVE))
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.handns_filter,tp,LOCATION_HAND,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,s.handns_filter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	Duel.Summon(tp,tc,true,nil) -- Invocação-Normal
	-- opcional: equipar 1 "Bestial Weapon" da mão/GY ao monstro recém-invocado (se for Guerreiro)
	if not (tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup()) then return end
	if not tc:IsRace(RACE_WARRIOR) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(function(c) return s.eqfilter(c,tc) end),
		tp,LOCATION_HAND+LOCATION_GRAVE,0,0,1,nil)
	if #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		local ec=g2:GetFirst()
		Duel.Equip(tp,ec,tc)
		-- marca como Union equipado
		aux.SetUnionState(ec)
	end
end
