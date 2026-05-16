--Purple Karasu
local s,id=GetID()
function s.initial_effect(c)
    -- E1: Normal Summon sem tributo se não controlar monstros ou todos forem WIND
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SUMMON_PROC)
    e1:SetCondition(s.ntcon)
    c:RegisterEffect(e1)

	--self destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(s.sdcon)
	c:RegisterEffect(e2)
	
	--destroy top
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.dmcon)
	e3:SetOperation(s.nogyop)
	c:RegisterEffect(e3)

    -- E4: Anexar a um Xyz "Karasu"
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_GRAVE|LOCATION_HAND)
	e4:SetCountLimit(1,id+1)
	e4:SetTarget(s.mattg)
	e4:SetOperation(s.matop)
	c:RegisterEffect(e4)


	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(s.e5con)
	e5:SetCost(Cost.DetachFromSelf(1))
	e5:SetTarget(s.e5tg)
	e5:SetOperation(s.e5op)	
	e5:SetCountLimit(1,id+2) -- separa das outras partes do efeito
	c:RegisterEffect(e5)
end

-- E1: Normal Summon sem tributo
function s.ntcon(e,c,minc)
    if c==nil then return true end
    local tp=c:GetControler()
    local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
    return minc==0 and (#g==0 or g:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_WIND)==#g)
end

-- E2: Autodestruição se não houver Zumbi
function s.zyfilter(c)
    return c:IsRace(RACE_ZOMBIE)
end
function s.selfdesop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetMatchingGroupCount(s.zyfilter,tp,LOCATION_GRAVE,0,nil)==0 then
        Duel.Destroy(c,REASON_EFFECT)
    end
end

-- Operação: Destrói este card e depois as 3 do topo do próprio Deck
function s.sdcon(e)
	return not Duel.IsExistingMatchingCard(Card.IsRace,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,RACE_ZOMBIE)
end
function s.dmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rg=Duel.GetDecktopGroup(tp,2)
	return c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP) and #rg>1
end
function s.nogyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
        local g=Duel.GetDecktopGroup(tp,2)
        if #g>1 then
            Duel.Destroy(g,REASON_EFFECT)
        end
end
-- E4: Anexar a Xyz Karasu
function s.matfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x760) and c:IsType(TYPE_XYZ)
end
	--Activation legality
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.matfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.matfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if(e:GetHandler():IsLocation(LOCATION_GRAVE)) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end
end
	--Attach itself to targeted "Sprigguns" Xyz monster from hand, field, or GY
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(tc,c)
	end
end

-- Condição: este card está anexado a um Xyz WIND, e cards do oponente do campo foram ao GY
function s.e5con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOriginalSetCard()==0x760
end
-- Target: verificar se há cards no GY do oponente para banir
function s.e5tg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=eg:FilterCount(function(tc)
        return tc:IsControler(1-tp) 
    end, nil)
    if chk==0 then
        return ct > 0 and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,ct,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,ct,1-tp,LOCATION_GRAVE)
    e:SetLabel(ct)
end

-- Operation: selecionar e banir até ct cards do GY do oponente
function s.e5op(e,tp,eg,ep,ev,re,r,rp)
    local ct=e:GetLabel()
    local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
    if #g>=ct then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local sg=g:Select(tp,ct,ct,nil)
        Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
    end
end