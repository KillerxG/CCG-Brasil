--Bestial Weapon Shotgun Toad
local s,id=GetID()
function s.initial_effect(c)
--Equip only to a FIRE or Warrior monster
	aux.AddUnionProcedure(c,s.cfilter)
	 -- If a card or effect is activated: target Warrior or FIRE with 1000 or less ATK/DEF, equip this from hand/GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.eqcon)
    e1:SetTarget(s.eqtg)
    e1:SetOperation(s.eqop)
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
	e3:SetValue(500)
	c:RegisterEffect(e3)
	local e3b=e3:Clone()
	e3b:SetCode(EFFECT_UPDATE_DEFENSE)
	e3b:SetValue(500)
	c:RegisterEffect(e3b)	
    -- If the equipped monster declares an attack: double its current ATK/DEF until end of Damage Step
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_ATTACK_ANNOUNCE)
    e4:SetRange(LOCATION_SZONE)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCondition(s.atkcon)
    e4:SetOperation(s.atkop)
    c:RegisterEffect(e4)
end
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) or c:IsRace(RACE_WARRIOR)
end
-- Condição: Apenas verifica se um efeito foi ativado (sempre verdadeiro neste contexto)
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
    return true -- qualquer efeito ou card ativado
end

-- Filtro para monstros válidos no campo
function s.eqfilter(c,tp)
    return c:IsFaceup() and c:IsControler(tp)
        and (c:IsRace(RACE_WARRIOR) or c:IsAttribute(ATTRIBUTE_FIRE))
        and (c:GetAttack()<=1000 or c:GetDefense()<=1000)
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.eqfilter(chkc,tp) end
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
            and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil,tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.Equip(tp,c,tc)
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
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local ec=e:GetHandler():GetEquipTarget()
    return ec and Duel.GetAttacker()==ec
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c = e:GetHandler()
    local ec = c:GetEquipTarget()
    if not ec or not ec:IsFaceup() then return end

    local oatk = ec:GetBaseAttack()
    local odef = ec:GetBaseDefense()

   -- Dobra o ATK original
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_BASE_ATTACK)
    e1:SetValue(oatk * 2)
    e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_DAMAGE)
    ec:RegisterEffect(e1)

    -- Dobra o DEF original
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_SET_BASE_DEFENSE)
    e2:SetValue(odef * 2)
    e2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_DAMAGE)
    ec:RegisterEffect(e2)
end