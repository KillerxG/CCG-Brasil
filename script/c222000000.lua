local s, id = GetID()
local SET_PRYSM_BEAST = 0x100b 

function s.initial_effect(c)
	-- Invocação Xyz Padrão (4 Monstros Nível 4)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c, nil, 4, 4)

	-- Invocação Alternativa: Associar 7 "Prysm Beast" do campo
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.altcon)
	e1:SetTarget(s.alttg)
	e1:SetOperation(s.altop)
	c:RegisterEffect(e1)

	-- Efeito Contínuo: Ganho de ATK
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)

	-- Efeito Ignição: Desassociar e Embaralhar (Sem dar Alvo)
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id, 0))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(s.cost)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end

-- ==========================================
-- Lógica: Invocação Alternativa (Efeito 1)
-- ==========================================
function s.altfilter(c)
	-- Puxa Prysm Beasts do Campo todo (Zonas de Monstro e S&T) que estejam virados para cima
	return c:IsFaceup() and c:IsSetCard(SET_PRYSM_BEAST) and c:IsOriginalType(TYPE_MONSTER)
end

function s.rescon(sg, e, tp, mg)
	-- Garante que todos os 7 cards selecionados tenham nomes diferentes e que libere espaço no campo
	return sg:GetClassCount(Card.GetCode) == #sg 
		and Duel.GetLocationCountFromEx(tp, tp, sg, e:GetHandler()) > 0
end

function s.altcon(e, c)
	if c == nil then return true end
	local tp = c:GetControler()
	local g = Duel.GetMatchingGroup(s.altfilter, tp, LOCATION_ONFIELD, 0, nil)
	-- Verifica se é possível agrupar 7 cartas com a condição acima
	return aux.SelectUnselectGroup(g, e, tp, 7, 7, s.rescon, 0)
end

function s.alttg(e, tp, eg, ep, ev, re, r, rp, chk, c)
	local g = Duel.GetMatchingGroup(s.altfilter, tp, LOCATION_ONFIELD, 0, nil)
	-- Abre a seleção de 7 cartas exigindo nomes diferentes
	local sg = aux.SelectUnselectGroup(g, e, tp, 7, 7, s.rescon, 1, tp, HINTMSG_XMATERIAL)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	end
	return false
end

function s.altop(e, tp, eg, ep, ev, re, r, rp, c)
	local g = e:GetLabelObject()
	if not g then return end
	c:SetMaterial(g) -- Memoriza que essas foram as matérias usadas
	Duel.Overlay(c, g) -- Anexa todas as 7 cartas como Matéria Xyz!
	g:DeleteGroup()
end

-- ==========================================
-- Lógica: Ganho de ATK (Efeito 2)
-- ==========================================
function s.atkval(e, c)
	-- Conta apenas matérias Xyz que pertençam ao arquétipo "Prysm Beast"
	return c:GetOverlayGroup():FilterCount(Card.IsSetCard, nil, SET_PRYSM_BEAST) * 500
end

-- ==========================================
-- Lógica: Desassociar e Embaralhar (Efeito 3)
-- ==========================================
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.tdtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, 0, LOCATION_ONFIELD)
end

function s.tdop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
	-- O jogador escolhe na resolução (não dá target)
	local g = Duel.SelectMatchingCard(tp, Card.IsAbleToDeck, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil)
	if #g > 0 then
		Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
	end
end