--Infernal Cave
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--(1)Neither Player can Special Summon Link
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetTargetRange(1, 1)
    e2:SetTarget(s.splimit)
    c:RegisterEffect(e2)
	--(2)Unaffected
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_FZONE)
    e3:SetValue(1)
    c:RegisterEffect(e3)
	--(3)You cannot activate Field Spells
	local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCode(EFFECT_CANNOT_ACTIVATE)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetTargetRange(1, 0)
    e4:SetValue(s.aclimit)
    c:RegisterEffect(e4)
	--(4)Discard 1 card
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 0))
    e5:SetCategory(CATEGORY_TOGRAVE)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_FZONE)
    e5:SetTarget(s.tgtg)
    e5:SetOperation(s.tgop)
    c:RegisterEffect(e5)
	--(5)Your or your opponent Lose LP
	local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 1))
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetRange(LOCATION_FZONE)
    e6:SetTarget(s.lptg)
    e6:SetOperation(s.lpop)
    c:RegisterEffect(e6)
	--(6)Negate directly attack
    local e7 = Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id, 2))
    e7:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_TRIGGER_O)
    e7:SetCode(EVENT_ATTACK_ANNOUNCE)
    e7:SetRange(LOCATION_FZONE)
    e7:SetCountLimit(1)
    e7:SetCondition(s.negcon)
    e7:SetOperation(s.negop)
    c:RegisterEffect(e7)
	--(7)Call ???
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,6))
	e8:SetType(EFFECT_TYPE_IGNITION)
	e8:SetRange(LOCATION_FZONE)
	e8:SetCountLimit(1)
	e8:SetTarget(s.tktg)
	e8:SetOperation(s.tkop)
	c:RegisterEffect(e8)
	-- Efeito 1 (e9, e10, e11): Nenhum jogador pode Invocar Fish, Aqua ou Sea Serpent
    local e9 = Effect.CreateEffect(c)
    e9:SetType(EFFECT_TYPE_FIELD)
    e9:SetCode(EFFECT_CANNOT_SUMMON)
    e9:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e9:SetRange(LOCATION_FZONE)
    e9:SetTargetRange(1, 1)
    e9:SetTarget(s.sumlimit)
    c:RegisterEffect(e9)
    local e10 = e9:Clone()
    e10:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    c:RegisterEffect(e10)
    local e11 = e9:Clone()
    e11:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
    c:RegisterEffect(e11)

    -- Efeito 2 (e12): Monstros Machine e Cyberse no campo perdem 2000 de ATK
    local e12 = Effect.CreateEffect(c)
    e12:SetType(EFFECT_TYPE_FIELD)
    e12:SetCode(EFFECT_UPDATE_ATTACK)
    e12:SetRange(LOCATION_FZONE)
    -- Afeta as zonas de monstros de ambos os jogadores
    e12:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    e12:SetTarget(aux.TargetBoolFunction(Card.IsRace, RACE_MACHINE | RACE_CYBERSE))
    e12:SetValue(-2000)
    c:RegisterEffect(e12)

    -- Efeito 3 (e13): Monstros WATER no campo têm seus efeitos negados
    local e13 = Effect.CreateEffect(c)
    e13:SetType(EFFECT_TYPE_FIELD)
    e13:SetCode(EFFECT_DISABLE)
    e13:SetRange(LOCATION_FZONE)
    e13:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    e13:SetTarget(aux.TargetBoolFunction(Card.IsAttribute, ATTRIBUTE_WATER))
    c:RegisterEffect(e13)

    -- Efeito 4 (e14): Durante a SUA End Phase: Infligir 500 de dano a ambos os jogadores
    local e14 = Effect.CreateEffect(c)
    e14:SetDescription(aux.Stringid(id, 0))
    e14:SetCategory(CATEGORY_DAMAGE)
    e14:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_TRIGGER_F)
    e14:SetCode(EVENT_PHASE | PHASE_END)
    e14:SetRange(LOCATION_FZONE)
    e14:SetCountLimit(1)
    e14:SetCondition(s.damcon)
    e14:SetTarget(s.damtg)
    e14:SetOperation(s.damop)
    c:RegisterEffect(e14)

    -- Efeito 5 (e15): "Infernal Flame Emperor" sob o seu controle é inafetado por efeitos de cartas
    local e15 = Effect.CreateEffect(c)
    e15:SetType(EFFECT_TYPE_FIELD)
    e15:SetCode(EFFECT_IMMUNE_EFFECT)
    e15:SetRange(LOCATION_FZONE)
    e15:SetTargetRange(LOCATION_MZONE, 0)
    e15:SetTarget(aux.TargetBoolFunction(Card.IsCode, 19847532))
    e15:SetValue(s.efilter)
    c:RegisterEffect(e15)

    -- Efeito 6 (e16): "Infernal Flame Emperor" sob o seu controle pode atacar diretamente
    local e16 = Effect.CreateEffect(c)
    e16:SetType(EFFECT_TYPE_FIELD)
    e16:SetCode(EFFECT_DIRECT_ATTACK)
    e16:SetRange(LOCATION_FZONE)
    e16:SetTargetRange(LOCATION_MZONE, 0)
    e16:SetTarget(aux.TargetBoolFunction(Card.IsCode, 19847532))
    c:RegisterEffect(e16)
