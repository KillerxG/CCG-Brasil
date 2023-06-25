--Genshin Impact - Dehya
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_FIRE),5,2,s.ovfilter,aux.Stringid(id,0))
	c:EnableReviveLimit()
	--(1)Cannot Target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.tgtg)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--(2)Attack Limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.atlimit)
	c:RegisterEffect(e2)
	--(3)Unaffected
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(s.unfcost)
	e3:SetTarget(s.unftg)
	e3:SetOperation(s.unfop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_BECOME_TARGET)
	c:RegisterEffect(e4)
end
--Xyz Summon
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsType(TYPE_XYZ) and c:IsSetCard(0x291,lc,SUMMON_TYPE_XYZ,tp) and not c:IsCode(id)
end
--(1)Cannot Target
function s.tgtg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x291) and c:IsMonster() and c~=e:GetHandler()
end
--(2)Attack Limit
function s.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x291) and c~=e:GetHandler()
end

function s.unfcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.unffilter(c)
  return c:IsFaceup() and c:IsSetCard(0x291) and c:IsType(TYPE_MONSTER)
end
function s.unftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.unffilter,tp,LOCATION_MZONE,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  Duel.SelectTarget(tp,s.unffilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.unfop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if tc:IsRelateToEffect(e) and tc:IsFaceup() then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetValue(s.efilter)
    e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	e2:SetValue(1000)
	tc:RegisterEffect(e2)
  end
end
function s.efilter(e,re)
  return e:GetHandler()~=re:GetOwner()
end