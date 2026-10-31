local s, id = GetID()
local SET_PRYSM_BEAST = 0x100b 

function s.initial_effect(c)
	-- Efeito 1: Batalhar -> Retornar para a mão e Ganhar ATK
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetCategory(CATEGORY_TOHAND + CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START) -- "No início da Etapa de Dano, se este card batalhar"
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)

	-- Efeito 2: Colocar na Zona S&T ao ser enviado ao Cemitério e Buff em Área
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetTarget(s.pctg)
	e2:SetOperation(s.pcop)
	c:RegisterEffect(e2)
end

-- ==========================================
-- Lógica: Batalhar (Não pode escolher a si mesmo)
-- ==========================================
function s.thfilter(c, ec)
	-- Filtra Prysm Beasts no campo que possam voltar para a mão, EXCETO a própria carta (ec)
	return c:IsFaceup() and c:IsSetCard(SET_PRYSM_BEAST) and c:IsAbleToHand()
		and (c:IsLocation(LOCATION_MZONE) or c:IsLocation(LOCATION_SZONE)) and c ~= ec
end

function s.atktg(e, tp, eg, ep, ev, re, r, rp, chk)
	local c = e:GetHandler()
	if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_MZONE + LOCATION_SZONE, 0, 1, nil, c) end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_MZONE + LOCATION_SZONE)
end

function s.atkop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RTOHAND)
	-- Passamos 'c' no final para que o filtro s.thfilter saiba quem deve excluir
	local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_MZONE + LOCATION_SZONE, 0, 1, 1, nil, c)
	
	if #g > 0 then
		local tc = g:GetFirst()
		-- Memoriza o ATK original do monstro ANTES de ele ir para a mão
		local atk = tc:GetBaseAttack()
		if atk < 0 then atk = 0 end 
		
		if Duel.SendtoHand(tc, nil, REASON_EFFECT) > 0 and tc:IsLocation(LOCATION_HAND) then
			-- "and if you do": Se retornou para a mão, o Topaz Tiger ganha aquele ATK memorizado
			if c:IsRelateToEffect(e) and c:IsFaceup() and atk > 0 then
				local e1 = Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(atk) 
				e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_BATTLE)
				c:RegisterEffect(e1)
			end
		end
	end
end
-- ==========================================
-- Lógica: Colocar na S&T e Buff de ATK (Efeito 2)
-- ==========================================
function s.pctg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 end
end

function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_PRYSM_BEAST)
end

function s.pcop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp, LOCATION_SZONE) <= 0 then return end
	
	-- Coloca o próprio Topaz Tiger na Zona S&T como Magia Contínua
	if Duel.MoveToField(c, tp, tp, LOCATION_SZONE, POS_FACEUP, true) then
		local e1 = Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL + TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
		
		-- Conjunção "and if you do": Conta S&Ts e aplica buff
		local ct = Duel.GetFieldGroupCount(tp, LOCATION_SZONE, 0)
		if ct > 0 then
			local g = Duel.GetMatchingGroup(s.atkfilter, tp, LOCATION_MZONE, 0, nil)
			for tc in aux.Next(g) do
				local e2 = Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_UPDATE_ATTACK)
				e2:SetValue(ct * 300)
				e2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
				tc:RegisterEffect(e2)
			end
		end
	end
end