--FGO Aurora
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Special Summon token, then Ritual Summon Mélusine
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--(2)ATK increase
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
	--(3)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_RITUAL))
	e2:SetValue(-2000)
	c:RegisterEffect(e2)
end
s.listed_names={237}
--(1)Special Summon token, then Ritual Summon Mélusine
function s.filter(c,e,tp,m)
	if not c:IsCode(237) or bit.band(c:GetType(),0x81)~=0x81
		or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	if c.mat_filter then
		m=m:Filter(c.mat_filter,nil)
	end
	return m:CheckWithSumEqual(Card.GetRitualLevel,c:GetLevel(),1,99,c)
end
function s.matfilter(c)
	return (c:IsRace(RACE_ALL) and c:IsLocation(LOCATION_HAND)) or (c:IsCode(238) and c:IsLocation(LOCATION_MZONE))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.IsPlayerCanSpecialSummonMonster(tp,238,0,TYPES_TOKEN,0,0,5,RACE_WARRIOR,ATTRIBUTE_EARTH) and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE+LOCATION_ALL,LOCATION_ALL,nil)
		return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not s.sptg(e,tp,eg,ep,ev,re,r,rp,0) then return end
	local token=Duel.CreateToken(tp,238)
	if Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)>0 then
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,mg)
		if tg:GetCount()>0 then
		local tc=tg:GetFirst()
			if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,nil)
			end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local mat=mg:SelectWithSumEqual(tp,Card.GetRitualLevel,tc:GetLevel(),1,99,tc)
			tc:SetMaterial(mat)
			Duel.Release(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
			Duel.BreakEffect()
				if tc and Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)>0 then
				Duel.Equip(tp,c,tc)
				--Equip limit
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetValue(s.eqlimit)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				c:RegisterEffect(e1)
				c:CancelToGrave(true)
				else
				c:CancelToGrave(false)
				end
			tc:CompleteProcedure()
		end
	end
end
function s.eqlimit(e,c)
	return c:IsCode(237)
end
--(2)ATK increase
function s.value(e,c)
	local ec=e:GetHandler():GetEquipTarget()
	if (ec:IsCode(237) or ec:IsCode(777002200)) then
		if c:IsAttackAbove(0) then
			return ec:GetBaseAttack()*0.1
		end
	else
		local ct=Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsSetCard,0x294),e:GetHandler():GetControler(),LOCATION_MZONE,0,nil)
		return -200*ct
	end
end