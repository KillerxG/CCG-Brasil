Duel.LoadScript("VampireHunter.lua")
local s,id=GetID()

function s.initial_effect(c)
	-- 1: Ativar Mágica (Invocação-Ritual) -- motor padrão.
	-- also_grave=false: a versão antiga só buscava na MÃO (confirmado
	-- pelo s.target antigo, que usava só LOCATION_HAND). Se a carta
	-- também deve poder pegar Ritual Monster do GY, troque pra true.
	-- self_grant=true: reproduz o comportamento antigo -- o monstro
	-- invocado por ESTA carta já entra com o efeito próprio dele
	-- concedido (ex: Alucard entra já com a proteção contra Kaiju,
	-- mesmo sem nenhum outro Alucard ter sido usado como material).
	VampireHunter.AddExternalRitual(c,nil,false,true)

	-- 2: Voltar para a mão do GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

-- === Funções do Efeito 2 (Reciclar do GY) ===
function s.cfilter(c)
	return (c:IsSetCard(0x8e) or c:IsRace(RACE_ZOMBIE)) and c:IsAbleToRemoveAsCost()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end