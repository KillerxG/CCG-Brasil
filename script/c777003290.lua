-- Oceanic Storm Blood Infection
-- Programado por Gemini
local s,id=GetID()

function s.initial_effect(c)
	-- Ativação base da Armadilha Contínua (pode ser ativada sem usar o efeito)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_END_PHASE)
	c:RegisterEffect(e1)

	-- Efeito Rápido: Tomar o controle ou o oponente pagar LP para destruir
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_CONTROL+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_END_PHASE)
	e2:SetCountLimit(1,id) -- Restrição de uso do efeito 1 vez por turno
	e2:SetCondition(s.condition)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end

-- Filtro genérico da tribo
function s.os_filter(c)
	return c:IsFaceup() and c:IsSetCard(0x312)
end

-- Filtro da Caroline pelo ID direto
function s.caroline_filter(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(777003320)
end

-- Condição: Controlar um monstro "Oceanic Storm"
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.os_filter,tp,LOCATION_MZONE,0,1,nil)
end

-- Custo: Pagar 800 LP (ou 200 se controlar a Caroline)
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1 = Duel.IsExistingMatchingCard(s.caroline_filter,tp,LOCATION_MZONE,0,1,nil)
	local cost = b1 and 200 or 800
	if chk==0 then return Duel.CheckLPCost(tp,cost) end
	Duel.PayLPCost(tp,cost)
end

-- Filtro de alvo válido
function s.tgfilter(c)
	-- O monstro precisa estar com a face para cima (para ler o ATK) e poder trocar de controle
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end

-- Seleção de Alvo
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_MZONE,1,nil) end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_MZONE,1,1,nil)
	
	-- Passamos CATEGORY_CONTROL como a intenção base
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end

-- Resolução
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	
	-- Pega o ATK atual do monstro no campo
	local atk = tc:GetAttack()
	
	-- Confere se o oponente pode pagar (ATK > 0 e possui LP suficiente)
	local can_pay = atk > 0 and Duel.CheckLPCost(1-tp, atk)
	
	-- Pergunta ao oponente
	if can_pay and Duel.SelectYesNo(1-tp, aux.Stringid(id,1)) then
		-- Oponente paga os PV e destrói o monstro
		Duel.PayLPCost(1-tp, atk)
		Duel.Destroy(tc, REASON_EFFECT)
	else
		-- Se o oponente não puder ou escolher não pagar, você toma o controle
		Duel.GetControl(tc, tp)
	end
end