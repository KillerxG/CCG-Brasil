local s, id = GetID()
-- ATENÇÃO: Substitua pelo código do seu arquétipo "Prysm Beast" no cards.cdb
local SET_PRYSM_BEAST = 0x100b 

function s.initial_effect(c)
	-- Efeito 1: Invocar da mão ou da Zona de Magias e Armadilhas
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2 = e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)

	-- Efeito 2: Colocar na Zona S&T ao ser enviado ao Cemitério
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id, 1))
	e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTarget(s.pctg)
	e3:SetOperation(s.pcop)
	c:RegisterEffect(e3)
end

-- ==========================================
-- Lógica: Invocação-Especial (Efeito 1 corrigido)
-- ==========================================
function s.spfilter(c, e, tp)
	-- Filtra cartas do arquétipo que estejam na mão ou na S&T Zone (com a face para cima)
	return c:IsSetCard(SET_PRYSM_BEAST) and c:IsOriginalType(TYPE_MONSTER)
		and (c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_SZONE) and c:IsFaceup() and c:GetSequence() < 5))
		-- AQUI: "true, false" para ignorar a restrição da carta ser uma Magia neste momento
		and c:IsCanBeSpecialSummoned(e, 0, tp, true, false)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
		and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_HAND + LOCATION_SZONE, 0, 1, nil, e, tp) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_SZONE)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_HAND + LOCATION_SZONE, 0, 1, 1, nil, e, tp)
	if #g > 0 then
		-- AQUI: "true, false" também na execução da Invocação
		Duel.SpecialSummon(g, 0, tp, tp, true, false, POS_FACEUP)
	end
end

-- ==========================================
-- Lógica: Colocar na Zona de Magias e Armadilhas (Efeito 2)
-- ==========================================
function s.pctg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 end
end

function s.pcfilter(c)
	return c:IsSetCard(SET_PRYSM_BEAST) and c:IsMonster() and not c:IsForbidden()
end

function s.pcop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp, LOCATION_SZONE) <= 0 then return end
	
	-- Coloca o próprio Ruby Carbuncle na Zona S&T como Magia Contínua
	if Duel.MoveToField(c, tp, tp, LOCATION_SZONE, POS_FACEUP, true) then
		local e1 = Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL + TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
		
		-- Conjunção "and if you do": Checa se tem espaço sobrando na S&T e cartas válidas na mão
		if Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 
			and Duel.IsExistingMatchingCard(s.pcfilter, tp, LOCATION_HAND, 0, 1, nil) 
			and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
			
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOFIELD)
			local g = Duel.SelectMatchingCard(tp, s.pcfilter, tp, LOCATION_HAND, 0, 1, 1, nil)
			local tc = g:GetFirst()
			if tc then
				-- Coloca a segunda Prysm Beast da mão na Zona S&T também como Magia Contínua
				Duel.MoveToField(tc, tp, tp, LOCATION_SZONE, POS_FACEUP, true)
				local e2 = Effect.CreateEffect(c)
				e2:SetCode(EFFECT_CHANGE_TYPE)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TURN_SET)
				e2:SetValue(TYPE_SPELL + TYPE_CONTINUOUS)
				tc:RegisterEffect(e2)
			end
		end
	end
end