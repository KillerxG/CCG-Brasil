local s, id = GetID()
local SET_PRYSM_BEAST = 0x100b 

function s.initial_effect(c)
	-- Efeito 1: Negar Ataque e Invocar da Mão (Hand Trap)
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Efeito 2: Colocar na Zona S&T e Mudar Posição
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetTarget(s.pctg)
	e2:SetOperation(s.pcop)
	c:RegisterEffect(e2)
end

-- ==========================================
-- Lógica: Negar Ataque e Invocar (Efeito 1)
-- ==========================================
function s.stfilter(c)
	-- Filtra Prysm Beasts na Zona de Magias e Armadilhas
	return c:IsFaceup() and c:IsSetCard(SET_PRYSM_BEAST)
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
	local at = Duel.GetAttacker()
	-- Se o ataque for seu, não pode ativar
	if at:IsControler(tp) then return false end
	
	local d = Duel.GetAttackTarget()
	if d then
		-- Condição A: O alvo do ataque é um Prysm Beast virado para cima no seu campo?
		return d:IsControler(tp) and d:IsSetCard(SET_PRYSM_BEAST) and d:IsFaceup()
	else
		-- Condição B: O ataque é direto E você possui um Prysm Beast na Zona de Magias e Armadilhas?
		return Duel.IsExistingMatchingCard(s.stfilter, tp, LOCATION_SZONE, 0, 1, nil)
	end
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	local c = e:GetHandler()
	if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
		and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	-- Se negar o ataque com sucesso, Invoca por Invocação-Especial
	if Duel.NegateAttack() and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
	end
end

-- ==========================================
-- Lógica: Colocar na S&T e Mudar Posição (Efeito 2)
-- ==========================================
function s.pctg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 end
	Duel.SetPossibleOperationInfo(0, CATEGORY_POSITION, nil, 1, 0, 0)
end

function s.posfilter(c)
	-- Filtra apenas monstros que estejam virados para cima em Posição de Ataque
	return c:IsFaceup() and c:IsAttackPos() and c:IsCanChangePosition()
end

function s.pcop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp, LOCATION_SZONE) <= 0 then return end
	
	-- Coloca o próprio Amber Mammoth na Zona S&T como Magia Contínua
	if Duel.MoveToField(c, tp, tp, LOCATION_SZONE, POS_FACEUP, true) then
		local e1 = Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL + TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
		
		-- Conjunção "and if you do": Checa se existem monstros virados em Posição de Ataque para mudar
		local g = Duel.GetMatchingGroup(s.posfilter, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
		if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_POSCHANGE)
			local sg = g:Select(tp, 1, 1, nil)
			Duel.ChangePosition(sg, POS_FACEUP_DEFENSE, POS_FACEDOWN_DEFENSE, POS_FACEUP_DEFENSE, POS_FACEUP_DEFENSE)
		end
	end
end