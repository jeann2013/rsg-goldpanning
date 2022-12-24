local RSGCore = exports['rsg-core']:GetCoreObject()
local panning = false
local canPan = false

RegisterNetEvent('rsg-goldpanning:client:StartGoldPan')
AddEventHandler('rsg-goldpanning:client:StartGoldPan', function()
	local ped = PlayerPedId()
	local coords = GetEntityCoords(ped)
	local water = Citizen.InvokeNative(0x5BA7A68A346A5A91, coords.x, coords.y, coords.z)
	if panning == false then
		for k,v in pairs(Config.WaterTypes) do 
			if water == Config.WaterTypes[k]["waterhash"]  then
				canPan = true           
				break            
			end
		end
		if canPan == true then
			panning = true
			AttachPan()
			CrouchAnim()
			Wait(6000)
			ClearPedTasks(ped)
			GoldShake()
			local randomwait = math.random(12000,28000)
			Wait(randomwait)
			DeletePan(prop_goldpan) 
			TriggerServerEvent('rsg-goldpanning:server:reward')
			panning = false
		else
			RSGCore.Functions.Notify('you need to be by the river to goldpan', 'primary')
		end
	else
		RSGCore.Functions.Notify('you are already goldpanning!', 'error')
	end
end)

-- attach gold pan to ped
function AttachPan()
    if not DoesEntityExist(prop_goldpan) then
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local modelHash = GetHashKey("P_CS_MININGPAN01X")  
    LoadModel(modelHash)    
    prop_goldpan = CreateObject(modelHash, coords.x+0.30, coords.y+0.10,coords.z, true, false, false)
    SetEntityVisible(prop_goldpan, true)
    SetEntityAlpha(prop_goldpan, 255, false)
    Citizen.InvokeNative(0x283978A15512B2FE, prop_goldpan, true)   
    local boneIndex = GetEntityBoneIndexByName(ped, "SKEL_R_HAND")
    AttachEntityToEntity(prop_goldpan, PlayerPedId(), boneIndex, 0.2, 0.0, -0.20, -100.0, -50.0, 0.0, false, false, false, true, 2, true)
    SetModelAsNoLongerNeeded(modelHash)
    end
end

-- ped crouch
function CrouchAnim()
    local dict = "script_rc@cldn@ig@rsc2_ig1_questionshopkeeper"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    TaskPlayAnim(ped, dict, "inspectfloor_player", 0.5, 8.0, -1, 1, 0, false, false, false)
end

-- ped does gold shake anim
function GoldShake()
    local dict = "script_re@gold_panner@gold_success"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
    TaskPlayAnim(PlayerPedId(), dict, "SEARCH02", 1.0, 8.0, -1, 1, 0, false, false, false)
end

-- delete goldpan prop
function DeletePan(entity)
    DeleteObject(entity)
    DeleteEntity(entity)
    Wait(100)          
    ClearPedTasks(PlayerPedId())
end

-- ensure prop is loaded
function LoadModel(model)
    local attempts = 0
    while attempts < 100 and not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(10)
        attempts = attempts + 1
    end
    return IsModelValid(model)
end
