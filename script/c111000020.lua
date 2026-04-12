--Deadlands
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
	-- Efeito 1 (e9, e10, e11): Nenhum jogador pode Invocar Plant ou Fairy ou Insect
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

    -- Efeito 2 (e12): Fiend e Zombie sob seu controle podem atacar 2 vezes
    local e12 = Effect.CreateEffect(c)
    e12:SetType(EFFECT_TYPE_FIELD)
    e12:SetCode(EFFECT_EXTRA_ATTACK)
    e12:SetRange(LOCATION_FZONE)
    e12:SetTargetRange(LOCATION_MZONE, 0)
    e12:SetTarget(aux.TargetBoolFunction(Card.IsRace, RACE_FIEND | RACE_ZOMBIE))
    e12:SetValue(1) -- "1" denota um ataque extra (totalizando 2)
    c:RegisterEffect(e12)

    -- Efeito 3 (e13): Durante sua End Phase: Cara (destrói 1) ou Coroa (toma 800 de dano)
    local e13 = Effect.CreateEffect(c)
    e13:SetDescription(aux.Stringid(id, 0))
    e13:SetCategory(CATEGORY_COIN | CATEGORY_DESTROY | CATEGORY_DAMAGE)
    e13:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_TRIGGER_F)
    e13:SetCode(EVENT_PHASE | PHASE_END)
    e13:SetRange(LOCATION_FZONE)
    e13:SetCountLimit(1)
    e13:SetCondition(s.epcon)
    e13:SetTarget(s.eptg)
    e13:SetOperation(s.epop)
    c:RegisterEffect(e13)

    -- Efeito 4 (e14): Monstros "Despair from the Dark" são inafetados por efeitos de cartas
    local e14 = Effect.CreateEffect(c)
    e14:SetType(EFFECT_TYPE_FIELD)
    e14:SetCode(EFFECT_IMMUNE_EFFECT)
    e14:SetRange(LOCATION_FZONE)
    e14:SetTargetRange(LOCATION_MZONE, 0)
    e14:SetTarget(aux.TargetBoolFunction(Card.IsCode, 73216412))
    e14:SetValue(s.efilter)
    c:RegisterEffect(e14)

    -- Efeito 5 (e15): Monstros "Despair from the Dark" podem atacar diretamente
    local e15 = Effect.CreateEffect(c)
    e15:SetType(EFFECT_TYPE_FIELD)
    e15:SetCode(EFFECT_DIRECT_ATTACK)
    e15:SetRange(LOCATION_FZONE)
    e15:SetTargetRange(LOCATION_MZONE, 0)
    e15:SetTarget(aux.TargetBoolFunction(Card.IsCode, 73216412))
    c:RegisterEffect(e15)
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
		local token=Duel.CreateToken(tp,71200730)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ==========================================================
-- Efeito (e9, e10, e11): Filtro de Bloqueio de Invocação
-- ==========================================================
function s.sumlimit(e, c, sump, sumtype, sumpos, target_p)
    return c:IsRace(RACE_PLANT | RACE_FAIRY | RACE_INSECT)
end

-- ==========================================================
-- Efeito (e13): Cara ou Coroa na End Phase
-- ==========================================================
function s.desfilte(c)
    return not c:IsCode(id,71200730)
end
function s.epcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == tp
end

function s.eptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_COIN, nil, 0, tp, 1)
end

function s.epop(e, tp, eg, ep, ev, re, r, rp)
    local res = Duel.TossCoin(tp, 1)
    if res == COIN_HEADS then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
        -- Escolhe 1 carta no seu lado do campo e a destrói
        local g = Duel.SelectMatchingCard(tp, s.desfilte, tp, LOCATION_ONFIELD, 0, 1, 1, nil)
        if #g > 0 then
            Duel.Destroy(g, REASON_EFFECT)
        end
    elseif res == COIN_TAILS then
        Duel.Damage(tp, 800, REASON_EFFECT)
    end
end

-- ==========================================================
-- Efeito (e14): Imunidade para o "Despair from the Dark"
-- ==========================================================
function s.efilter(e, te)
    return te:GetOwner() ~= e:GetOwner()
end