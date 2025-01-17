QBCore = exports['qb-core']:GetCoreObject() -- Used Globally
inJail = false
jailTime = 0
currentJob = "electrician"
CellsBlip = nil
TimeBlip = nil
ShopBlip = nil
PlayerJob = {}

-- Functions
function prisonClothes()
    local Player = QBCore.Functions.GetPlayerData()
    local player = PlayerPedId()
    local gender = Player.charinfo.gender
    if gender == 0 then -- Male
        -- (player, propindex, prop, texture) [[ Only need to edit prop & texure to change clothes ]]

        -- Just sets to 0 to remove any props they may have
        SetPedPropIndex(player, 0, 11, 0) -- Hat
        SetPedPropIndex(player, 1, -1, 0) -- Glasses
        SetPedPropIndex(player, 2, -1, 0) -- Ear
        SetPedPropIndex(player, 6, -1, 0) -- Watch
        SetPedPropIndex(player, 7, -1, 0) -- Bracelet
        SetPedComponentVariation(player, 1, 0, 0) -- Mask
        SetPedComponentVariation(player, 5, 0, 0) -- Bag/Parachute
        SetPedComponentVariation(player, 9, 0, 0) -- Kevlar?
        SetPedComponentVariation(player, 10, 0, 0) -- Badge
        SetPedComponentVariation(player, 7, 0, 0) -- Accessory
        
        -- Actual Prison Outfit
        SetPedComponentVariation(player, 3, 5, 0) -- Torso
        SetPedComponentVariation(player, 11, 237, 0) -- Torso 2
        SetPedComponentVariation(player, 8, 15, 0) -- Undershirt
        SetPedComponentVariation(player, 4, 64, 6) -- Pants
        SetPedComponentVariation(player, 6, 8, 0) -- Shoes
    else -- Female
        -- (player, propindex, prop, texture) [[ Only need to edit prop & texure to change clothes ]]

        -- Just sets to 0 to remove any props they may have
        SetPedPropIndex(player, 0, -1, 0) -- Hat
        SetPedPropIndex(player, 1, -1, 0) -- Glasses
        SetPedPropIndex(player, 2, -1, 0) -- Ear
        SetPedPropIndex(player, 6, -1, 0) -- Watch
        SetPedPropIndex(player, 7, -1, 0) -- Bracelet
        SetPedComponentVariation(player, 1, 0, 0) -- Mask
        SetPedComponentVariation(player, 5, 0, 0) -- Bag/Parachute
        SetPedComponentVariation(player, 9, 0, 0) -- Kevlar?
        SetPedComponentVariation(player, 10, 0, 0) -- Badge
        SetPedComponentVariation(player, 7, 0, 0) -- Accessory
        
        -- Actual Prison Outfit
        SetPedComponentVariation(player, 3, 14, 0) -- Torso
        SetPedComponentVariation(player, 11, 338, 0) -- Torso 2
        SetPedComponentVariation(player, 8, 2, 0) -- Undershirt
        SetPedComponentVariation(player, 4, 66, 6) -- Pants
        SetPedComponentVariation(player, 6, 1, 0) -- Shoes
    end
end

function DrawText3D(x, y, z, text) -- Used Globally
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

local function CreateCellsBlip()

	if TimeBlip ~= nil then
		RemoveBlip(TimeBlip)
	end
	TimeBlip = AddBlipForCoord(Config.Locations["freedom"].coords.x, Config.Locations["freedom"].coords.y, Config.Locations["freedom"].coords.z)

	SetBlipSprite (TimeBlip, 466)
	SetBlipDisplay(TimeBlip, 4)
	SetBlipScale  (TimeBlip, 0.8)
	SetBlipAsShortRange(TimeBlip, true)
	SetBlipColour(TimeBlip, 4)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName("Time check")
	EndTextCommandSetBlipName(TimeBlip)

	if ShopBlip ~= nil then
		RemoveBlip(ShopBlip)
	end
	ShopBlip = AddBlipForCoord(Config.Locations["shop"].coords.x, Config.Locations["shop"].coords.y, Config.Locations["shop"].coords.z)

	SetBlipSprite (ShopBlip, 52)
	SetBlipDisplay(ShopBlip, 4)
	SetBlipScale  (ShopBlip, 0.5)
	SetBlipAsShortRange(ShopBlip, true)
	SetBlipColour(ShopBlip, 0)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName("Canteen")
	EndTextCommandSetBlipName(ShopBlip)
end

-- Events

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	QBCore.Functions.GetPlayerData(function(PlayerData)
		if PlayerData.metadata["injail"] > 0 then
			TriggerEvent("prison:client:Enter", PlayerData.metadata["injail"])
		end
	end)

	QBCore.Functions.TriggerCallback('prison:server:IsAlarmActive', function(active)
		if active then
			TriggerEvent('prison:client:JailAlarm', true)
		end
	end)

	PlayerJob = QBCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
	inJail = false
	currentJob = nil
	RemoveBlip(currentBlip)
