VampireHunter = {}
VampireHunter.CardEffects = {}
VampireHunter.InheritedIDs = setmetatable({}, { __mode = "k" })

function VampireHunter.GetIDSet(c)
    local t = VampireHunter.InheritedIDs[c]
    if not t then
        t = {}
        VampireHunter.InheritedIDs[c] = t
    end
    return t
end

function VampireHunter.ApplyIDSet(rc, idset)
    for id, _ in pairs(idset) do
        local f = VampireHunter.CardEffects[id]
        if f then f(rc) end
    end
end

function VampireHunter.GrantOwnEffect(rc)
    local code = rc:GetOriginalCodeRule() or rc:GetCode()
    local rcset = VampireHunter.GetIDSet(rc)
    if not rcset[code] then
        rcset[code] = true
        VampireHunter.ApplyIDSet(rc, { [code] = true })
    end
end

function VampireHunter.RitualCost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return not c:IsPublic() end
    Duel.ConfirmCards(1 - tp, c)
    local te = Effect.CreateEffect(c)
    te:SetType(EFFECT_TYPE_SINGLE)
    te:SetCode(EFFECT_PUBLIC)
    te:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(te)
end

function VampireHunter.CardFilter(c)
    -- ADICIONADO: Conta a carta oficial do TCG também!
    return c:IsSetCard(0x108e) or c:IsCode(80485722)
end

function VampireHunter.ExtraMaterial(e, tp, eg, ep, ev, re, r, rp, chk)
    return Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, LOCATION_GRAVE, 0, nil):Filter(Card.HasLevel, nil)
end

function VampireHunter.AddSelfRitual(c, desc)
    local e1 = Ritual.AddProcGreater({
        handler = c,
        filter = VampireHunter.CardFilter,
        desc = desc,
        location = LOCATION_HAND + LOCATION_GRAVE,
        extrafil = VampireHunter.ExtraMaterial,
    })
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCost(VampireHunter.RitualCost)
    c:RegisterEffect(e1)
    return e1
end

function VampireHunter.AddExternalRitual(c, desc, also_grave, self_grant)
    if self_grant == nil then self_grant = true end
    local location = LOCATION_HAND
    if also_grave then location = LOCATION_HAND + LOCATION_GRAVE end

    return Ritual.AddProcGreater({
        handler = c,
        filter = VampireHunter.CardFilter,
        desc = desc,
        location = location,
        extrafil = VampireHunter.ExtraMaterial,
        stage2 = function(mat, e, tp, eg, ep, ev, re, r, rp, tc)
            if self_grant then VampireHunter.GrantOwnEffect(tc) end
        end,
    })
end

-- Herança em Cadeia (SEM a regra de enviar pro GY cópias extras)
function VampireHunter.RegisterInheritedEffect(c, specific_id, apply_func)
    VampireHunter.CardEffects[specific_id] = apply_func

    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EVENT_BE_MATERIAL)
    e1:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local mat = e:GetHandler()
        local rc = mat:GetReasonCard()
        
        -- ADICIONADO: Checa o Setcode ou o ID da carta do TCG
        if not rc or r ~= REASON_RITUAL or not (rc:IsSetCard(0x108e) or rc:IsCode(80485722)) then return false end

        local loc = mat:GetPreviousLocation()
        local from_field = (loc == LOCATION_MZONE)
        local from_gy_properly = (loc == LOCATION_GRAVE and mat:IsStatus(STATUS_PROC_COMPLETE))
        local is_same_name = rc:IsCode(specific_id)

        return from_field or from_gy_properly or is_same_name
    end)
    e1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local mat = e:GetHandler()
        local rc = mat:GetReasonCard()
        if not rc then return end

        local rcset = VampireHunter.GetIDSet(rc)
        local matset = VampireHunter.GetIDSet(mat)

        local toAdd = {}
        if not rcset[specific_id] then toAdd[specific_id] = true end
        
        if mat:GetPreviousLocation() == LOCATION_MZONE then
            for id, _ in pairs(matset) do
                if not rcset[id] then toAdd[id] = true end
            end
        end

        for id, _ in pairs(toAdd) do
            rcset[id] = true
        end
        VampireHunter.ApplyIDSet(rc, toAdd)
    end)
    c:RegisterEffect(e1)
end