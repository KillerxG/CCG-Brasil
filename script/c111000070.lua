--Twilight Lake
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
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
	e8:SetDescription(aux.Stringid(id,5))
	e8:SetType(EFFECT_TYPE_IGNITION)
	e8:SetRange(LOCATION_FZONE)
	e8:SetCountLimit(1)
	e8:SetTarget(s.tktg)
	e8:SetOperation(s.tkop)
	c:RegisterEffect(e8)
	-- Efeito 1 (e9): Dar alvo em Beast-Warrior com Nível; Invocar do Extra Deck com mesmo Nível e nome diferente
    local e9 = Effect.CreateEffect(c)
    e9:SetDescription(aux.Stringid(id, 6))
    e9:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e9:SetType(EFFECT_TYPE_IGNITION)
    e9:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e9:SetRange(LOCATION_FZONE)
    e9:SetCountLimit(1)
    e9:SetTarget(s.sptg)
    e9:SetOperation(s.spop)
    c:RegisterEffect(e9)

    -- Efeito 2 (e10): Descartar 1 carta; Comprar 1 carta
    local e10 = Effect.CreateEffect(c)
    e10:SetDescription(aux.Stringid(id, 7))
    e10:SetCategory(CATEGORY_DRAW)
    e10:SetType(EFFECT_TYPE_IGNITION)
    e10:SetRange(LOCATION_FZONE)
    e10:SetCountLimit(1)
    e10:SetCost(s.drcost)
    e10:SetTarget(s.drtg)
    e10:SetOperation(s.drop)
    c:RegisterEffect(e10)
end
s.af="a"
s.tableAction = {
111000071,111000072,111000073,111000074,111000075, --Traps Custom
150000010,150000011,150000016,150000017,150000021, --Spells Anime
111000201,111000202,111000203,111000204,111000205, --Spells Custom
111000206,111000207,111000208,111000209,111000210  --Spells Custom
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
		local token=Duel.CreateToken(tp,54701958)
		Duel.SpecialSummon(token,0,tp,tp,true,true,POS_FACEUP)
	end
end
-- ==========================================================
-- Efeito (e9): Target e Special Summon do Extra Deck
-- ==========================================================
function s.spfilter1(c, e, tp)
    -- Verifica se tem Nível e se existe um correspondente válido no Extra Deck
    return c:IsFaceup() and c:IsRace(RACE_BEASTWARRIOR) and c:HasLevel()
        and Duel.IsExistingMatchingCard(s.spfilter2, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, c:GetLevel(), c:GetCode())
end

function s.spfilter2(c, e, tp, lv, code)
    -- Deve ser Beast-Warrior, ter o mesmo Nível, nome diferente e ser Invocável
    return c:IsRace(RACE_BEASTWARRIOR) and c:GetLevel() == lv and not c:IsCode(code)
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.spfilter1(chkc, e, tp) end
    -- GetLocationCountFromEx é a função moderna mandatória para verificar o espaço antes de invocações do Extra Deck
    if chk == 0 then return Duel.GetLocationCountFromEx(tp) > 0
        and Duel.IsExistingTarget(s.spfilter1, tp, LOCATION_MZONE, 0, 1, nil, e, tp) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g = Duel.SelectTarget(tp, s.spfilter1, tp, LOCATION_MZONE, 0, 1, 1, nil, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    -- Verifica se o alvo ainda é válido e se há espaço no Extra Monster Zone / Main Monster Zone
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCountFromEx(tp) > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local g = Duel.SelectMatchingCard(tp, s.spfilter2, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp, tc:GetLevel(), tc:GetCode())
        if #g > 0 then
            Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
        end
    end
end

-- ==========================================================
-- Efeito (e10): Descartar e Comprar (Draw)
-- ==========================================================
function s.drcost(e, tp, eg, ep, ev, re, r, rp, chk)
    -- Verifica se existe uma carta descartável na mão para pagar o custo 
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, nil) end
    Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1, REASON_COST | REASON_DISCARD)
end

function s.drtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDraw(tp, 1) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.drop(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    Duel.Draw(p, d, REASON_EFFECT)
end