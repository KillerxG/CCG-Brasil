-- Elementale Stage
-- Programado por Gemini
local s,id=GetID()

function s.initial_effect(c)
	-- Ativação da Carta e Busca Opcional
	-- You can only activate 1 "Elementale Stage" per turn.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- Proteção: "Elementale" monsters you control cannot be destroyed by card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)

	-- Restrição de Ataque: Only "Singtress of Elementale - Zel" and Level 3 or lower monsters can declare attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE) -- Afeta o campo inteiro
	e3:SetTarget(s.atktg)
	c:RegisterEffect(e3)

	-- Efeito das Fases: Once per turn, during the Standby or End Phase
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_POSITION)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1) -- Soft Once Per Turn
	e4:SetTarget(s.postg)
	e4:SetOperation(s.posop)
	c:RegisterEffect(e4)
	
	-- Copia o efeito da Standby Phase para a End Phase
	local e5=e4:Clone()
	e5:SetCode(EVENT_PHASE+PHASE_END)
	c:RegisterEffect(e5)
end

-- ==============================================================
-- Lógica da Ativação e Busca Opcional
-- ==============================================================
function s.thfilter(c)
	return c:IsSetCard(0x310) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- Pergunta se o jogador quer buscar na ativação
	if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		e:SetLabel(1) -- Marca que o jogador decidiu buscar
	else
		e:SetCategory(0)
		e:SetLabel(0)
	end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- Magias de Campo precisam estar no campo para resolver
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if e:GetLabel()==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

-- ==============================================================
-- Lógica da Proteção contra Destruição
-- ==============================================================
function s.indtg(e,c)
	return c:IsSetCard(0x310) and c:IsFaceup()
end

-- ==============================================================
-- Lógica da Restrição de Ataques
-- ==============================================================
function s.atktg(e,c)
	-- O alvo NÃO PODE ATACAR se não for a Zel e também não for um monstro de Nível 3 ou menor
	return not (c:IsOriginalCodeRule(777003130) or c:IsLevelBelow(3))
end

-- ==============================================================
-- Lógica do Efeito de Virar para Baixo
-- ==============================================================
function s.posfilter(c)
	return c:IsSetCard(0x310) and c:IsType(TYPE_FLIP) and c:IsCanTurnSet()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.posfilter,tp,LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.posfilter,tp,LOCATION_MZONE,0,nil)
	if #g>0 then
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end