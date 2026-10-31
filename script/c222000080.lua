local s, id = GetID()
local SET_PRYSM_BEAST = 0x100b 

function s.initial_effect(c)
	-- Efeito 1: Defender ataque, mudar posição e buffar DEF (Hand/Field)
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetCategory(CATEGORY_POSITION + CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND + LOCATION_MZONE)
	e1:SetCondition(s.poscon)
	e1:SetCost(s.poscost)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)

	-- Efeito 2: Colocar na S&T e Invocação-Normal extra
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 1))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetTarget(s.pctg)
	e2:SetOperation(s.pcop)
	c:RegisterEffect(e2)
end

-- ==========================================
-- Lógica: Defender o Ataque (Efeito 1)
-- ==========================================
function s.poscon(e, tp, eg, ep, ev, re, r, rp)
	local d = Duel.GetAttackTarget()
	-- Verifica se existe alvo de ataque, se é seu, se é Prysm Beast e se está virado para cima
	return d and d:IsControler(tp) and d:IsSetCard(SET_PRYSM_BEAST) and d:IsFaceup()
end

function s.poscost(e, tp, eg, ep, ev, re, r, rp, chk)
	local c = e:GetHandler()
	if chk == 0 then return c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c, REASON_COST)
end

function s.postg(e, tp, eg, ep, ev, re, r, rp, chk)
	local d = Duel.GetAttackTarget()
	-- Para poder mudar a posição (and if you do), o alvo precisa não estar em Defesa Face para Cima já
	if chk == 0 then return d and not d:IsPosition(POS_FACEUP_DEFENSE) end
	Duel.SetOperationInfo(0, CATEGORY_POSITION, d, 1, 0, 0)
end

function s.pbfilter(c)
	-- Filtra todas as cartas Prysm Beast com a face para cima no campo (S&T e MZONE)
	return c:IsFaceup() and c:IsSetCard(SET_PRYSM_BEAST)
end

function s.posop(e, tp, eg, ep, ev, re, r, rp)
	local d = Duel.GetAttackTarget()
	if not d or not d:IsRelateToBattle() or d:IsFacedown() then return end
	
	-- Muda para Posição de Defesa. "And if you do": se conseguir mudar, aplica o Buff!
	if Duel.ChangePosition(d, POS_FACEUP_DEFENSE) > 0 then
		local ct = Duel.GetMatchingGroupCount(s.pbfilter, tp, LOCATION_ONFIELD, 0, nil)
		if ct > 0 then
			local e1 = Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_DEFENSE)
			e1:SetValue(ct * 300)
			e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
			d:RegisterEffect(e1)
		end
	end
end

-- ==========================================
-- Lógica: Colocar na S&T e Invocação Normal (Efeito 2)
-- ==========================================
function s.pctg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 end
	Duel.SetPossibleOperationInfo(0, CATEGORY_SUMMON, nil, 1, tp, LOCATION_HAND)
end

function s.sumfilter(c)
	-- Verifica se a carta pode ser Invocada Normalmente (true permite ignorar limites do turno)
	return c:IsSetCard(SET_PRYSM_BEAST) and c:IsSummonable(true, nil)
end

function s.pcop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp, LOCATION_SZONE) <= 0 then return end
	
	-- Coloca a própria Emerald Tortoise na Zona S&T como Magia Contínua
	if Duel.MoveToField(c, tp, tp, LOCATION_SZONE, POS_FACEUP, true) then
		local e1 = Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL + TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
		
		-- Conjunção "and if you do": Checa se você tem monstros válidos e pergunta se deseja invocar
		if Duel.IsExistingMatchingCard(s.sumfilter, tp, LOCATION_HAND, 0, 1, nil) 
			and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
			
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SUMMON)
			local g = Duel.SelectMatchingCard(tp, s.sumfilter, tp, LOCATION_HAND, 0, 1, 1, nil)
			if #g > 0 then
				-- O 'true' diz para a engine que esta invocação não conta no limite de Normal Summons do turno
				Duel.Summon(tp, g:GetFirst(), true, nil)
			end
		end
	end
end