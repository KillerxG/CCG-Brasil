--HN - Uzume
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:AddSetcodesRule(id,true,0x314)--Waifu Arch
	--(1)Activate Field Spell
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--(2)Excavate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)	
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.excatg)
	e2:SetOperation(s.excaop)
	c:RegisterEffect(e2)
end
--(1)Activate Field Spell
function s.actfilter(c,tp)
	return c:IsCode(777003550) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	if not Duel.CheckPhaseActivity() then Duel.RegisterFlagEffect(tp,CARD_MAGICAL_MIDBREAKER,RESET_CHAIN,0,1) end
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local tc=Duel.SelectMatchingCard(tp,s.actfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()	
	Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)							
end
--(2)Excavate
function s.excafilter(c)
  return c:IsFaceup() and c:IsSetCard(0x998) and c:GetRank()>0
end
function s.filter(c)
  return c:IsSetCard(0x998) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.excatg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then
    local lg=Duel.GetMatchingGroup(s.excafilter,tp,LOCATION_MZONE,0,c)
    local ct=lg:GetSum(Card.GetRank)
    if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<ct or ct<1 then return false end
    local g=Duel.GetDecktopGroup(tp,ct)
    return g:FilterCount(Card.IsAbleToHand,nil)>0
  end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function s.thfilter(c)
  return c:IsSetCard(0x998) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.excaop(e,tp,eg,ep,ev,re,r,rp)
  local lg=Duel.GetMatchingGroup(s.excafilter,tp,LOCATION_MZONE,0,c)
  local ct=lg:GetSum(Card.GetRank)
  Duel.ConfirmDecktop(tp,ct)
  local g=Duel.GetDecktopGroup(tp,ct)
  if g:GetCount()>0 then
    local tg=g:Filter(s.filter,nil,e,tp)
    if tg:GetCount()>0 then
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
      local sg=tg:Select(tp,1,1,nil)
      Duel.SendtoHand(sg,nil,REASON_EFFECT)
      Duel.ConfirmCards(1-tp,sg)
    end
    Duel.ShuffleDeck(tp)
    if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil) 
    and g:IsExists(Card.IsCode,1,nil,id) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
      Duel.BreakEffect()
      Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
      local hg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
      if hg:GetCount()>0 then
        Duel.SendtoHand(hg,tp,REASON_EFFECT)
        if hg:GetFirst():IsLocation(LOCATION_HAND) then
          Duel.ConfirmCards(1-tp,hg)
        end
      end
    end
  end
end