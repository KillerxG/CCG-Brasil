--Duskwing Whip
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--Equip
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsSetCard,0x253))
	--(1)Can attack twice
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--(2)Pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	--(3)Change the Monster Type of 1 face-up monster you control
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.chngtg)
	e3:SetOperation(s.chngop)
	c:RegisterEffect(e3)
	--(4)Self Recycle then Draw
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.tdcon)
	e4:SetTarget(s.tdtg)
	e4:SetOperation(s.tdop)
	c:RegisterEffect(e4)
end
s.listed_names={444000190}
--(3)Change the Monster Type of 1 face-up monster you control
function s.chngtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() and chkc:IsRaceExcept(e:GetLabel()) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCanBeEffectTarget,e),tp,LOCATION_MZONE,0,nil)
	local race=Duel.AnnounceAnotherRace(g,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local sel=g:FilterSelect(tp,Card.IsRaceExcept,1,1,nil,race)
	Duel.SetTargetCard(sel)
	e:SetLabel(race)
end
function s.chngop(e,tp,eg,ep,ev,re,r,rp)
	local races=e:GetLabel()
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRaceExcept(races)) or tc:IsImmuneToEffect(e) then return end
	--Change its Race
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CHANGE_RACE)
	e1:SetValue(races)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	tc:RegisterEffect(e1)	
end
--(4)Self Recycle then Draw
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(444000190)
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_DECK) then
		Duel.ShuffleDeck(tp)
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end