--SAO Allies
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Excavate
	local e1=Effect.CreateEffect(c)	
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.exctg)
	e1:SetOperation(s.excop)
	c:RegisterEffect(e1)
end
--(1)Excavate
function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk)
  local c=e:GetHandler()
  local ct=Duel.GetCounter(c:GetControler(),1,0,0x1297)*2
  if chk==0 then return ct>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=ct end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function s.excfilter(c)
  return c:IsAbleToHand() and c:IsSetCard(0x282) and not c:IsCode(id)
end
function s.archerfilter(c)
  return c:IsFaceup() and c:IsSetCard(0x282a) and c:IsType(TYPE_SYNCHRO)
end
function s.excop(e,tp,eg,ep,ev,re,r,rp)
  local ac=Duel.GetCounter(e:GetHandler():GetControler(),1,0,0x1297)*2
  Duel.ConfirmDecktop(tp,ac)
  local g=Duel.GetDecktopGroup(tp,ac)
  if #g>0 and g:IsExists(s.excfilter,1,nil) then
	local ct=1
	if Duel.IsExistingMatchingCard(s.archerfilter,tp,LOCATION_MZONE,0,1,nil) then
	  ct=2
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:FilterSelect(tp,s.excfilter,1,ct,nil)
	Duel.DisableShuffleCheck()
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleHand(tp)
	Duel.RemoveCounter(tp,1,0,0x1297,1,REASON_EFFECT)
	g:Sub(sg)
  end
  if ac>0 then
	Duel.SortDecktop(tp,tp,#g)
	for i=1,#g do
	  local mg=Duel.GetDecktopGroup(tp,1)
	  Duel.MoveSequence(mg:GetFirst(),1)
	end
  end
end
