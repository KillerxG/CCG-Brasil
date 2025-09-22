--Bestial Weapon Eagle Gun
local s,id=GetID()

local SET_BW=0x102C
local CODE_BENKEI=69456283
local CODE_MILLENNIUM=32012841

function s.initial_effect(c)
	-- [E1] Union (equipa em Guerreiro / desequipa e Invoca)
	aux.AddUnionProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR))

	-- [E2] Substituição de destruição do equipado
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)

	-- [E3] Bônus enquanto equipado: +300 ATK/DEF
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	local e3b=e3:Clone()
	e3b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3b)

	--double tribute
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e4:SetValue(s.effcon)
	c:RegisterEffect(e4)

	-- [E5] Quando o equipado declara ataque: causa 200 de dano para cada card equipado a ele
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(s.damcon)
	e5:SetTarget(s.damtg)
	e5:SetOperation(s.damop)
	c:RegisterEffect(e5)

	-- [E6] Se um Guerreiro de Nível 5+ é Invocado por Invocação-Normal
	-- enquanto este card está na Z/M&A ou no Cemitério: equipe do seu Cemitério
	-- 1 "Bestial Weapon", ou "Armed Samurai - Ben Kei", ou "Millennium Shield" a esse monstro (1/turno, Oath)
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_EQUIP)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e6:SetCode(EVENT_SUMMON_SUCCESS)
	e6:SetRange(LOCATION_SZONE+LOCATION_GRAVE)
	e6:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e6:SetCondition(s.eqcon)
	e6:SetTarget(s.eqtg)
	e6:SetOperation(s.eqop)
	c:RegisterEffect(e6)
end
-- Somente para monstros Guerreiro
function s.effcon(e,c)
	return c:IsRace(RACE_WARRIOR)
end

-- E5
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local eq=e:GetHandler():GetEquipTarget()
	return eq and Duel.GetAttacker()==eq
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local a=Duel.GetAttacker()
	local ct=a and a:GetEquipCount() or 0
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*200)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	if not a or not a:IsRelateToBattle() then return end
	local ct=a:GetEquipCount()
	if ct>0 then Duel.Damage(1-tp,ct*200,REASON_EFFECT) end
end

-- Guerreiro 5+ invocado por você
function s.lv5war(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:IsLevelAbove(5) and c:IsSummonPlayer(tp)
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.lv5war,1,nil,tp)
end

-- alvo no GY para equipar
function s.gyfilter(c)
	return c:IsType(TYPE_MONSTER)
		and (c:IsSetCard(0x102C) or c:IsCode(84430950) or c:IsCode(32012841)) -- BW / Ben Kei / Millennium Shield
		and not c:IsForbidden()
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(s.lv5war,nil,tp)
	if chk==0 then
		return #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>1
			and Duel.IsExistingTarget(aux.NecroValleyFilter(s.gyfilter),tp,LOCATION_GRAVE,0,1,e:GetHandler(),tp)
	end
	-- escolhe o Guerreiro 5+ que vai receber o equipamento (não é alvo)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local mc=g:Select(tp,1,1,nil):GetFirst()
	e:SetLabelObject(mc)
	-- escolhe o monstro no GY (este sim é alvo)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,aux.NecroValleyFilter(s.gyfilter),tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local mc=e:GetLabelObject()         -- monstro que vai receber o Equip
	local tc=Duel.GetFirstTarget()      -- card do GY que será equipado
	local c=e:GetHandler()
	if not (mc and mc:IsFaceup() and mc:IsLocation(LOCATION_MZONE) and mc:IsControler(tp)) then return end
	if not (tc and tc:IsRelateToEffect(e)) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end

	if Duel.Equip(tp,tc,mc) and Duel.Equip(tp,c,mc) then
		-- limita o Equip ao alvo escolhido
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(function(e,c) return c==mc end)
		tc:RegisterEffect(e1)
		-- limita o Equip ao alvo escolhido
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(function(e,c) return c==mc end)
		c:RegisterEffect(e2)
		-- se for Union, marca estado
		if tc:IsType(TYPE_UNION) then aux.SetUnionState(tc) end

		-- bônus de Ben Kei
		if tc:IsCode(84430950) then
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetCode(EFFECT_EXTRA_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(function(e,c) return c:GetEquipCount() end)
			tc:RegisterEffect(e2)
		-- bônus de Millennium Shield
		elseif tc:IsCode(32012841) then
			local e3=Effect.CreateEffect(tc)
			e3:SetType(EFFECT_TYPE_EQUIP)
			e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e3:SetValue(1)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
			local e4=Effect.CreateEffect(tc)
			e4:SetType(EFFECT_TYPE_EQUIP)
			e4:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD)
			e4:SetValue(aux.ChangeBattleDamage(tp,HALF_DAMAGE))
			tc:RegisterEffect(e4)
		end
	end
end
