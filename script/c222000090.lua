local s, id = GetID()
local SET_PRYSM_BEAST = 0x100b 

function s.initial_effect(c)
	-- Efeito 1: Enviar para o Cemitério e Atacar Duas Vezes (Fase Principal)
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1, id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)

	-- Efeito 2: Colocar na Zona S&T ao ser enviado ao Cemitério e Destruir
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetTarget(s.pctg)
	e2:SetOperation(s.pcop)
	c:RegisterEffect(e2)
end

-- ==========================================
-- Lógica: Enviar para o GY e Atacar Duas Vezes (Efeito 1)
-- ==========================================
function s.tgfilter(c)
	-- Permite enviar Cartas Fera Prisma da mão ou do Baralho
	return c:IsSetCard(SET_PRYSM_BEAST) and c:IsAbleToGrave()
end

function s.tgtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(s.tgfilter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_HAND + LOCATION_DECK)
end

function s.tgop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g = Duel.SelectMatchingCard(tp, s.tgfilter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil)
	
	-- Se conseguiu enviar a carta com sucesso para o Cemitério...
	if #g > 0 and Duel.SendtoGrave(g, REASON_EFFECT) > 0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		local c = e:GetHandler()
		-- ...E se o Pegasus ainda estiver virado para cima no campo, ganha o 2º ataque!
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			local e1 = Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EXTRA_ATTACK)
			e1:SetValue(1) -- "1" significa +1 ataque (total de 2)
			e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end

-- ==========================================
-- Lógica: Colocar na Zona de Magias e Armadilhas e Destruir (Efeito 2)
-- ==========================================
function s.pctg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 end
	Duel.SetPossibleOperationInfo(0, CATEGORY_DESTROY, nil, 1, 0, LOCATION_ONFIELD)
end

function s.pcop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp, LOCATION_SZONE) <= 0 then return end
	
	-- Coloca o próprio Pegasus na Zona S&T como Magia Contínua
	if Duel.MoveToField(c, tp, tp, LOCATION_SZONE, POS_FACEUP, true) then
		local e1 = Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL + TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
		
		-- Conjunção "and if you do": Checa se há cartas no campo que podem ser destruídas
		local g = Duel.GetMatchingGroup(nil, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, c)
		if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
			-- Seleciona a carta sem dar alvo (burla proteção) e destrói
			local sg = g:Select(tp, 1, 1, nil)
			Duel.HintSelection(sg)
			Duel.Destroy(sg, REASON_EFFECT)
		end
	end
end