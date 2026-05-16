-- Ground Quake
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.filter(c)
	-- Filtra apenas monstros virados para cima que podem ser mudados para posição de defesa
	return c:IsFaceup() and c:IsCanTurnSet()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Verifica se existe pelo menos um monstro válido em qualquer um dos lados do campo
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	
	-- Informa ao simulador que haverá uma mudança de posição
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- Checa a validade de cada opção no momento da resolução
	local b1=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil)
	
	-- Menu de seleção
	local op=aux.SelectFromFreeMenu(tp,
		{b1,aux.Stringid(id,0)}, -- Opção 1: Seus monstros
		{b2,aux.Stringid(id,1)}) -- Opção 2: Monstros do oponente
	
	local g=Group.CreateGroup()
	if op==1 then
		-- Coleta seus monstros
		g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	elseif op==2 then
		-- Coleta monstros do oponente
		g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	end
	
	if #g>0 then
		-- Muda todos os monstros selecionados para Posição de Defesa virados para baixo
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end