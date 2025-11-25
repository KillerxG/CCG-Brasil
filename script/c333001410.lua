--Bestial Weapon Riffle Hound
local s,id=GetID()
function s.initial_effect(c)
	--[E1] Procedimento de União (alvo: Guerreiro)
	aux.AddUnionProcedure(c,s.cfilter)

	--[E2] Substituição de destruição do monstro equipado
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)

	--[E3] Boost de ATK/DEF do equipado
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(500)
	c:RegisterEffect(e3)
	local e3b=e3:Clone()
	e3b:SetCode(EFFECT_UPDATE_DEFENSE)
	e3b:SetValue(500)
	c:RegisterEffect(e3b)

	--[E4] Quando o equipado declara ataque: destrói 1 card no campo do oponente e o ataque se torna direto
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCondition(s.dircon)
	e4:SetTarget(s.dirtg)
	e4:SetOperation(s.dirop)
	c:RegisterEffect(e4)

	--[E6] Normal/Special: Invoca por Invocação-Especial 1 Guerreiro Nível 4 com ATK e DEF <= 1000 do Deck (1/turno)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetCountLimit(1,id)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e6)
end
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) or c:IsRace(RACE_WARRIOR)
end

-- [E4] O monstro equipado é quem está declarando o ataque
function s.dircon(e,tp,eg,ep,ev,re,r,rp)
	local eq=e:GetHandler():GetEquipTarget()
	return eq and Duel.GetAttacker()==eq
end
function s.dirtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsDestructable() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsDestructable,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsDestructable,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.dirop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and
		Duel.Destroy(tc,REASON_EFFECT)>0 
	-- transforma o ataque em direto (se houve alvo)
	and a and a:IsFaceup() and a:IsControler(tp) and Duel.GetAttackTarget()~=nil then
		Duel.ChangeAttackTarget(nil)
	end
end

-- [E6] Invocação do Deck
function s.spfilter(c,e,tp)
	return (c:IsRace(RACE_WARRIOR) or c:IsAttribute(ATTRIBUTE_FIRE))
		and (c:IsAttackBelow(1000) or c:IsDefenseBelow(1000))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end