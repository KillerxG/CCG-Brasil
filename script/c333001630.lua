--Mr. Temper's Rage

-- Mr. Temper's Rage
-- ID: 333001630
local s,id=GetID()

function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE|CATEGORY_REMOVE|CATEGORY_SEARCH|CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
local s,id=GetID()
s.listed_card_types={TYPE_GEMINI}
-- Controlar um monstro Normal, Gemini ou "Mr."
function s.normalfilter(c)
	return c:IsFaceup() and c:IsMonster()
		and (c:IsType(TYPE_NORMAL) or c:IsType(TYPE_GEMINI) or c:IsSetCard(0x215b))
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsChainNegatable(ev)
		and Duel.IsExistingMatchingCard(
			s.normalfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- Exatamente 4 monstros Normal "Mr." de Atributos diferentes
function s.costfilter(c,mask)
	return c:IsMonster() and c:IsType(TYPE_NORMAL) and c:IsSetCard(0x215b)
		and c:IsAbleToGraveAsCost()
		and (c:GetAttribute()&mask)==0
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(
		s.costfilter,tp,LOCATION_DECK,0,nil,0)
	local mask=0
	for tc in aux.Next(g) do
		mask=mask|tc:GetAttribute()
	end

	if chk==0 then
		local count=0
		for i=0,6 do
			if (mask&(1<<i))~=0 then
				count=count+1
			end
		end
		return count>=4
	end

	local sg=Group.CreateGroup()
	local used=0

	for i=1,4 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tc=Duel.SelectMatchingCard(
			tp,s.costfilter,tp,LOCATION_DECK,0,
			1,1,nil,used):GetFirst()
		sg:AddCard(tc)
		used=used|tc:GetAttribute()
	end

	e:SetLabel(used)
	Duel.SendtoGrave(sg,REASON_COST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(
		0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(
		0,CATEGORY_REMOVE,nil,1,1-tp,
		LOCATION_DECK|LOCATION_EXTRA)
end

-- Cartas com o mesmo nome original
function s.banishfilter(c,code)
	return c:GetOriginalCode()==code
		and c:IsAbleToRemove()
end

-- Monstros que podem ser adicionados
function s.addfilter(c,mask)
	return c:IsMonster()
		and c:IsAbleToHand()
		and (c:GetAttribute()&mask)==0
end

-- Avancar para End Phase
function s.endphase(tp)
	local phase=Duel.GetCurrentPhase()
	local reset=RESET_PHASE|PHASE_END

	if phase==PHASE_MAIN1 then
		Duel.SkipPhase(tp,PHASE_MAIN1,reset,1)
		Duel.SkipPhase(tp,PHASE_BATTLE,reset,1,1)
		Duel.SkipPhase(tp,PHASE_MAIN2,reset,1)
	elseif phase>=PHASE_BATTLE_START
		and phase<=PHASE_BATTLE then
		Duel.SkipPhase(tp,PHASE_BATTLE,reset,1,1)
		Duel.SkipPhase(tp,PHASE_MAIN2,reset,1)
	elseif phase==PHASE_MAIN2 then
		Duel.SkipPhase(tp,PHASE_MAIN2,reset,1)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.NegateActivation(ev) then return end

	local rc=re:GetHandler()
	local code=rc:GetOriginalCode()

	-- Banir a carta negada
	if rc:IsAbleToRemove() then
		Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
	end

	-- Banir todas as copias do Deck e Extra Deck
	local g=Duel.GetMatchingGroup(
		s.banishfilter,tp,0,
		LOCATION_DECK|LOCATION_EXTRA,nil,code)

	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end

	-- Apenas durante o turno do oponente
	if Duel.GetTurnPlayer()~=1-tp then return end

	local op=1-tp
	local mask=e:GetLabel()

	if not Duel.IsExistingMatchingCard(
		s.addfilter,op,LOCATION_DECK,0,1,nil,mask)
	then return end

	-- O oponente decide se deseja adicionar
	if not Duel.SelectYesNo(op,aux.Stringid(id,0)) then
		return
	end

	local added=0

	-- Primeiro monstro
	Duel.Hint(HINT_SELECTMSG,op,HINTMSG_ATOHAND)
	local g1=Duel.SelectMatchingCard(
		op,s.addfilter,op,LOCATION_DECK,0,
		1,1,nil,mask)

	if #g1==0 then return end

	local tc=g1:GetFirst()
	local used=mask|tc:GetAttribute()

	if Duel.SendtoHand(g1,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(tp,g1)
		added=added+1
	end

	-- Segundo monstro, com Attribute diferente
	if Duel.IsExistingMatchingCard(
		s.addfilter,op,LOCATION_DECK,0,1,nil,used)
		and Duel.SelectYesNo(op,aux.Stringid(id,1))
	then
		Duel.Hint(HINT_SELECTMSG,op,HINTMSG_ATOHAND)
		local g2=Duel.SelectMatchingCard(
			op,s.addfilter,op,LOCATION_DECK,0,
			1,1,nil,used)

		if #g2>0
			and Duel.SendtoHand(g2,nil,REASON_EFFECT)>0
		then
			Duel.ConfirmCards(tp,g2)
			added=added+1
		end
	end

	-- So avanca se realmente adicionou
	if added>0 then
		s.endphase(op)
	end
end
