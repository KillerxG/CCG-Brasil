-- Oceanic Storm Blood Experiment
-- Programado por Gemini
local s,id=GetID()

function s.initial_effect(c)
	-- You can only control 1 "Oceanic Storm Blood Experiment"
	c:SetUniqueOnField(1,0,id)

	-- Ativação base da carta (Registra a ativação neste turno)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetOperation(s.actop)
	c:RegisterEffect(e0)

	-- Efeito 1: Buscar carta (Main Phase, APENAS se ativada neste turno)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- Efeito 2: Taxa do Extra Deck (Contínuo, Oponente deve pagar 800 LP)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_COST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_EXTRA)
	e2:SetCondition(s.taxcon)
	e2:SetCost(s.taxcost)
	e2:SetOperation(s.taxop)
	c:RegisterEffect(e2)

	-- Efeito 3: Substituição de Destruição por efeito
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetTarget(s.reptg)
	e3:SetValue(s.repval)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)

	-- Efeito 4: Mudar LP para 4000
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id+2)
	e4:SetCondition(s.lpcon)
	e4:SetOperation(s.lpop)
	c:RegisterEffect(e4)
end

function s.caroline_filter(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(777003320)
end

function s.os_filter(c)
	return c:IsFaceup() and c:IsSetCard(0x312)
end

-- ==============================================================
-- Lógica de Ativação Base (Registra o uso neste turno)
-- ==============================================================
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	-- Salva uma flag informando que a carta foi ativada neste exato turno
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end

-- ==============================================================
-- Lógica do Efeito 1: Buscar do Deck
-- ==============================================================
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- Verifica se a flag do turno existe (se foi ativada hoje)
	return e:GetHandler():GetFlagEffect(id)>0
end

function s.thfilter(c)
	local is_caroline = c:IsCode(777003320)
	local is_os_st = c:IsSetCard(0x312) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(id)
	return (is_caroline or is_os_st) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- ==============================================================
-- Lógica do Efeito 2: Taxa do Extra Deck
-- ==============================================================
function s.taxcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.os_filter,tp,LOCATION_MZONE,0,1,nil)
end

function s.taxcost(e,c,tp)
	-- Verifica se o oponente pode pagar o custo no momento que tenta realizar o Special Summon
	return Duel.CheckLPCost(tp,800)
end

function s.taxop(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp,800)
end

-- ==============================================================
-- Lógica do Efeito 3: Substituição de Destruição
-- ==============================================================
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsSetCard(0x312) and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT)
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=eg:Filter(s.repfilter,nil,tp)
		if #g==0 then return false end
		local b1=Duel.IsExistingMatchingCard(s.caroline_filter,tp,LOCATION_MZONE,0,1,nil)
		local cost=b1 and 200 or 800
		if Duel.CheckLPCost(tp,cost) then return true end
		return false
	end
	
	local b1=Duel.IsExistingMatchingCard(s.caroline_filter,tp,LOCATION_MZONE,0,1,nil)
	local cost=b1 and 200 or 800
	-- Código 96 invoca o popup "Deseja usar o efeito de [Nome da Carta]?"
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		e:SetLabel(cost)
		return true
	end
	return false
end

function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp,e:GetLabel())
end

-- ==============================================================
-- Lógica do Efeito 4: Mudar LP para 4000
-- ==============================================================
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)<=2000 and Duel.IsExistingMatchingCard(s.caroline_filter,tp,LOCATION_MZONE,0,1,nil)
end

function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	-- Reseta os Pontos de Vida, sem tratar o acréscimo como cura
	Duel.SetLP(tp,4000)
end