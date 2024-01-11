--Skarlet Warrior - Chloe
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Link Materials
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),2,2,s.lcheck)
	c:EnableReviveLimit()
	--(1)Equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	aux.AddEREquipLimit(c,nil,s.eqval,s.equipop,e1)
	--(2)Can use 1 DARK Warrior monster in your hand as material when using this for a "Skarlet" monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_EXTRA_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetOperation(s.extracon2)
	e2:SetValue(s.extraval2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_SZONE,0)
	e3:SetTarget(s.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	aux.GlobalCheck(s,function()
		s.flagmap2={}
	end)
	--(4)Pay or Destroy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.paycon)
	e4:SetOperation(s.payop)
	c:RegisterEffect(e4)
end
--Link Materials
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsRace,1,nil,RACE_WARRIOR,lc,sumtype,tp)
end
--(2)Equip
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.eqval(ec,c,tp)
	return ec:IsControler(tp) --and ec:IsRace(RACE_WARRIOR) and ec:IsAttribute(ATTRIBUTE_DARK)
end
function s.filter(c,ec)
	return c:IsAttribute(ATTRIBUTE_DARK) --and c:IsRace(RACE_WARRIOR)  and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end
function s.equipop(c,e,tp,tc)
	if not c:EquipByEffectAndLimitRegister(e,tp,tc,nil,true) then return end
	local atk=tc:GetTextAttack()/2
	local def=tc:GetTextDefense()/2
	if atk<0 then atk=0 end
	if def<0 then def=0 end
	--atk/def
	if atk>0 then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
	end
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK,0,1,1,nil,c)
	local tc=g:GetFirst()
	if tc then
		s.equipop(c,e,tp,tc)
	end
end
--(2)Can use 1 DARK Warrior monster in your hand as material when using this for a "Skarlet" monster
function s.eftg(e,c)
	return c:IsOriginalAttribute(ATTRIBUTE_DARK) and c:IsOriginalRace(RACE_WARRIOR) and c:IsCanBeLinkMaterial()
end
function s.extrafilter2(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
function s.extracon2(c,e,tp,sg,mg,lc,og,chk)
	local ct=sg:FilterCount(Card.HasFlagEffect,nil,id+1)
	return ct==0 or ((sg+mg):Filter(s.extrafilter2,nil,e:GetHandlerPlayer()):IsExists(Card.IsCode,1,og,id) and ct<2)
end
function s.extraval2(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or not sc:IsSetCard(0x290) or Duel.GetFlagEffect(tp,id+1)>0 then
			return Group.CreateGroup()
		else
			s.flagmap2[c]=c:RegisterFlagEffect(id+1,0,0,1)
			return Group.FromCards(c)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_LINK==SUMMON_TYPE_LINK and #sg>0 and Duel.GetFlagEffect(tp,id+1)==0 then
			Duel.Hint(HINT_CARD,tp,id)
			Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		end
	elseif chk==2 then
		if s.flagmap2[c] then
			s.flagmap2[c]:Reset()
			s.flagmap2[c]=nil
		end
	end
end
--(4)Pay or Destroy
function s.paycon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.GetTurnPlayer()==tp
end
function s.payop(e,tp,eg,ep,ev,re,r,rp)
  Duel.HintSelection(Group.FromCards(e:GetHandler()))
  if Duel.CheckLPCost(tp,500) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
    Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
    Duel.PayLPCost(tp,500)
  else
    Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
    Duel.Destroy(e:GetHandler(),REASON_COST)
  end
end