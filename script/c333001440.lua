--Bestial Weapon Garrot Snake
local s,id=GetID()
function s.initial_effect(c)
	--Equip only to a FIRE or Warrior monster
	aux.AddUnionProcedure(c,s.cfilter)
	-- Trigger: quando o monstro equipado declarar ataque
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetRange(LOCATION_SZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCondition(s.atkcon)
    e1:SetTarget(s.atktg)
    e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)
	--[E2] Substituição de destruição do monstro equipado
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	
	--[E3] Boost de ATK/DEF do equipado
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	local e3b=e3:Clone()
	e3b:SetCode(EFFECT_UPDATE_DEFENSE)
	e3b:SetValue(300)
	c:RegisterEffect(e3b)
	
	-- Trigger: Quando outro "Bestial Weapon" é enviado ao GY
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCountLimit(1,id)
    e4:SetCondition(s.spcon)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) or c:IsRace(RACE_WARRIOR)
end
-- Condição: o monstro equipado é quem declarou o ataque
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local ec=e:GetHandler():GetEquipTarget()
    return ec and Duel.GetAttacker()==ec
end

-- Filtro para monstros válidos no GY
function s.tdfilter(c)
    return (c:IsRace(RACE_WARRIOR) or c:IsAttribute(ATTRIBUTE_FIRE)) 
        and not c:IsType(TYPE_LINK) 
        and (c:GetLevel()>0 or c:GetRank()>0)
        and c:IsAbleToDeck()
end

function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.tdfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ec=c:GetEquipTarget()
    if not ec or not c:IsRelateToEffect(e) then return end

    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
        local val=tc:GetLevel()
        if tc:IsType(TYPE_XYZ) then val=tc:GetRank() end
        if val<=0 then return end

        -- Ganha ATK até o final da próxima End Phase do oponente
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(val*100)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
        ec:RegisterEffect(e1)
    end
end
-- Verifica se uma outra "Bestial Weapon" (exceto esta) foi enviada ao GY
function s.csfilter(c,id)
    return c:IsSetCard(0x102c) and not c:IsCode(id)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.csfilter,1,nil,id)
end

-- Filtro para monstros válidos para Invocação-Especial
function s.spfilter(c,e,tp)
    return (c:IsRace(RACE_WARRIOR) or c:IsAttribute(ATTRIBUTE_FIRE))
        and (c:GetAttack()<=1000 or c:GetDefense()<=1000)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
            and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
        Duel.Equip(tp,c,tc)
		-- limita o Equip ao alvo escolhido
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(function(e,c) return c==mc end)
		c:RegisterEffect(e2)
		-- se for Union, marca estado
		if c:IsType(TYPE_UNION) then aux.SetUnionState(c) end
    end
end