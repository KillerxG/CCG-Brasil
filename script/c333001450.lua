--Bestial Weapon Knuckle Hornet
local s,id=GetID()
function s.initial_effect(c)
--Equip only to a FIRE or Warrior monster
	aux.AddUnionProcedure(c,s.cfilter)
-- If equipped monster declares attack: send 1 "Bestial Weapon" from hand/deck to GY; add 1 FIRE/Warrior with 1000 or less ATK/DEF from deck
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetRange(LOCATION_SZONE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(s.atkcon)
    e1:SetTarget(s.tg)
    e1:SetOperation(s.op)
    c:RegisterEffect(e1)
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
	e3:SetValue(200)
	c:RegisterEffect(e3)
	local e3b=e3:Clone()
	e3b:SetCode(EFFECT_UPDATE_DEFENSE)
	e3b:SetValue(200)
	c:RegisterEffect(e3b)
    -- If a Warrior or FIRE monster you control declares a direct attack: equip this card from hand or GY
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_EQUIP)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_ATTACK_ANNOUNCE)
    e4:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCountLimit(1,id)
    e4:SetCondition(s.eqcon)
    e4:SetTarget(s.eqtg)
    e4:SetOperation(s.eqop)
    c:RegisterEffect(e4)	
end
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) or c:IsRace(RACE_WARRIOR)
end
-- Verifica se o monstro equipado é quem declarou o ataque
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local ec=e:GetHandler():GetEquipTarget()
    return ec and Duel.GetAttacker()==ec
end

-- Filtro: "Bestial Weapon" para enviar ao GY
function s.costfilter(c)
    return c:IsAbleToGrave()
end

-- Filtro: FIRE ou Warrior com 1000 ou menos ATK ou DEF
function s.thfilter(c)
    return (c:IsAttribute(ATTRIBUTE_FIRE) or c:IsRace(RACE_WARRIOR))
        and (c:GetAttack()<=1000 or c:GetDefense()<=1000)
        and c:IsAbleToHand()
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil)
            and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
    -- Envia "Bestial Weapon" da mão ou Deck
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
    if #g==0 or Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end

    -- Agora busca 1 Warrior ou FIRE com 1000 ou menos ATK/DEF
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local tg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #tg>0 then
        Duel.SendtoHand(tg,tp,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tg)
    end
end
-- Condição: Um Warrior ou FIRE monstro do seu lado declarou ataque direto
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
    local atk=Duel.GetAttacker()
    return atk and atk:IsControler(tp)
        and (atk:IsRace(RACE_WARRIOR) or atk:IsAttribute(ATTRIBUTE_FIRE))
        and atk:IsFaceup()
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local atk=Duel.GetAttacker()
    if not atk or not atk:IsRelateToBattle() or not atk:IsControler(tp) or not atk:IsFaceup() then return end
    if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.Equip(tp,c,atk)
			-- limita o Equip ao alvo escolhido
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(function(e,c) return c==mc end)
		c:RegisterEffect(e2)
		-- se for Union, marca estado
		if c:IsType(TYPE_UNION) then aux.SetUnionState(c) end
end