-- Oceanic Storm Studying
-- Programado por Gemini
local s,id=GetID()

function s.initial_effect(c)
	-- Efeito 1: Adicionar 2 cartas e descartar 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)

	-- Efeito 2: Baixar 1 Armadilha do Deck/GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.gycon)
	e2:SetCost(aux.bfgcost) -- Custo automático de "Banir esta carta do GY"
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end

-- Filtro para a presença da Caroline pelo ID
function s.caroline_filter(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(777003320)
end

-- Filtro auxiliar para buscar as cartas do Deck
function s.thfilter(c,t)
	return c:IsSetCard(0x312) and c:IsType(t) and c:IsAbleToHand()
end

-- Filtro para a carta revelada
function s.revfilter(c,tp)
	if not c:IsSetCard(0x312) or c:IsPublic() then return false end
	
	-- Determina quais os outros 2 tipos baseados no tipo revelado
	local t1, t2
	if c:IsType(TYPE_MONSTER) then
		t1, t2 = TYPE_SPELL, TYPE_TRAP
	elseif c:IsType(TYPE_SPELL) then
		t1, t2 = TYPE_MONSTER, TYPE_TRAP
	elseif c:IsType(TYPE_TRAP) then
		t1, t2 = TYPE_MONSTER, TYPE_SPELL
	else
		return false
	end
	
	-- A carta só pode ser revelada se houver alvos válidos dos outros 2 tipos no Deck
	return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,t1)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,t2)
end

-- ==============================================================
-- Lógica do Efeito 1: Pagar LP, Revelar, Adicionar e Descartar
-- ==============================================================
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.caroline_filter,tp,LOCATION_MZONE,0,1,nil)
	local cost=b1 and 200 or 800
	-- Confere o custo em LP e se há uma carta legal para revelar na mão
	if chk==0 then 
		return Duel.CheckLPCost(tp,cost) and Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_HAND,0,1,e:GetHandler(),tp) 
	end
	
	-- Executa os custos
	Duel.PayLPCost(tp,cost)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	
	-- Salva na Label o tipo exato da carta revelada para repassar à operação de busca
	local tc=g:GetFirst()
	local rtype=0
	if tc:IsType(TYPE_MONSTER) then rtype=TYPE_MONSTER
	elseif tc:IsType(TYPE_SPELL) then rtype=TYPE_SPELL
	elseif tc:IsType(TYPE_TRAP) then rtype=TYPE_TRAP
	end
	e:SetLabel(rtype)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_HAND,0,1,e:GetHandler(),tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,1,tp,1)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local rtype=e:GetLabel()
	if rtype==0 then return end
	
	local t1, t2
	if rtype==TYPE_MONSTER then
		t1, t2 = TYPE_SPELL, TYPE_TRAP
	elseif rtype==TYPE_SPELL then
		t1, t2 = TYPE_MONSTER, TYPE_TRAP
	elseif rtype==TYPE_TRAP then
		t1, t2 = TYPE_MONSTER, TYPE_SPELL
	end
	
	local g1=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil,t1)
	local g2=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil,t2)
	
	if #g1>0 and #g2>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg1=g1:Select(tp,1,1,nil)
		
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg2=g2:Select(tp,1,1,nil)
		
		-- Funde os dois grupos para enviar juntos à mão
		sg1:Merge(sg2)
		if Duel.SendtoHand(sg1,nil,REASON_EFFECT)==2 then
			Duel.ConfirmCards(1-tp,sg1)
			Duel.ShuffleHand(tp)
			Duel.BreakEffect()
			-- Descarte obrigatório de 1 carta após a busca
			Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
		end
	end
end

-- ==============================================================
-- Lógica do Efeito 2: Baixar Armadilha do Deck/GY
-- ==============================================================
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.caroline_filter,tp,LOCATION_MZONE,0,1,nil)
end

function s.setfilter(c)
	return c:IsSetCard(0x312) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	-- NecroValleyFilter garante compatibilidade de regras oficiais caso o alvo venha do GY
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end