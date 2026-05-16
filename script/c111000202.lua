-- Quadruple Boon
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- No momento da ativação, checa quantas cartas você tem na mão
	local ht=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	local ct=4-ht
	-- Para ativar, você precisa ter menos de 4 cartas e ser capaz de sacar a diferença
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- Recalcula na resolução em caso de mudanças na corrente (Chain)
	local ht=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	local ct=4-ht
	if ct>0 then
		Duel.Draw(tp,ct,REASON_EFFECT)
	end
end