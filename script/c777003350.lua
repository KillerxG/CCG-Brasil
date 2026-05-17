-- Oceanic Storm Blood Experiment
-- Programado por Gemini
local s,id=GetID()

function s.initial_effect(c)
	-- You can only control 1 "Oceanic Storm Blood Experiment"
	c:SetUniqueOnField(1,0,id)

	-- Ativação base da Magia Contínua
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- Efeito 1: Substituição de Destruição por Efeito (Pagar LP ao invés de destruir)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTarget(s.reptg)
	e1:SetValue(s.repval)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)

	-- Efeito 2: Oponente deve pagar 800 LP para invocar por Invocação-Especial do Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_COST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_EXTRA) -- CORREÇÃO: Aplica o custo especificamente às cartas no Extra Deck do oponente
	e2:SetCondition(s.taxcon)
	e2:SetCost(s.taxcost)
	e2:SetOperation(s.taxop)
	c:RegisterEffect(e2)

	-- Efeito 3: Uma vez por turno, se seu LP for 2000 ou menos: Tornar LP em 4000
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1) -- Soft Once Per Turn (uma vez por turno por carta)
	e3:SetCondition(s.lpcon)
	e3:SetOperation(s.lpop)
	c:RegisterEffect(e3)
end

-- Filtro para a presença da Caroline
function s.caroline_filter(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(777003320)
end
-- Filtro genérico "Oceanic Storm"
function s.os_filter(c)
	return c:IsFaceup() and c:IsSetCard(0x312)
end

-- ==============================================================
-- Lógica do Efeito 1: Substituição de Destruição
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
	-- Código 96 cria a caixa de diálogo "Deseja usar o efeito de <Nome da Carta>?"
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		e:SetLabel(cost) -- Salva o custo final na label para garantir exatidão
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
-- Lógica do Efeito 2: Taxa do Extra Deck
-- ==============================================================
function s.taxcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.os_filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.taxcost(e,c,tp)
	-- Verifica antes se o oponente tem os pontos para pagar a taxa
	return Duel.CheckLPCost(tp,800)
end
function s.taxop(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp,800)
end

-- ==============================================================
-- Lógica do Efeito 3: Mudar LP para 4000
-- ==============================================================
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)<=2000 and Duel.IsExistingMatchingCard(s.caroline_filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetLP(tp,4000)
end