--Mr. Blazehowl
local s, id = GetID()
local SET_BLAZEHOWL = 0x100c
local SET_MR = 0x215b

-- IDs fixos dos quatro Mr. originais usados para identificar a materia desassociada:
local ID_BASALT = 333001580
local ID_GEYSER = 333001570
local ID_MEGAVOLT = 333001560
local ID_VOLCANO = 31477025 -- Official Mr. Volcano and its custom alias.
s.listed_series={SET_MR,SET_BLAZEHOWL}
s.listed_names={
    31477025, -- Mr. Volcano
    333001560, -- Mr. Megavolt
    333001570, -- Mr. Geyser
    333001580  -- Mr. Basalt
}
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Mantem o procedimento de Invocacao-Xyz do arquivo enviado (2+ "Mr." Xyz Rank 5).
	Xyz.AddProcedure(c,s.xyzfilter,nil,2,nil,nil,nil,nil,false)
    
    -- Efeito 0: Ganhar efeitos dos "Blazehowl" associados (Em Tempo Real)
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_ADJUST)
    e0:SetRange(LOCATION_MZONE)
    e0:SetOperation(s.copyop)
    c:RegisterEffect(e0)

    -- Efeito 1: Invocar por Xyz -> Associar 4 "Mr."
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.attcon)
    e1:SetCost(s.attcost)
    e1:SetTarget(s.atttg)
    e1:SetOperation(s.attop)
    c:RegisterEffect(e1)

    -- Efeito 2: Desassociar 1 -> Destruir e Aplicar Efeito (Ignition)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DESTROY + CATEGORY_SPECIAL_SUMMON + CATEGORY_TOGRAVE + CATEGORY_DISABLE + CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1, {id,0})
    e2:SetCost(s.descost)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
	
	
    -- Continuous: gains 200 ATK per currently attached material
    local e_atk=Effect.CreateEffect(c)
    e_atk:SetType(EFFECT_TYPE_SINGLE)
    e_atk:SetCode(EFFECT_UPDATE_ATTACK)
    e_atk:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e_atk:SetRange(LOCATION_MZONE)
    e_atk:SetValue(s.atkval)
    c:RegisterEffect(e_atk)
end
function s.atkval(e,c)
    return e:GetHandler():GetOverlayCount()*200
end

function s.xyzfilter(c,xyz,sumtype,tp)
	return c:IsType(TYPE_XYZ,xyz,sumtype,tp) and c:IsRank(5) and c:IsSetCard(SET_MR,xyz,sumtype,tp)
end
-- ==========================================
-- Efeito 0: Copiar Efeitos "Blazehowl"
-- ==========================================
function s.copyop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = c:GetOverlayGroup():Filter(Card.IsSetCard, nil, SET_BLAZEHOWL)
    
    -- Cria uma tabela segura no script em vez de no objeto da carta
    if not s.copy_mats then s.copy_mats = {} end
    local fid = c:GetFieldID()
    if not s.copy_mats[fid] then s.copy_mats[fid] = {} end
    
    local mats = s.copy_mats[fid]
    local current_codes = {}
    
    for tc in aux.Next(g) do
        current_codes[tc:GetOriginalCodeRule()] = true
    end

    -- Remove os efeitos das matérias que já foram desassociadas
    for code, cid in pairs(mats) do
        if not current_codes[code] then
            c:ResetEffect(cid, RESET_COPY)
            mats[code] = nil
        end
    end

    -- Adiciona os efeitos das novas matérias
    for code, _ in pairs(current_codes) do
        if not mats[code] then
            local cid = c:CopyEffect(code, RESET_EVENT + RESETS_STANDARD)
            mats[code] = cid
        end
    end
end