end
s.af="a"
s.tableAction = {
150000024,150000001,150000002,150000003,150000004,150000020,150000021,150000030,
150000033,150000005,150000006,150000009,150000010,150000022,150000023,150000031,
150000042,150000011,150000012,150000014,150000015,150000025,150000026,150000032,
150000071,150000016,150000017,150000018,150000019,150000028,150000029,150000035,
150000013,150000038,150000040
}
--(1)Neither Player can Special Summon Link
function s.splimit(e, c)
    return c:IsType(TYPE_LINK)
end
--(3)You cannot activate Field Spells
function s.aclimit(e, re, tp)
    return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsType(TYPE_FIELD)
end
--(4)Discard 1 card
function s.tgfilter(c)
    return c:IsAbleToGrave()
end
function s.tgtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.tgfilter, tp, LOCATION_HAND, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_HAND)
end
function s.tgop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.tgfilter, tp, LOCATION_HAND, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoGrave(g, REASON_EFFECT)
    end
end
--(5)Your or your opponent Lose LP
function s.lptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_NUMBER)
    local num = Duel.AnnounceNumber(tp, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200)
    Duel.SetTargetParam(num)
end
function s.lpop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end    
    local num = Duel.GetChainInfo(0, CHAININFO_TARGET_PARAM)    
    local op = Duel.SelectOption(tp, aux.Stringid(id, 3), aux.Stringid(id, 4))
    local target_player = (op == 0) and tp or (1 - tp)    
    local current_lp = Duel.GetLP(target_player)
    local new_lp = math.max(0, current_lp - num)
    Duel.SetLP(target_player, new_lp)
end
--(6)Negate directly attack
function s.negcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetAttacker():IsControler(1 - tp) and Duel.GetAttackTarget() == nil
end
function s.negop(e, tp, eg, ep, ev, re, r, rp)
    Duel.NegateAttack()
end
--(7)Call ???
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local token=Duel.CreateToken(tp,19847532)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ==========================================================
-- Efeito (e9, e10, e11): Filtro de Bloqueio de Invocação
-- ==========================================================
function s.sumlimit(e, c, sump, sumtype, sumpos, target_p)
    return c:IsRace(RACE_FISH | RACE_AQUA | RACE_SEASERPENT)
end

-- ==========================================================
-- Efeito (e14): Dano Simultâneo na sua End Phase
-- ==========================================================
function s.damcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == tp
end

function s.damtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, PLAYER_ALL, 500)
end

function s.damop(e, tp, eg, ep, ev, re, r, rp)
    -- O parâmetro "true" instrui a máquina a adiar o registro até a conclusão da cadeia 
    Duel.Damage(tp, 500, REASON_EFFECT, true)
    Duel.Damage(1 - tp, 500, REASON_EFFECT, true)
    Duel.RDComplete() 
end

-- ==========================================================
-- Efeito (e15): Imunidade para o Infernal Flame Emperor
-- ==========================================================
function s.efilter(e, te)
    return te:GetOwner() ~= e:GetOwner()
end