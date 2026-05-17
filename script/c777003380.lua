-- Oceanic Storm Spectrum - Jack
-- Programado por Gemini
local s,id=GetID()

function s.initial_effect(c)
	-- Efeito 1a: Special Summon da mão ou GY (Gatilho ao pagar LP)
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

	-- Efeito 1b: Special Summon da mão ou GY (Ignição se controlar a Caroline)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(0)
	e2:SetCondition(s.spcon_ign)
	c:RegisterEffect(e2)

	-- Efeito 2: Ao ser Invocado, revelar e enviar 1 para o GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+1)
	e3:SetCost(s.cost)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
	
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)

	-- Efeito 3: Reviver 1 monstro "Oceanic Storm" do seu GY
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCountLimit(1,id+2)
	e5:SetCost(s.cost)
	e5:SetTarget(s.revtg)
	e5:SetOperation(s.revop)
	c:RegisterEffect(e5)
end

-- Filtro exclusivo da Caroline pelo ID
function s.caroline_filter(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(777003320)
end

-- ==============================================================
-- Lógica do Efeito 1: Special Summon e Redirecionamento
-- ==============================================================
function s.spcon_ign(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.caroline_filter,tp,LOCATION_MZONE,0,1,nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	
	-- Salva na memória se a carta foi invocada do GY para aplicar o banimento
	local from_gy = c:IsLocation(LOCATION_GRAVE)
	
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and from_gy then
		-- Aplica "banish it when it leaves the field"
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300) -- String universal "Banida ao deixar o campo"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end

-- ==============================================================
-- Lógica Compartilhada: Custo de 800 ou 200 LP
-- ==============================================================
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.caroline_filter,tp,LOCATION_MZONE,0,1,nil)
	local cost=b1 and 200 or 800
	if chk==0 then return Duel.CheckLPCost(tp,cost) end
	Duel.PayLPCost(tp,cost)
end

-- ==============================================================
-- Lógica do Efeito 2: Revelar e Enviar para o GY
-- ==============================================================
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- O oponente deve ter no mínimo 1 carta na Mão, 1 no Deck e 1 no Extra Deck
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

	-- Failsafe caso alguma zona fique vazia em resposta à ativação
	if #hg==0 or #dg==0 or #xg==0 then return end

	-- Oponente escolhe 1 carta de cada zona
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)
	local tc1=hg:Select(1-tp,1,1,nil):GetFirst()
	
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)
	local tc2=dg:Select(1-tp,1,1,nil):GetFirst()
	
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)
	local tc3=xg:Select(1-tp,1,1,nil):GetFirst()

	local g=Group.FromCards(tc1,tc2,tc3)
	if #g==3 then
		-- As 3 cartas são reveladas/confirmadas
		Duel.ConfirmCards(tp,g)
		
		-- Você escolhe qual vai para o cemitério
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
		
		-- A engine já devolve pro ExtraDeck sozinho, então embaralhamos a Mão e o Main Deck do oponente
		Duel.ShuffleHand(1-tp)
		Duel.ShuffleDeck(1-tp)
	end
end

-- ==============================================================
-- Lógica do Efeito 3: Reviver 1 monstro Oceanic Storm
-- ==============================================================
function s.revfilter(c,e,tp)
	return c:IsSetCard(0x312) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.revfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.revfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
		
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.revfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

function s.revop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end