-- ==========================================
-- Efeito 1: Associar 4 "Mr."
-- ==========================================
function s.attcon(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.attcost(e, tp, eg, ep, ev, re, r, rp, chk)
	local c = e:GetHandler()
	if chk == 0 then return c:CheckRemoveOverlayCard(tp, 2, REASON_COST) end
	c:RemoveOverlayCard(tp, 2, 2, REASON_COST)
end
function s.att_filter(c)
	return c:IsSetCard(SET_MR) and c:IsType(TYPE_MONSTER)
end
function s.att_chk(sg, e, tp, mg)
	return sg:GetClassCount(Card.GetAttribute) == #sg
end
function s.atttg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		local g = Duel.GetMatchingGroup(s.att_filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, nil)
		return aux.SelectUnselectGroup(g, e, tp, 4, 4, s.att_chk, 0)
	end
end
function s.attop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.att_filter), tp, LOCATION_DECK + LOCATION_GRAVE, 0, nil)
	local sg = aux.SelectUnselectGroup(g, e, tp, 4, 4, s.att_chk, 1, tp, HINTMSG_XMATERIAL)
	if #sg == 4 then
		Duel.Overlay(c, sg)
	end
end


-- ==========================================
-- Efeito 2: Destruir e Aplicar (Basalt, Geyser, etc)
-- ==========================================
function s.descost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:CheckRemoveOverlayCard(tp, 1, REASON_COST) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVEXYZ)
    -- Seleciona 1 matéria específica
    local g = c:GetOverlayGroup():Select(tp, 1, 1, nil)
    
    -- Lê e guarda o ID original dessa matéria antes dela sair
    local material = g:GetFirst()
    local code = material:IsCode(ID_VOLCANO) and ID_VOLCANO or material:GetOriginalCodeRule()
    e:SetLabel(code) 
    
    -- Envia a matéria selecionada para o Cemitério (Desassocia corretamente)
    Duel.SendtoGrave(g, REASON_COST)
end
function s.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	if chk == 0 then return Duel.IsExistingTarget(aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
	local g = Duel.SelectTarget(tp, aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e)) then return end
	
	-- Grava o ATK antes de destruir (Para o Mr. Volcano)
	local atk = 0
	if tc:IsFaceup() and tc:IsMonster() then atk = tc:GetAttack() end
	if atk < 0 then atk = 0 end

	if Duel.Destroy(tc, REASON_EFFECT) > 0 then
		local code = e:GetLabel()
		local c = e:GetHandler()

		-- ================== MR. BASALT ==================
		if code == ID_BASALT then
			local mat_count = c:IsRelateToEffect(e) and c:GetOverlayCount() or 0
			local att_mask = 0
			if c:IsRelateToEffect(e) then
				for mc in aux.Next(c:GetOverlayGroup()) do
					att_mask = bit.bor(att_mask, mc:GetAttribute())
				end
			end
			if mat_count > 0 and att_mask > 0 then
				local g = Duel.GetMatchingGroup(s.basalt_sp_filter, tp, LOCATION_GRAVE, 0, nil, e, tp, att_mask)
				local sg = aux.SelectUnselectGroup(g, e, tp, 1, mat_count, s.basalt_chk, 1, tp, HINTMSG_SPSUMMON)
				if sg and #sg > 0 then
					for sc in aux.Next(sg) do
						Duel.SpecialSummonStep(sc, 0, tp, tp, false, false, POS_FACEUP)
						sc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD, 0, 1)
					end
					Duel.SpecialSummonComplete()
					-- Trava o Extra Deck
					local e1 = Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_FIELD)
					e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
					e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
					e1:SetTargetRange(1, 0)
					e1:SetCondition(s.lockcon)
					e1:SetTarget(s.splimit)
					Duel.RegisterEffect(e1, tp)
				end
			end

		-- ================== MR. GEYSER ==================
		elseif code == ID_GEYSER then
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
			local tg = Duel.SelectMatchingCard(tp, s.geyser_send_filter, tp, LOCATION_DECK, 0, 1, 1, nil)
			if #tg > 0 and Duel.SendtoGrave(tg, REASON_EFFECT) > 0 then
				Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_XMATERIAL)
				local og = Duel.SelectMatchingCard(tp, s.geyser_att_filter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
				if #og > 0 and c:IsRelateToEffect(e) and c:IsFaceup() then
					Duel.Overlay(c, og)
				end
			end

		-- ================== MR. MEGAVOLT ==================
		elseif code == ID_MEGAVOLT then
			local ct = s.attr_count(tp)
			if ct > 0 then
				local e1 = Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetTargetRange(0, LOCATION_MZONE)
				e1:SetTarget(aux.TargetBoolFunction(Card.IsSummonType, SUMMON_TYPE_SPECIAL))
				e1:SetValue(-500 * ct)
				e1:SetReset(RESET_PHASE + PHASE_END)
				Duel.RegisterEffect(e1, tp)
				
				local e2 = e1:Clone()
				e2:SetCode(EFFECT_DISABLE)
				Duel.RegisterEffect(e2, tp)
			end

		-- ================== MR. VOLCANO ==================
		elseif code == ID_VOLCANO then
			local e1 = Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_DIRECT_ATTACK)
			e1:SetTargetRange(LOCATION_MZONE, 0)
			e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard, SET_MR))
			e1:SetReset(RESET_PHASE + PHASE_END)
			Duel.RegisterEffect(e1, tp)
			
			local e2 = Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
			e2:SetCondition(s.volcanocon)
			e2:SetOperation(s.volcanoop)
			e2:SetLabel(atk)
			e2:SetReset(RESET_PHASE + PHASE_END)
			Duel.RegisterEffect(e2, tp)
		end
	end
