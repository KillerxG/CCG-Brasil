--Transmorpher Beast
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--(1)Change the Levels of 2 face-up monsters you control, including a "Transmorpher" monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_LVCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
	--(2)Attach this card to 1 Xyz monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCost(s.matcost)
	e2:SetTarget(s.mattg)
	e2:SetOperation(s.matop)
	c:RegisterEffect(e2)
end
--(1)Change the Levels of 2 face-up monsters you control, including a "Transmorpher" monster
function s.lvfilter(c,e)
	return c:HasLevel() and c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsSetCard,1,nil,0x297)
end
s.nlvfilter=aux.NOT(Card.IsLevel)
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local gg=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_MZONE,0,nil,e)
	if chk==0 then return aux.SelectUnselectGroup(gg,e,tp,2,2,s.rescon,0) end
	local g1,g2=gg:Split(Card.IsSetCard,nil,0x297)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	local lv=Duel.AnnounceNumber(tp,s.get_declarable_levels(g1,g2))
	local g=gg:Match(s.nlvfilter,nil,lv)
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(tg)
	e:SetLabel(lv)
	Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,tg,2,tp,lv)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e):Filter(Card.IsFaceup,nil)
	if #tg==0 then return end
	local lv=e:GetLabel()
	for tc in tg:Iter() do
		if not tc:IsLevel(lv) then
			--Its Level becomes the declared Level
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
function s.get_declarable_levels(g1,g2)
	local opts={}
	for lv=1,8 do
		local ct=g1:FilterCount(s.nlvfilter,nil,lv)
		if ct>1 or (ct>0 and g2:IsExists(s.nlvfilter,1,nil,lv)) then
			table.insert(opts,lv)
		end
	end
	return table.unpack(opts)
end
--(2)Attach this card to 1 Xyz monster
function s.matcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.matfilter(c,mc,tp)
	return c:IsFaceup() and c:IsSetCard(0x297) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c,tp,REASON_EFFECT)
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.matfilter(chkc,c,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.matfilter,tp,LOCATION_MZONE,0,1,nil,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.matfilter,tp,LOCATION_MZONE,0,1,1,nil,c,tp)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)	
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		and not tc:IsImmuneToEffect(e) and c:IsCanBeXyzMaterial(tc,tp,REASON_EFFECT) then
		Duel.Overlay(tc,c)
	end
end