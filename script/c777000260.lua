--Azur Lane - Enterprise
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--XYZ Materials
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,s.xyzfilter,nil,2,nil,nil,nil,nil,false,s.xyzcheck)
	--(1)Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
end
--XYZ Materials
function s.xyzfilter(c,xyz,sumtype,tp)
    return c:HasLevel() and c:IsSetCard(0x283)
end
function s.xyzcheck(g,tp,xyz)
    local mg=g:Filter(function(c) return not c:IsHasEffect(511001175) end,nil)
    return #mg==2 and math.abs(mg:GetFirst():GetLevel()-mg:GetNext():GetLevel())==6
end
--(1)Destroy
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetAttack())
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		local atk=tc:GetAttack()
		if atk<0 or tc:IsFacedown() then atk=0 end
		if Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_ONFIELD,PLAYER_NONE,0)>0 end
			local dis=Duel.SelectDisableField(tp,1,0,LOCATION_ONFIELD,0)
	Duel.Hint(HINT_ZONE,tp,dis)
	e:SetLabel(dis)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetOperation(s.disop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	e1:SetLabel(e:GetLabel())
	e:GetHandler():RegisterEffect(e1)
		end
	end
end
function s.disop(e,tp)
	return e:GetLabel()
end