end)

RegisterNetEvent('prison:client:Enter', function(time)
	QBCore.Functions.Notify( Lang:t("error.injail", {Time = time}), "error")
	TriggerServerEvent("prison:server:Enter",true)
	TriggerEvent("chatMessage", "SYSTEM", "warning", "Your property has been seized, you'll get everything back when your time is up..")
	DoScreenFadeOut(500)
	while not IsScreenFadedOut() do
		Wait(10)
	end
	local RandomStartPosition = Config.Locations.spawns[math.random(1, #Config.Locations.spawns)]
	SetEntityCoords(PlayerPedId(), RandomStartPosition.coords.x, RandomStartPosition.coords.y, RandomStartPosition.coords.z - 0.9, 0, 0, 0, false)
	SetEntityHeading(PlayerPedId(), RandomStartPosition.coords.w)
	prisonClothes()
	Wait(500)
	TriggerEvent('animations:client:EmoteCommandStart', {RandomStartPosition.animation})

	inJail = true
	jailTime = time
	currentJob = "electrician"
	TriggerServerEvent("prison:server:SetJailStatus", jailTime)
	TriggerServerEvent("prison:server:SaveJailItems", jailTime)
	TriggerServerEvent("InteractSound_SV:PlayOnSource", "jail", 0.5)
	CreateCellsBlip()
	Wait(2000)
	DoScreenFadeIn(1000)
	QBCore.Functions.Notify( Lang:t("error.do_some_work", {currentjob = Config.Jobs[currentJob] }), "error")
	Wait(2000)
	ClearPedTasks(PlayerPedId())
end)

RegisterNetEvent('prison:client:Leave', function()
	if jailTime > 0 then
		QBCore.Functions.Notify( Lang:t("info.timeleft", {JAILTIME = jailTime}))
	else
		jailTime = 0
		TriggerServerEvent("prison:server:SetJailStatus", 0)
		TriggerServerEvent("prison:server:GiveJailItems")
		TriggerServerEvent("prison:server:Leave",true)
		TriggerEvent("chatMessage", "SYSTEM", "warning", "you've received your property back..")
		inJail = false
		RemoveBlip(currentBlip)
		RemoveBlip(CellsBlip)
		CellsBlip = nil
		RemoveBlip(TimeBlip)
		TimeBlip = nil
		RemoveBlip(ShopBlip)
		ShopBlip = nil
		QBCore.Functions.Notify(Lang:t("success.free_"))
		DoScreenFadeOut(500)
		while not IsScreenFadedOut() do
			Wait(10)
		end
		SetEntityCoords(PlayerPedId(), Config.Locations["outside"].coords.x, Config.Locations["outside"].coords.y, Config.Locations["outside"].coords.z, 0, 0, 0, false)
		SetEntityHeading(PlayerPedId(), Config.Locations["outside"].coords.w)
		prisonClothes()
		TriggerServerEvent("qb-clothes:loadPlayerSkin")
		Wait(500)

		DoScreenFadeIn(1000)
	end
end)

RegisterNetEvent('prison:client:UnjailPerson', function()
	if jailTime > 0 then
		TriggerServerEvent("prison:server:SetJailStatus", 0)
		TriggerServerEvent("prison:server:GiveJailItems")
		TriggerEvent("chatMessage", "SYSTEM", "warning", "You got your property back..")
		inJail = false
		RemoveBlip(currentBlip)
		RemoveBlip(CellsBlip)
		CellsBlip = nil
		RemoveBlip(TimeBlip)
		TimeBlip = nil
		RemoveBlip(ShopBlip)
		ShopBlip = nil
		QBCore.Functions.Notify(Lang:t("success.free_"))
		DoScreenFadeOut(500)
		while not IsScreenFadedOut() do
			Wait(10)
		end
		SetEntityCoords(PlayerPedId(), Config.Locations["outside"].coords.x, Config.Locations["outside"].coords.y, Config.Locations["outside"].coords.z, 0, 0, 0, false)
		SetEntityHeading(PlayerPedId(), Config.Locations["outside"].coords.w)
		Wait(500)
		DoScreenFadeIn(1000)
	end
end)

RegisterNetEvent('prison:client:UnjailPersonToHospital', function()
		print("HELLO I AM TRIGGERED")
		TriggerServerEvent("prison:server:Leave",true)
		TriggerServerEvent("prison:server:SetJailStatus", 0)
		TriggerServerEvent("prison:server:GiveJailItems")
		TriggerEvent("chatMessage", "SYSTEM", "warning", "You got your property back..")
		inJail = false
		RemoveBlip(currentBlip)
		RemoveBlip(CellsBlip)
		CellsBlip = nil
		RemoveBlip(TimeBlip)
		TimeBlip = nil
		RemoveBlip(ShopBlip)
		ShopBlip = nil

end)

AddEventHandler("prison:client:setTime", function (time)
	jailTime = time
	TriggerServerEvent("prison:server:SetJailStatus", time)
end)
-- Threads

CreateThread(function()
    TriggerEvent('prison:client:JailAlarm', false)
	while true do
		Wait(7)
		if jailTime > 0 and inJail then
			Wait(1000 * 60)
			if jailTime > 0 and inJail then
				jailTime = jailTime - 1
				if jailTime <= 0 then
					jailTime = 0
					QBCore.Functions.Notify(Lang:t("success.timesup"), "success", 10000)
				end
				TriggerServerEvent("prison:server:SetJailStatus", jailTime)
			end
		else
			Wait(5000)
		end
	end
end)

CreateThread(function()
	while true do
		Wait(1)
		if LocalPlayer.state.isLoggedIn then
			if inJail then
				local pos = GetEntityCoords(PlayerPedId())
				if #(pos - vector3(Config.Locations["freedom"].coords.x, Config.Locations["freedom"].coords.y, Config.Locations["freedom"].coords.z)) < 1.5 then
					DrawText3D(Config.Locations["freedom"].coords.x, Config.Locations["freedom"].coords.y, Config.Locations["freedom"].coords.z, "~g~E~w~ - Check time")
					if IsControlJustReleased(0, 38) then
						TriggerEvent("prison:client:Leave")
					end
				elseif #(pos - vector3(Config.Locations["freedom"].coords.x, Config.Locations["freedom"].coords.y, Config.Locations["freedom"].coords.z)) < 2.5 then
					DrawText3D(Config.Locations["freedom"].coords.x, Config.Locations["freedom"].coords.y, Config.Locations["freedom"].coords.z, "Check time")
				end

				if #(pos - vector3(Config.Locations["shop"].coords.x, Config.Locations["shop"].coords.y, Config.Locations["shop"].coords.z)) < 1.5 then
					DrawText3D(Config.Locations["shop"].coords.x, Config.Locations["shop"].coords.y, Config.Locations["shop"].coords.z, "~g~E~w~ - Canteen")
					if IsControlJustReleased(0, 38) then
                        local ShopItems = {}
                        ShopItems.label = "Prison Canteen"
                        ShopItems.items = Config.CanteenItems
                        ShopItems.slots = #Config.CanteenItems
                        TriggerServerEvent("inventory:server:OpenInventory", "shop", "Canteenshop_"..math.random(1, 99), ShopItems)
					end
					DrawMarker(2, Config.Locations["shop"].coords.x, Config.Locations["shop"].coords.y, Config.Locations["shop"].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.2, 255, 55, 22, 222, false, false, false, 1, false, false, false)
				elseif #(pos - vector3(Config.Locations["shop"].coords.x, Config.Locations["shop"].coords.y, Config.Locations["shop"].coords.z)) < 2.5 then
					DrawText3D(Config.Locations["shop"].coords.x, Config.Locations["shop"].coords.y, Config.Locations["shop"].coords.z, "Canteen")
					DrawMarker(2, Config.Locations["shop"].coords.x, Config.Locations["shop"].coords.y, Config.Locations["shop"].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.2, 255, 55, 22, 222, false, false, false, 1, false, false, false)
				elseif #(pos - vector3(Config.Locations["shop"].coords.x, Config.Locations["shop"].coords.y, Config.Locations["shop"].coords.z)) < 10 then
					DrawMarker(2, Config.Locations["shop"].coords.x, Config.Locations["shop"].coords.y, Config.Locations["shop"].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.2, 255, 55, 22, 222, false, false, false, 1, false, false, false)
				end
			end
		else
			Wait(5000)
		end
	end
end)

RegisterCommand("unjailme", function ()
	jailTime = 0
	TriggerServerEvent("prison:server:SetJailStatus", 0)
	TriggerServerEvent("prison:server:GiveJailItems")
	TriggerServerEvent("prison:server:Leave",true)
	TriggerEvent("chatMessage", "SYSTEM", "warning", "you've received your property back..")
	inJail = false
	RemoveBlip(currentBlip)
	RemoveBlip(CellsBlip)
	CellsBlip = nil
	RemoveBlip(TimeBlip)
	TimeBlip = nil
	RemoveBlip(ShopBlip)
	ShopBlip = nil
	QBCore.Functions.Notify(Lang:t("success.free_"))
	DoScreenFadeOut(500)
	while not IsScreenFadedOut() do
		Wait(10)
	end
	SetEntityCoords(PlayerPedId(), Config.Locations["outside"].coords.x, Config.Locations["outside"].coords.y, Config.Locations["outside"].coords.z, 0, 0, 0, false)
	SetEntityHeading(PlayerPedId(), Config.Locations["outside"].coords.w)
	prisonClothes()
	TriggerServerEvent("qb-clothes:loadPlayerSkin")
	Wait(500)

	DoScreenFadeIn(1000)
end)