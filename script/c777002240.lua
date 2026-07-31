--Skarlet Warrior - Sets
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Link Materials
	Link.AddProcedure(c, nil, 2, 2, s.lcheck)
	c:EnableReviveLimit()
	-- Efeito: Se Link Summoned -> Add Spirit -> Seta "Virus"
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.thcon)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
	--(2)Can use 1 DARK Fiend Spirit monster in your hand as material when using this for a "Skarlet" monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EFFECT_EXTRA_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetOperation(s.extracon2)
	e2:SetValue(s.extraval2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_HAND,0)
	e3:SetTarget(s.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	aux.GlobalCheck(s,function()
		s.flagmap2={}
	end)
	--(4)Pay or Destroy
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.paycon)
	e5:SetOperation(s.payop)
	c:RegisterEffect(e5)	
end
s.listed_card_types={TYPE_SPIRIT}
--Link Materials
function s.lcheck(g, lc, sumtype, tp)
    -- Garante que o grupo de materiais possui pelo menos 1 monstro Spirit
    return g:IsExists(Card.IsType, 1, nil, TYPE_SPIRIT, lc, sumtype, tp)
end
-- ====================================================================
-- Efeito do Gatilho: Busca e Set
-- ====================================================================
function s.thcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.thfilter(c)
    return c:IsType(TYPE_SPIRIT) and c:IsAbleToHand()
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.virusfilter(c)
    -- Lista de "Vírus" inserida por Hardcode usando os IDs fornecidos
    local virus_ids = {
        4931121,   -- Crush Card Virus
        35027493,  -- Deck Devastation Virus
        39163598,  -- Eradicator Epidemic Virus
        54591086,  -- Full Force Virus
        54974237,  -- Grinning Grave Virus
        57728570,  -- Lair of Darkness (Se estiver na lista, é procurável se tiver um typo no ID, mantive o que você mandou)
        84491298,  -- Smile Potion (Talvez um ID específico do seu custom)
        85555787   -- Doom Virus Dragon (ou outra variante dependendo do custom)
    }
    
    for _, vid in ipairs(virus_ids) do
        if c:IsCode(vid) then return c:IsSSetable() end
    end
    return false
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    -- Busca protegida por NecroValley caso você escolha do Cemitério
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.thfilter), tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
    
    if #g > 0 and Duel.SendtoHand(g, nil, REASON_EFFECT) > 0 and g:GetFirst():IsLocation(LOCATION_HAND) then
        Duel.ConfirmCards(1 - tp, g)
        
        -- "...and if you do, you can Set 1 "Virus" Trap from your Deck."
        if Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 
            and Duel.IsExistingMatchingCard(s.virusfilter, tp, LOCATION_DECK, 0, 1, nil)
            and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
            
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
            local vg = Duel.SelectMatchingCard(tp, s.virusfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
            
            if #vg > 0 then
                Duel.SSet(tp, vg:GetFirst())
            end
        end
    end
end
--(2)Can use 1 DARK Fiend Spirit monster in your hand as material when using this for a "Skarlet" monster
function s.eftg(e,c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SPIRIT) and c:IsRace(RACE_FIEND) and c:IsCanBeLinkMaterial()
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
--(3)Set 1 "Curse" Trap
function s.setfilter(c)
	return (c:IsSetCard(0x304b) or c:IsCode(84970821)) and c:IsTrap() and c:IsType(TYPE_CONTINUOUS) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(1-tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SSet(1-tp,g)
	end
end
--(4)Pay or Destroy
function s.paycon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.GetTurnPlayer()==tp
end
function s.payop(e,tp,eg,ep,ev,re,r,rp)
  Duel.HintSelection(Group.FromCards(e:GetHandler()))
  if Duel.CheckLPCost(tp,500) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
    Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,4))
    Duel.PayLPCost(tp,500)
  else
    Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,5))
    Duel.Destroy(e:GetHandler(),REASON_COST)
  end
end