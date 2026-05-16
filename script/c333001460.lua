--Bestial Arsenal
local s,id=GetID()
function s.initial_effect(c)
    -- Effect 0: When this card is activated, search a "Bestial Weapon" monster
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
    e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCountLimit(1,id)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetOperation(s.activate)
    c:RegisterEffect(e0)
    -- Effect 1: Trigger on Warrior being Normal or Special Summoned
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetRange(LOCATION_FZONE)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id+1)
    e1:SetTarget(s.eqtg)
    e1:SetOperation(s.eqop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
	-- E2: When a monster equipped with a "Bestial Weapon" declares an attack
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+2)
	e3:SetCondition(s.attrcon)
	e3:SetTarget(s.attrtg)
	e3:SetOperation(s.attrop)
	c:RegisterEffect(e3)
end
-- Filter for "Bestial Weapon" monster
function s.thfilter(c)
    return c:IsMonster() and c:IsSetCard(0x102c) and c:IsAbleToHand()
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Check if there's a valid "Bestial Weapon" monster in Deck/GY/Banished
    local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
    if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=g:Select(tp,1,1,nil)
        if #sg>0 then
            Duel.SendtoHand(sg,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,sg)
        end
    end
end
-- Filter for Warrior monsters summoned
function s.warriorfilter(c,tp)
    return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:IsControler(tp)
end

-- Filter for Bestial Weapon monsters in hand/GY/banished
function s.eqfilter(c)
    return c:IsSetCard(0x102c) and c:IsMonster() and not c:IsForbidden()
        and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then
        return eg:IsExists(s.warriorfilter,1,nil,tp)
            and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
            and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=eg:Filter(s.warriorfilter,nil,tp)
    local tc=g:Select(tp,1,1,nil):GetFirst()
    Duel.SetTargetCard(tc)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsFaceup() or not tc:IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local ec=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil):GetFirst()
    if not ec then return end

if ec:IsLocation(LOCATION_HAND) then
    Duel.MoveToField(ec,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
end

if Duel.Equip(tp,ec,tc,false) then
    -- Equip limit
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EQUIP_LIMIT)
    e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    e1:SetValue(function(e,c) return c==tc end)
    ec:RegisterEffect(e1)

    -- Union support
		if ec:IsType(TYPE_UNION) then aux.SetUnionState(ec) end
end

    -- Make sure the equipped monster is treated as Union-equipped (for rules engine)
		if ec:IsType(TYPE_UNION) then aux.SetUnionState(ec) end
end
-- Verifica se o atacante está equipado com um "Bestial Weapon"
function s.attrcon(e,tp,eg,ep,ev,re,r,rp)
    local atk=Duel.GetAttacker()
    return atk and atk:IsControler(tp) and atk:IsFaceup() and s.has_bestial_equip(atk)
end

-- Checa se o monstro está equipado com algum "Bestial Weapon"
function s.has_bestial_equip(c)
    local g=c:GetEquipGroup()
    return g:IsExists(function(ec) return ec:IsSetCard(0x102c) end,1,nil)
end

function s.attrtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local atk=Duel.GetAttacker()
    if chk==0 then return atk and s.has_bestial_equip(atk) and Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>0 end
end

function s.attrop(e,tp,eg,ep,ev,re,r,rp)
    local atk=Duel.GetAttacker()
    if not atk or not atk:IsRelateToBattle() then return end

    -- Obtém os atributos dos "Bestial Weapon" equipados ao atacante
    local g=atk:GetEquipGroup():Filter(function(c) return c:IsSetCard(0x102c) and c:IsFaceup() end,nil)
    if #g==0 then return end

    local attr=0
    for ec in g:Iter() do
        attr=attr|ec:GetAttribute()
    end

    local op_deck=Duel.GetFieldGroup(1-tp,LOCATION_DECK,0)
    if #op_deck==0 then return end

    -- Revela o Deck do oponente
    Duel.ConfirmDecktop(1-tp,#op_deck)

    -- Procura por monstros com o mesmo atributo
    local bg=op_deck:Filter(function(c) return c:IsMonster() and c:IsAttribute(attr) and c:IsAbleToRemove() end,nil)
    if #bg>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local rg=bg:Select(tp,1,1,nil)
        Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
    end

    Duel.ShuffleDeck(1-tp)
end