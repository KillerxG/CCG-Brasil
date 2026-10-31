local s, id = GetID()
local SET_PRYSM_BEAST = 0x100b 

function s.initial_effect(c)
	-- Efeito 1: Dar alvo no campo, retornar para a mão e enviar para o GY (Efeito Rápido)
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetCategory(CATEGORY_TOHAND + CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET) 
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER + TIMING_END_PHASE)
	e1:SetCountLimit(1, id) -- HOPT mantido apenas neste efeito!
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- Efeito 2: Colocar na Zona S&T ao ser enviado ao Cemitério e Arrumar o Topo
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 1))
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetTarget(s.pctg)
	e2:SetOperation(s.pcop)
	c:RegisterEffect(e2)
end

-- ==========================================
-- Lógica: Efeito Rápido (Alvo, Retornar e Enviar para o GY)
-- ==========================================
function s.thfilter(c, tp)
	return c:IsFaceup() and c:IsSetCard(SET_PRYSM_BEAST) and c:IsAbleToHand()
		and (c:IsLocation(LOCATION_MZONE) or c:IsLocation(LOCATION_SZONE))
		-- Garante que exista um monstro no Deck com nome diferente que possa ir pro GY
		and Duel.IsExistingMatchingCard(s.tgfilter, tp, LOCATION_DECK, 0, 1, nil, c:GetCode())
end

function s.tgfilter(c, code)
	return c:IsSetCard(SET_PRYSM_BEAST) and c:IsMonster() and not c:IsCode(code) and c:IsAbleToGrave()
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE + LOCATION_SZONE) and s.thfilter(chkc, tp) end
	if chk == 0 then return Duel.IsExistingTarget(s.thfilter, tp, LOCATION_MZONE + LOCATION_SZONE, 0, 1, nil, tp) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RTOHAND)
	local g = Duel.SelectTarget(tp, s.thfilter, tp, LOCATION_MZONE + LOCATION_SZONE, 0, 1, 1, nil, tp)
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, tp, LOCATION_MZONE + LOCATION_SZONE)
	Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local code = tc:GetCode()
		-- Devolve para a mão e, se tiver sucesso...
		if Duel.SendtoHand(tc, nil, REASON_EFFECT) > 0 and tc:IsLocation(LOCATION_HAND) then
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
			-- ...Seleciona e envia 1 Fera Prisma diferente do Deck pro Cemitério!
			local g = Duel.SelectMatchingCard(tp, s.tgfilter, tp, LOCATION_DECK, 0, 1, 1, nil, code)
			if #g > 0 then
				Duel.SendtoGrave(g, REASON_EFFECT)
			end
		end
	end
end

-- ==========================================
-- Lógica: Colocar na S&T e Arrumar Topo
-- ==========================================
function s.pctg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 end
end

function s.tdfilter(c)
	-- Garante que a carta seja do arquétipo e esteja no Deck ou no Cemitério
	return c:IsSetCard(SET_PRYSM_BEAST) 
		and (c:IsLocation(LOCATION_DECK) or (c:IsLocation(LOCATION_GRAVE) and c:IsAbleToDeck()))
end

function s.pcop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp, LOCATION_SZONE) <= 0 then return end
	
	-- Coloca o próprio Cobalt Eagle na Zona S&T como Magia Contínua
	if Duel.MoveToField(c, tp, tp, LOCATION_SZONE, POS_FACEUP, true) then
		local e1 = Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL + TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
		
		-- Conjunção "and if you do": Checa se quer arrumar o topo
		local g = Duel.GetMatchingGroup(s.tdfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, nil)
		if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
			local sg = g:Select(tp, 1, 1, nil)
			local tc = sg:GetFirst()
			if tc then
				-- Se a carta estiver no Cemitério, envia para o Topo do Deck normalmente
				if tc:IsLocation(LOCATION_GRAVE) then
					Duel.SendtoDeck(tc, nil, SEQ_DECKTOP, REASON_EFFECT)
				
				-- Se a carta JÁ estiver no Deck, a engine exige que embaralhe antes de colocar no topo!
				else
					Duel.ShuffleDeck(tp)
					Duel.MoveSequence(tc, SEQ_DECKTOP)
					Duel.ConfirmDecktop(tp, 1)
				end
			end
		end
	end
end