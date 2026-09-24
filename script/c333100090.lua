--Warforged Avatar Prime
-- Warforged Aatar Prime
local s,id=GetID()
function s.initial_effect(c)
	-- Invocação Xyz Padrão
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x311),8,2)
	
	-- Invocação Xyz Alternativa (4 Equip Spells)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.altxyzcon)
	e1:SetTarget(s.altxyztg)
	e1:SetOperation(s.altxyzop)
	e1:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e1)
	
	-- Tratada como Monstro Normal
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetCondition(s.normcon)
	e2:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_REMOVE_TYPE)
	e3:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e3)

	-- ==========================================
	-- EFEITOS CONTÍNUOS (AURA)
	-- ==========================================
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCode(EFFECT_CHANGE_RACE)
	e4:SetCondition(s.effcon)
	e4:SetTarget(s.auratg)
	e4:SetValue(RACE_MACHINE)
	c:RegisterEffect(e4)
	
	local e5=e4:Clone()
	e5:SetCode(EFFECT_ADD_SETCODE)
	e5:SetValue(0x311)
	c:RegisterEffect(e5)
	
	local e6=e4:Clone()
	e6:SetCode(EFFECT_ADD_TYPE)
	e6:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e6)
	
	local e7=e4:Clone()
	e7:SetCode(EFFECT_GEMINI_STATUS)
	c:RegisterEffect(e7)
	
	local e8=e4:Clone()
	e8:SetCode(EFFECT_UPDATE_ATTACK)
	e8:SetValue(s.atkval)
	c:RegisterEffect(e8)
	local e9=e8:Clone()
	e9:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e9)

	-- ==========================================
	-- EFEITOS ATIVADOS
	-- ==========================================
	-- Efeito Rápido: Negar e Anexar
	local e10=Effect.CreateEffect(c)
	e10:SetDescription(aux.Stringid(id,1))
	e10:SetCategory(CATEGORY_DISABLE)
	e10:SetType(EFFECT_TYPE_QUICK_O)
	e10:SetCode(EVENT_CHAINING)
	e10:SetRange(LOCATION_MZONE)
	e10:SetCountLimit(1,id)
	e10:SetCondition(s.negcon)
	e10:SetCost(s.negcost)
	e10:SetTarget(s.negtg)
	e10:SetOperation(s.negop)
	c:RegisterEffect(e10)
	
	-- Efeito Ignição: Buscar e Conceder Efeito na Mão
	local e11=Effect.CreateEffect(c)
	e11:SetDescription(aux.Stringid(id,2))
	e11:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e11:SetType(EFFECT_TYPE_IGNITION)
	e11:SetRange(LOCATION_MZONE)
	e11:SetCountLimit(1,id+1)
	e11:SetCondition(s.effcon)
	e11:SetCost(Cost.DetachFromSelf(1))
	e11:SetTarget(s.thtg)
	e11:SetOperation(s.thop)
	c:RegisterEffect(e11)
end

local SETCODE_WARFORGED = 0x311
local CARD_FESTOS = 333000040 -- ID exato do Festos
s.listed_names={CARD_FESTOS}

-- ==========================================
-- INVOCAÇÃO XYZ ALTERNATIVA (4 Matérias)
-- ==========================================
function s.altxyzfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsSetCard(SETCODE_WARFORGED) 
		and (c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_SZONE) and c:IsFaceup()))
end
function s.altxyzcon(e,c,og,min,max)
	if c==nil then return true end
	local tp=c:GetControler()
	local mg=Duel.GetMatchingGroup(s.altxyzfilter,tp,LOCATION_HAND+LOCATION_SZONE,0,nil)
	return #mg>=4 and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.altxyztg(e,tp,eg,ep,ev,re,r,rp,chk,c,og,min,max)
	local mg=Duel.GetMatchingGroup(s.altxyzfilter,tp,LOCATION_HAND+LOCATION_SZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local sg=mg:Select(tp,4,4,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	end
	return false
end
function s.altxyzop(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
	local mg=e:GetLabelObject()
	if not mg then return end
	c:SetMaterial(mg)
	Duel.Overlay(c,mg)
	mg:DeleteGroup()
end

-- ==========================================
-- CONTROLE DE STATUS
-- ==========================================
function s.has_equip(c)
	local has_eq = c:GetEquipGroup():IsExists(Card.IsType,1,nil,TYPE_EQUIP)
	local has_mat = c:GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_EQUIP)
	return has_eq or has_mat
end
function s.normcon(e)
	return not s.has_equip(e:GetHandler())
end
function s.effcon(e)
	return s.has_equip(e:GetHandler())
end

-- ==========================================
-- AURA (Modificada para checar o Festos)
-- ==========================================
function s.auratg(e,c)
	return c:IsType(TYPE_GEMINI) and c:IsAttribute(ATTRIBUTE_FIRE) and c:GetEquipCount()>0
end
function s.festos_filter(c)
	return c:IsFaceup() and c:IsCode(CARD_FESTOS)
end
function s.atkval(e,c)
	local tp=e:GetHandlerPlayer()
	local count = Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil)
	-- Dinâmico: 200 por carta se o Festos estiver no campo, caso contrário 100.
	if Duel.IsExistingMatchingCard(s.festos_filter,tp,LOCATION_MZONE,0,1,nil) then
		return count * 200
	else
		return count * 100
	end
end

-- ==========================================
-- EFEITO RÁPIDO: NEGAR E ANEXAR
-- ==========================================
function s.tfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) and c:IsSetCard(SETCODE_WARFORGED)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not s.has_equip(e:GetHandler()) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(s.tfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
function s.costcfilter(c)
	return c:IsType(TYPE_EQUIP) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costcfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costcfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		re:GetHandler():CancelToGrave()
		if c:IsRelateToEffect(e) and c:IsType(TYPE_XYZ) then
			Duel.Overlay(c,re:GetHandler())
		end
	end
end

-- ==========================================
-- EFEITO IGNIÇÃO: BUSCAR E CONCEDER EFEITO
-- ==========================================
function s.thfilter(c)
	return c:IsSetCard(SETCODE_WARFORGED) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,tc)
		
		-- Concede a Propriedade de Equip Spell na Mão até o fim do turno
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_HAND)
		e1:SetValue(TYPE_SPELL+TYPE_EQUIP)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		
		-- Concede o Efeito de Ignição na Mão para Equipar (Simula a Ativação)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(aux.Stringid(id,3))
		e2:SetCategory(CATEGORY_EQUIP)
		e2:SetType(EFFECT_TYPE_IGNITION)
		e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e2:SetRange(LOCATION_HAND)
		e2:SetTarget(s.eqtg_granted)
		e2:SetOperation(s.eqop_granted)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end

-- ==========================================
-- EFEITO CONCEDIDO AO MONSTRO BUSCADO
-- ==========================================
function s.eqfilter_target(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.eqtg_granted(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter_target(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.eqfilter_target,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.eqfilter_target,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.eqop_granted(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(c,REASON_RULE)
		return
	end
	if Duel.Equip(tp,c,tc) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(s.eqlimit_granted)
		e1:SetLabelObject(tc)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
function s.eqlimit_granted(e,c)
	return c==e:GetLabelObject()
end