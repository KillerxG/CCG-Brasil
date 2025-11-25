--Bestial Hunter
local s,id=GetID()
if not s.global_check then
    s.global_check = true
    s.bp_gy_group = Group.CreateGroup()
    s.bp_gy_group:KeepAlive()

    -- Efeito contínuo global para rastrear envio ao GY durante Battle Phase
    local ge1 = Effect.GlobalEffect()
    ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    ge1:SetCode(EVENT_TO_GRAVE)
    ge1:SetOperation(function(_,tp,eg,ep,ev,re,r,rp)
        if Duel.GetCurrentPhase() >= PHASE_BATTLE_START and Duel.GetCurrentPhase() <= PHASE_BATTLE then
            for tc in aux.Next(eg) do
                if tc:IsReason(REASON_BATTLE+REASON_EFFECT) and tc:IsControler(tp) then
                    s.bp_gy_group:AddCard(tc)
                end
            end
        end
    end)
    Duel.RegisterEffect(ge1,0)

    -- Reset no fim do turno
    local ge2 = Effect.GlobalEffect()
    ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    ge2:SetCode(EVENT_TURN_END)
    ge2:SetOperation(function()
        s.bp_gy_group:Clear()
    end)
    Duel.RegisterEffect(ge2,0)
end
function s.initial_effect(c)
-- Effect: On Normal Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetTarget(s.eqtg)
    e1:SetOperation(s.eqop)
    c:RegisterEffect(e1)

    -- Clone para Special Summon
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
	  -- When this card declares an attack
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_ATTACK_ANNOUNCE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e3:SetTarget(s.target)
    e3:SetOperation(s.operation)
    c:RegisterEffect(e3)
    -- At the end of the Battle Phase: equip up to 5 monsters sent to GY this turn
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCountLimit(1,id)
    e4:SetTarget(s.eqtg2)
    e4:SetOperation(s.eqop2)
    c:RegisterEffect(e4)
end

-- Filtro: "Bestial Weapon" ou qualquer Equip Spell
function s.eqfilter(c)
    return (c:IsSetCard(0x102c) or (c:IsType(TYPE_EQUIP) and c:IsSpell()))
        and not c:IsForbidden()
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
            and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not c:IsFaceup() or not c:IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    local ec=g:GetFirst()
    if ec then
        Duel.Equip(tp,ec,c)
							-- limita o Equip ao alvo escolhido
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(function(e,ec) return ec==mc end)
		c:RegisterEffect(e2)
		-- se for Union, marca estado
		if ec:IsType(TYPE_UNION) then aux.SetUnionState(ec) end
    end
end
-- Filtro: Monstro FIRE no GY com nível adequado
function s.filter(c,e,tp,maxlv)
    return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLevelBelow(maxlv)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    local maxlv=c:GetEquipCount() + 3
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp,maxlv) end
    if chk==0 then
        return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
            and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,maxlv)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,maxlv)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    -- Envia o topo do deck para o GY
    if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<1 then return end
    local top=Duel.GetDecktopGroup(tp,1)
    if Duel.SendtoGrave(top,REASON_EFFECT)==0 then return end

    -- Invoca o monstro alvo se possível
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end
end
-- Filtro: Monstros enviados ao GY neste turno
function s.eqfilter2(c)
    return s.bp_gy_group:IsContains(c)
end
function s.eqtg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_SZONE) > 0
            and s.bp_gy_group:GetCount() > 0
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g = s.bp_gy_group:Select(tp,1,99,nil)
    Duel.SetTargetCard(g)
end
function s.eqop2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end
    local g=Duel.GetTargetCards(e)
    if #g == 0 then return end
    local ct = 0
    for tc in aux.Next(g) do
        if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then break end
        if not tc:IsRelateToEffect(e) or tc:IsForbidden() then goto continue end
        Duel.Equip(tp,tc,c,true)
        -- Equip limit para evitar que se equipe a outros
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetValue(function(e,c) return e:GetOwner()==c end)
        tc:RegisterEffect(e1)
		-- Efeito: Monstro equipado ganha 100 ATK por carta equipada a ele
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_EQUIP)
        e2:SetCode(EFFECT_UPDATE_ATTACK)
        e2:SetValue(s.atkval)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e2)
		-- Efeito 2: Se o monstro atacar um monstro, pode atacar de novo
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
        e3:SetCode(EVENT_DAMAGE_STEP_END)
        e3:SetRange(LOCATION_SZONE)
        e3:SetProperty(EFFECT_FLAG_DELAY)
        e3:SetCondition(s.chainatk_con)
        e3:SetCost(s.chainatk_cost)
        e3:SetOperation(s.chainatk_op)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e3)
        ct = ct + 1
        ::continue::
    end
end
-- Função dinâmica: retorna 100 * quantidade de equips
function s.atkval(e,c)
    if not c then return 0 end
    return c:GetEquipCount() * 100
end
-- Condição: monstro equipado atacou um monstro
function s.chainatk_con(e,tp,eg,ep,ev,re,r,rp)
    local eqc = e:GetHandler():GetEquipTarget()
    local atk = Duel.GetAttacker()
    return eqc and atk == eqc and eqc:IsRelateToBattle()
end

-- Custo: enviar esta carta equipada ao GY
function s.chainatk_cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c = e:GetHandler()
    if chk==0 then return c:IsAbleToGraveAsCost() end
    Duel.SendtoGrave(c,REASON_COST)
end

-- Operação: permite atacar novamente
function s.chainatk_op(e,tp,eg,ep,ev,re,r,rp)
    Duel.ChainAttack()
end