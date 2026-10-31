local s, id = GetID()
local SET_PRYSM_BEAST = 0x100b 

function s.initial_effect(c)
	-- Efeito 1: Atacar Diretamente
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)

	-- Efeito 2: Modificador do Dano de Batalha
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetCondition(s.damcon)
	e2:SetValue(s.damval)
	c:RegisterEffect(e2)

	-- Efeito 3: Colocar na Zona S&T e Special Summon
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id, 0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetTarget(s.pctg)
	e3:SetOperation(s.pcop)
	c:RegisterEffect(e3)
end

-- ==========================================
-- Lógica: Dano de Batalha Escalonável
-- ==========================================
function s.damcon(e)
	local c = e:GetHandler()
	local tp = e:GetHandlerPlayer()
	-- Confirma que está atacando diretamente apenas GRAÇAS ao efeito desta carta
	-- (Se o oponente não tiver monstros, o ataque é direto por natureza, então não aplica a mudança)
	return Duel.GetAttackTarget() == nil and Duel.GetFieldGroupCount(tp, 0, LOCATION_MZONE) > 0
		and c:GetEffectCount(EFFECT_DIRECT_ATTACK) < 2
end

function s.pbfilter(c)
	-- Puxa Prysm Beasts do Campo todo (Zona de Monstros e Zona S&T)
	return c:IsFaceup() and c:IsSetCard(SET_PRYSM_BEAST) 
end

function s.damval(e, d)
	local tp = e:GetHandlerPlayer()
	local ct = Duel.GetMatchingGroupCount(s.pbfilter, tp, LOCATION_ONFIELD, 0, nil)
	return ct * 400
end

-- ==========================================
-- Lógica: Colocar na S&T e Invocar do S&T
-- ==========================================
function s.pctg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 end
	Duel.SetPossibleOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_SZONE)
end

function s.spfilter(c, e, tp)
	-- Filtra Prysm Beasts na S&T Zone com nome diferente, ignorando que são Magias no momento ("true, false")
	return c:IsFaceup() and c:IsSetCard(SET_PRYSM_BEAST) and c:IsOriginalType(TYPE_MONSTER) and not c:IsCode(id)
		and c:IsCanBeSpecialSummoned(e, 0, tp, true, false)
end

function s.pcop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp, LOCATION_SZONE) <= 0 then return end
	
	-- Coloca o próprio Amethyst Cat na Zona S&T como Magia Contínua
	if Duel.MoveToField(c, tp, tp, LOCATION_SZONE, POS_FACEUP, true) then
		local e1 = Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL + TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
		
		-- Conjunção "and if you do": Checa se tem monstros válidos na S&T para invocar
		local g = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_SZONE, 0, nil, e, tp)
		if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
			local sg = g:Select(tp, 1, 1, nil)
			if #sg > 0 then
				Duel.SpecialSummon(sg, 0, tp, tp, true, false, POS_FACEUP)
			end
		end
	end
end