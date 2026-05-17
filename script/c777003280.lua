-- Oceanic Storm Knight
-- Programado por Gemini
local s,id=GetID()

function s.initial_effect(c)
	-- Efeito 1: Special Summon da mão
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.cost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Efeito 2: Efeito ao ser Invocado por Invocação-Normal ou Especial
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+1)
	e2:SetCost(s.cost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	
	-- Aplica o Efeito 2 também para Special Summon
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end

-- Filtro exclusivo para a Caroline usando o ID direto
function s.caroline_filter(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(777003320)
end

-- Custo de ativação compartilhado
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.caroline_filter,tp,LOCATION_MZONE,0,1,nil)
	local cost=b1 and 200 or 800
	if chk==0 then return Duel.CheckLPCost(tp,cost) end
	Duel.PayLPCost(tp,cost)
end

-- ==============================================================
-- Lógica do Efeito 1: Special Summon da mão
-- ==============================================================
function s.os_filter(c)
	return c:IsFaceup() and c:IsSetCard(0x312)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- Verifica se você controla uma carta "Oceanic Storm" ou se o oponente controla um monstro
	return Duel.IsExistingMatchingCard(s.os_filter,tp,LOCATION_ONFIELD,0,1,nil)
		or Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- ==============================================================
-- Lógica do Efeito 2: Enviar para o GY sequencialmente
-- ==============================================================
function s.tgmonfilter(c)
	-- Filtro exclui cópias do "Oceanic Storm Knight" pelo id
	return c:IsSetCard(0x312) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and c:IsAbleToGrave()
end

function s.tgstfilter(c)
	return c:IsSetCard(0x312) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgmonfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgmonfilter,tp,LOCATION_DECK,0,1,1,nil)
	
	-- Se o envio inicial do monstro for bem-sucedido
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		
		-- Confere as condições para o efeito opcional adicional ("then...")
		if Duel.IsExistingMatchingCard(s.caroline_filter,tp,LOCATION_MZONE,0,1,nil) 
			and Duel.IsExistingMatchingCard(s.tgstfilter,tp,LOCATION_DECK,0,1,nil) then
			
			-- Abre uma caixa de diálogo perguntando se deseja enviar também uma Mágica/Armadilha
			if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				Duel.BreakEffect() -- Insere a conjunção "then" (então) na corrente do motor
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
				local sg=Duel.SelectMatchingCard(tp,s.tgstfilter,tp,LOCATION_DECK,0,1,1,nil)
				if #sg>0 then
					Duel.SendtoGrave(sg,REASON_EFFECT)
				end
			end
		end
	end
end