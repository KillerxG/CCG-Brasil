-- Bestial Weapon Snake Garrote (refactor + target fix)
local s,id=GetID()

-- ================== Constants ==================
local SET_BW=0x102C
local CODE_SWORDHUNTER=51345461
local CODE_FIENDSWORD=22855882
local CODE_GARROTESNAKE=751001800   -- ID confirmado pelo autor

-- ================== Helpers ==================
local function equip_limit_to(mc)
	return function(e,c) return c==mc end
end

local function is_bw_or_legacy_pool(c)
	return c:IsType(TYPE_MONSTER)
		and (c:IsSetCard(SET_BW) or c:IsCode(CODE_FIENDSWORD) or c:IsCode(CODE_SWORDHUNTER))
		and not c:IsForbidden()
end

local function is_faceup_warrior(c) return c:IsFaceup() and c:IsRace(RACE_WARRIOR) end

local function can_ss_bw_from_st_g_or_gy(c,e,tp)
	return c:IsSetCard(SET_BW) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsLocation(LOCATION_GRAVE+LOCATION_SZONE)
end

local function halve_stats_until_end(handler, tc)
	if not (tc and tc:IsFaceup()) then return end
	local atk,def = tc:GetAttack(), tc:GetDefense()
	local e1=Effect.CreateEffect(handler)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(math.floor(atk/2))
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e2:SetValue(math.floor(def/2))
	tc:RegisterEffect(e2)
end

local function optional_ss_bw(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local nvCheck = function(c) return can_ss_bw_from_st_g_or_gy(c,e,tp) end
	if not Duel.IsExistingMatchingCard(aux.NecroValleyFilter(nvCheck),tp,LOCATION_GRAVE+LOCATION_SZONE,0,1,nil) then return end
	if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(nvCheck),tp,LOCATION_GRAVE+LOCATION_SZONE,0,1,1,nil)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

local function register_fiend_sword_limit(equip_tc)
	local e2x=Effect.CreateEffect(equip_tc)
	e2x:SetType(EFFECT_TYPE_FIELD)
	e2x:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2x:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2x:SetRange(LOCATION_SZONE)
	e2x:SetTargetRange(0,1)
	e2x:SetValue(1)
	e2x:SetCondition(function(e)
		local eq=e:GetHandler():GetEquipTarget()
		return eq and Duel.GetAttacker()==eq
	end)
	equip_tc:RegisterEffect(e2x)
end

local function register_sword_hunter_package(tc)
	local e3=Effect.CreateEffect(tc)
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
	end)
	e3:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c2=e:GetHandler()
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not c2:IsRelateToEffect(e) then return end
		if Duel.SpecialSummon(c2,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		local g=Duel.GetMatchingGroup(function(sc)
			return sc:IsType(TYPE_EQUIP) and sc:IsControler(tp) and sc:GetEquipTarget()~=c2
		end,tp,LOCATION_SZONE,0,nil)
		for tcx in g:Iter() do
			if tcx:IsType(TYPE_UNION) then aux.SetUnionState(tcx) end
			Duel.Equip(tp,tcx,c2)
		end
		local e4=Effect.CreateEffect(c2)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_UPDATE_ATTACK)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		e4:SetValue(function(e,mcc) return mcc:GetEquipCount()*200 end)
		c2:RegisterEffect(e4)
		local e5=Effect.CreateEffect(c2)
		e5:SetDescription(aux.Stringid(id,5))
		e5:SetCategory(CATEGORY_EQUIP)
		e5:SetType(EFFECT_TYPE_IGNITION)
		e5:SetRange(LOCATION_MZONE)
		e5:SetCountLimit(1)
		e5:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
			if chk==0 then
				return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
					and Duel.IsExistingMatchingCard(function(fc) return fc:IsSetCard(SET_BW) and fc:IsType(TYPE_UNION) end,
						tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil)
			end
		end)
		e5:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			local g2=Duel.SelectMatchingCard(tp,function(fc) return fc:IsSetCard(SET_BW) and fc:IsType(TYPE_UNION) end,
				tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil)
			local tc3=g2:GetFirst()
			if not tc3 then return end
			if Duel.Equip(tp,tc3,e:GetHandler()) then aux.SetUnionState(tc3) end
		end)
		c2:RegisterEffect(e5)
	end)
	tc:RegisterEffect(e3)
end

-- ================== Card Effects ==================
function s.initial_effect(c)
	aux.AddUnionProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR))

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)

	--double tribute
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e3:SetValue(s.effcon)
	c:RegisterEffect(e3)

	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(400)
	c:RegisterEffect(e4)
	local e4b=e4:Clone()
	e4b:SetCode(EFFECT_UPDATE_DEFENSE)
	e4b:SetValue(500)
	c:RegisterEffect(e4b)

	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		local eq=e:GetHandler():GetEquipTarget()
		return eq and Duel.GetAttacker()==eq and Duel.GetAttackTarget()~=nil
	end)
	e5:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.GetAttackTarget()~=nil end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_SZONE)
	end)
	e5:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local d=Duel.GetAttackTarget()
		if d and d:IsRelateToBattle() and d:IsFaceup() then
			halve_stats_until_end(e:GetHandler(), d)
		end
		optional_ss_bw(e,tp)
	end)
	c:RegisterEffect(e5)

	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_EQUIP)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetRange(LOCATION_GRAVE)
	e6:SetCountLimit(1,id)
	e6:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return eg:IsExists(function(tc) return tc:IsSetCard(SET_BW) and not tc:IsCode(CODE_GARROTESNAKE) end,1,nil)
	end)
	e6:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		if chkc then
			if chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) then
				return is_faceup_warrior(chkc)
			end
			return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and is_bw_or_legacy_pool(chkc)
		end
		if chk==0 then
			return Duel.GetLocationCount(tp,LOCATION_SZONE)>1
				and Duel.IsExistingTarget(is_faceup_warrior,tp,LOCATION_MZONE,0,1,nil)
				and Duel.IsExistingTarget(aux.NecroValleyFilter(is_bw_or_legacy_pool),tp,LOCATION_GRAVE,0,1,e:GetHandler())
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		Duel.SelectTarget(tp,is_faceup_warrior,tp,LOCATION_MZONE,0,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local nvPool = function(c) return is_bw_or_legacy_pool(c) end
		Duel.SelectTarget(tp,aux.NecroValleyFilter(nvPool),tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,2,tp,LOCATION_GRAVE)
	end)
	e6:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local tg=Duel.GetTargetCards(e)
		local mc=tg:Filter(Card.IsLocation,nil,LOCATION_MZONE):GetFirst()
		local tc=tg:Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetFirst()
		local c=e:GetHandler()
		if not (mc and mc:IsFaceup() and mc:IsLocation(LOCATION_MZONE) and mc:IsControler(tp)) then return end
		if not (tc and tc:IsRelateToEffect(e)) then return end
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=1 then return end

		if Duel.Equip(tp,tc,mc) and Duel.Equip(tp,c,mc) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(equip_limit_to(mc))
			tc:RegisterEffect(e1)

			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_EQUIP_LIMIT)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(equip_limit_to(mc))
			c:RegisterEffect(e2)

			if tc:IsType(TYPE_UNION) then aux.SetUnionState(tc) end

			if tc:IsCode(CODE_FIENDSWORD) then
				register_fiend_sword_limit(tc)
			elseif tc:IsCode(CODE_SWORDHUNTER) then
				register_sword_hunter_package(tc)
			end
		end
	end)
	c:RegisterEffect(e6)
end
-- Somente para monstros Guerreiro
function s.effcon(e,c)
	return c:IsRace(RACE_WARRIOR)
end
