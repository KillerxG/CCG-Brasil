-- Oceanic Storm Spectrum - Jack
-- Programado por Gemini
local s,id=GetID()

function s.initial_effect(c)
	-- Efeito 1: Special Summon da mão ou GY quando qualquer jogador paga LP
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PAY_LPCOST)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Efeito 2: Oponente revela cartas, você escolhe 1 para o GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetCost(s.cost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end

-- ==============================================================
-- Lógica do Efeito 1: Special Summon ao pagar LP
-- ==============================================================
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- Checa se a carta estava no GY antes da invocação resolver
	local from_gy = c:IsLocation(LOCATION_GRAVE) 
	
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- Aplica o banimento se foi invocada do GY
		if from_gy then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3300) -- String global para "Banish when it leaves the field"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e1,true)
		end
	end
end

-- ==============================================================
-- Lógica do Efeito 2: Revelar e Enviar para o GY
-- ==============================================================
-- Filtro para a presença da Caroline
function s.caroline_filter(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(777003320)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.caroline_filter,tp,LOCATION_MZONE,0,1,nil)
	local cost=b1 and 200 or 800
	if chk==0 then return Duel.CheckLPCost(tp,cost) end
	Duel.PayLPCost(tp,cost)
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- O oponente deve ter pelo menos 1 carta na Mão, 1 no Deck e 1 no Extra Deck
		return Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0
			and Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>0
			and Duel.GetFieldGroupCount(1-tp,LOCATION_EXTRA,0)>0
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local hg=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	local dg=Duel.GetFieldGroup(1-tp,LOCATION_DECK,0)
	local xg=Duel.GetFieldGroup(1-tp,LOCATION_EXTRA,0)
	
	-- Segurança: Cancela se o oponente ficou sem cartas em uma das zonas em resposta à ativação
	if #hg==0 or #dg==0 or #xg==0 then return end
	
	-- Oponente escolhe as 3 cartas
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)
	local tc1=hg:Select(1-tp,1,1,nil):GetFirst()
	
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)
	local tc2=dg:Select(1-tp,1,1,nil):GetFirst()
	
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)
	local tc3=xg:Select(1-tp,1,1,nil):GetFirst()
	
	local g=Group.FromCards(tc1,tc2,tc3)
	if #g==3 then
		-- Mostra as cartas escolhidas para você
		Duel.ConfirmCards(tp,g)
		
		-- Você escolhe 1 para ir para o cemitério
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
		
		-- O motor não moveu as outras cartas de lugar, então apenas embaralhamos o Deck e a Mão
		Duel.ShuffleHand(1-tp)
		Duel.ShuffleDeck(1-tp)
	end
end