end

-- ========== Funções Auxiliares (Basalt) ==========
function s.basalt_sp_filter(c, e, tp, att_mask)
	return c:IsType(TYPE_NORMAL) and bit.band(c:GetAttribute(), att_mask) ~= 0
		and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function s.basalt_chk(sg, e, tp, mg)
	return sg:GetClassCount(Card.GetAttribute) == #sg
end
function s.lockcon(e)
	return Duel.IsExistingMatchingCard(function(c) return c:GetFlagEffect(id) > 0 end, e:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, nil)
end
function s.splimit(e, c, sump, sumtype, sumpos, targetp, se)
	return c:IsLocation(LOCATION_EXTRA)
end

-- ========== Funções Auxiliares (Geyser) ==========
function s.geyser_send_filter(c)
	return (c:IsType(TYPE_NORMAL) or c:IsType(TYPE_GEMINI)) and c:IsAbleToGrave()
end
function s.geyser_att_filter(c)
	return c:IsSetCard(SET_MR) and c:IsType(TYPE_MONSTER)
end

-- ========== Funções Auxiliares (Megavolt) ==========
function s.attr_count(tp)
	local g = Duel.GetMatchingGroup(Card.IsType, tp, LOCATION_GRAVE, 0, nil, TYPE_MONSTER)
	local att = 0
	for tc in aux.Next(g) do att = bit.bor(att, tc:GetAttribute()) end
	
	local ct = 0
	if bit.band(att, ATTRIBUTE_EARTH) ~= 0 then ct = ct + 1 end
	if bit.band(att, ATTRIBUTE_WATER) ~= 0 then ct = ct + 1 end
	if bit.band(att, ATTRIBUTE_FIRE) ~= 0 then ct = ct + 1 end
	if bit.band(att, ATTRIBUTE_WIND) ~= 0 then ct = ct + 1 end
	if bit.band(att, ATTRIBUTE_LIGHT) ~= 0 then ct = ct + 1 end
	if bit.band(att, ATTRIBUTE_DARK) ~= 0 then ct = ct + 1 end
	if bit.band(att, ATTRIBUTE_DIVINE) ~= 0 then ct = ct + 1 end
	return ct
end

-- ========== Funções Auxiliares (Volcano) ==========
function s.volcanocon(e, tp, eg, ep, ev, re, r, rp)
	local ac = Duel.GetAttacker()
	return ep == 1 - tp and ac and ac:IsSetCard(SET_MR) and Duel.GetAttackTarget() == nil
		and ac:GetEffectCount(EFFECT_DIRECT_ATTACK) > 0
end
function s.volcanoop(e, tp, eg, ep, ev, re, r, rp)
	Duel.ChangeBattleDamage(ep, e:GetLabel())
end
