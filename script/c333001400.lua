--Bestial Weapon Blade Shark
local s,id=GetID()
function s.initial_effect(c)
	--Equip only to a FIRE or Warrior monster
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
	e3:SetValue(600)
	c:RegisterEffect(e3)
	local e3b=e3:Clone()
	e3b:SetCode(EFFECT_UPDATE_DEFENSE)
	e3b:SetValue(600)
	c:RegisterEffect(e3b)

	    -- Trigger when equipped monster declares an attack
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_ATTACK_ANNOUNCE)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCondition(s.atkcon)
    e4:SetOperation(s.atkop)
    c:RegisterEffect(e4)
	    -- Efeito: Equipar da mão ou do cemitério após invocação de Guerreiro/FOGO
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,2))
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_SUMMON_SUCCESS)
    e5:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCountLimit(1,id)
    e5:SetCondition(s.eqcon)
    e5:SetTarget(s.eqtg)
    e5:SetOperation(s.eqop)
    c:RegisterEffect(e5)

    -- Cópia para invocação especial
    local e6=e5:Clone()
    e6:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e6)
end
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) or c:IsRace(RACE_WARRIOR)
end
-- Verifica se o monstro equipado é quem declarou o ataque
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local ec=e:GetHandler():GetEquipTarget()
    return ec and Duel.GetAttacker()==ec
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<1 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.GetDecktopGroup(tp,1)
    local tc=g:GetFirst()
    Duel.ConfirmCards(tp,tc)

    local ec=e:GetHandler():GetEquipTarget()
    if not ec or not tc then return end

    -- Se for Equip Spell ou "Bestial Weapon"
    if (tc:IsType(TYPE_EQUIP) or tc:IsSetCard(0x102c)) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
        Duel.Equip(tp,tc,ec)
		-- limita o Equip ao alvo escolhido
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(function(e,tc) return tc==mc end)
		tc:RegisterEffect(e2)
		-- se for Union, marca estado
		if tc:IsType(TYPE_UNION) then aux.SetUnionState(tc) end
    else
        -- Se não, perguntar se coloca no topo ou fundo
        Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0)) -- Escolha topo/fundo
        local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2)) -- 0=Topo, 1=Fundo
        if op==1 then
            Duel.MoveSequence(tc,SEQ_DECKBOTTOM)
        else
            Duel.MoveSequence(tc,SEQ_DECKTOP)
        end
    end
end
-- Condição: Verifica se algum dos monstros invocados é Guerreiro ou FOGO e que pode ser equipado
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.eqfilter,1,nil,tp)
end

function s.eqfilter(c,tp)
    return c:IsFaceup() and c:IsControler(tp)
        and (c:IsRace(RACE_WARRIOR) or c:IsAttribute(ATTRIBUTE_FIRE))
        and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
end

-- Alvo: selecionar o monstro válido que acabou de ser invocado
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return eg:IsExists(s.eqfilter,1,nil,tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=eg:FilterSelect(tp,s.eqfilter,1,1,nil,tp)
    if g then
        e:SetLabelObject(g:GetFirst())
    end
end

-- Operação: equipa esta carta ao monstro escolhido
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=e:GetLabelObject()
    if not tc or not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
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