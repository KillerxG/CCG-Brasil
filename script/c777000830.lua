-- Oceanic Storm Blood Transmutation
-- Programado por Gemini
local s,id=GetID()

function s.initial_effect(c)
	-- Ativação base da Armadilha Contínua (apenas colocar face para cima)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_END_PHASE)
	c:RegisterEffect(e1)

	-- Efeito Rápido (Integrado automaticamente pelo EDOPro na ativação ou quando já estiver em campo)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end

-- Filtro exclusivo para a Caroline pelo ID
function s.caroline_filter(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(777003320)
end

-- Filtro de Mágicas/Armadilhas no Campo ou GY do Oponente
function s.filter(c,tp)
	if not c:IsType(TYPE_SPELL+TYPE_TRAP) then return false end
	if c:IsLocation(LOCATION_ONFIELD) then return true end
	if c:IsLocation(LOCATION_GRAVE) then return c:IsSSetable() end
	return false
end

-- ==============================================================
-- Lógica do Efeito Rápido / Seleção de Alvos
-- ==============================================================
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and s.filter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil,tp) end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil,tp)
	
	-- Define as categorias dinamicamente com base na localização do alvo
	if g:GetFirst():IsLocation(LOCATION_ONFIELD) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	
	-- Determina o custo com base na presença da Caroline
	local cost = 800
	if Duel.IsExistingMatchingCard(s.caroline_filter,tp,LOCATION_MZONE,0,1,nil) then
		cost = 1600
	end
	
	-- Caixa de diálogo para o oponente decidir se vai pagar os LP para negar a ação
	if Duel.CheckLPCost(1-tp,cost) and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
		Duel.PayLPCost(1-tp,cost)
		-- Anula a resolução do efeito
		if Duel.IsChainDisablable(0) then
			Duel.NegateEffect(0)
		end
		return
	end
	
	-- Aplica a consequência do efeito se o oponente optar por não pagar
	if tc:IsLocation(LOCATION_ONFIELD) then
		Duel.Destroy(tc,REASON_EFFECT)
	elseif tc:IsLocation(LOCATION_GRAVE) then
		Duel.SSet(tp,tc)
	end
end