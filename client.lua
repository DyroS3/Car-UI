_menuPool = NativeUI.CreatePool()

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end

function has_hash_value (tab, val)
    for index, value in ipairs(tab) do
		if GetHashKey(value) == val then
			return true
        end
    end
    return false
end

cardoors = {}
for k, v in pairs (Config.doors) do 
    cardoors[k] = v
end

carwindows = {}
for k, v in pairs (Config.windows) do 
    carwindows[k] = v
end

---- Creating Menus
function LiveryMenu(vehicle, menu)
	local liveryMenu = _menuPool:AddSubMenu(menu, "载具涂装", "编辑车辆涂装", true, true, true)
	local livery_count = GetVehicleLiveryCount(vehicle)
	local livery_list = {}
	local fetched_liveries = false
	
	for liveryID = 1, livery_count do
		livery_list[liveryID] = liveryID
		fetched_liveries = true
    end
	
	local liveryItem = NativeUI.CreateListItem("载具涂装", livery_list, GetVehicleLivery(vehicle))
    liveryMenu:AddItem(liveryItem)
    
	liveryMenu.OnListChange = function(sender, item, index)
        if item == liveryItem then
			SetVehicleLivery(vehicle,item:IndexToItem(index))
        end
    end
end

function ExtrasMenu(vehicle, menu)
	local extrasMenu = _menuPool:AddSubMenu(menu, "车辆改装", "快速编辑车辆改装件", true, true)
    
	local veh_extras = {['vehicleExtras'] = {}}
    local items = {['vehicle'] = {}}
    local fetched_extras = false
    
	for extraID = 0, 20 do
        if DoesExtraExist(vehicle, extraID) then
            veh_extras.vehicleExtras[extraID] = (IsVehicleExtraTurnedOn(vehicle, extraID) == 1)
            fetched_extras = true
        end
    end

    if fetched_extras then
		for k, v in pairs(veh_extras.vehicleExtras) do
			local extraItem = NativeUI.CreateCheckboxItem('改装件-' .. k, veh_extras.vehicleExtras[k],"安装/解除-改装件"..k)
			extrasMenu:AddItem(extraItem)
			items.vehicle[k] = extraItem
		end
		
		extrasMenu.OnCheckboxChange = function(sender, item, checked)
			for k, v in pairs(items.vehicle) do
				if item == v then
					veh_extras.vehicleExtras[k] = checked
					if veh_extras.vehicleExtras[k] then
						SetVehicleExtra(vehicle, k, 0)
					else
						SetVehicleExtra(vehicle, k, 1)
					end
				end
			end
		end
    end
    
end

function AddLocksEngineMenu(vehicle, menu)
	local lockMenu = NativeUI.CreateItem("车门门锁", "上锁或解锁您的载具车门")
	local engineMenu = NativeUI.CreateItem("载具引擎", "开启/关闭您的载具引擎")
	menu:AddItem(lockMenu)
	menu:AddItem(engineMenu)

	menu.OnListChange = function(sender, item, index)
        print("Beep Beep.")
    end
	
	menu.OnItemSelect = function(sender, item, index)
		if item == lockMenu then
            print("Lock status:")
            print(GetVehicleDoorLockStatus(vehicle))
			if GetVehicleDoorLockStatus(vehicle) == 1 or GetVehicleDoorLockStatus(vehicle) == 0 then
				SetVehicleDoorsLocked(vehicle,4)
				lib.notify({
					title = '系统提醒',
					description = "车门已上锁",
					type = 'success'
				})	
			else
				SetVehicleDoorsLocked(vehicle,1)
				lib.notify({
					title = '系统提醒',
					description = "已解锁车门",
					type = 'success'
				})	
			end
        end
		if item == engineMenu then
            print("engine running?:")
			print(GetIsVehicleEngineRunning(vehicle))
			if GetIsVehicleEngineRunning(vehicle) then
				SetVehicleEngineOn(vehicle,false,false,true)
			else
				SetVehicleEngineOn(vehicle,true,false,true)
			end
        end
    end  
end

function AddDoorsMenu(vehicle, menu)
	local doorMenu = _menuPool:AddSubMenu(menu, "载具车门", "开启或关闭您的车辆车门", true, true)

	for k, v in pairs(cardoors) do
		newIndex = k - 1
		if DoesVehicleHaveDoor(vehicle, newIndex) then 
			local doorItem = NativeUI.CreateItem("开启/关闭 "..v,"开启/关闭 "..v)
			doorMenu:AddItem(doorItem)
		end
	end

	doorMenu.OnItemSelect = function(sender, item, index)
		newIndex = index - 1
		if DoesVehicleHaveDoor(vehicle, newIndex) then 
			local isopen = GetVehicleDoorAngleRatio(vehicle,newIndex)
			if isopen == 0 then
				SetVehicleDoorOpen(vehicle,newIndex,0,0)
				lib.notify({
					title = '系统提醒',
					description = "已开启"..Config.doors[index].." 车门",
					type = 'success'
				})	
			else
				SetVehicleDoorShut(vehicle,newIndex,0)
				lib.notify({
					title = '系统提醒',
					description = "已关闭"..Config.doors[index].." 车门",
					type = 'success'
				})	
			end
		end
    end
end

function AddWindowsMenu(vehicle, menu)
	local windowMenu = _menuPool:AddSubMenu(menu, "载具车窗", "开启或关闭您的车辆车窗", true, true)

	for k, v in pairs(carwindows) do
		local windowItem = NativeUI.CreateItem("开启/关闭 "..v.." 车窗","")
		windowMenu:AddItem(windowItem)
	end

	windowMenu.OnItemSelect = function(sender, item, index)
		newIndex = index - 1
		local isopen = IsVehicleWindowIntact(vehicle,newIndex)
		if isopen then
			RollDownWindow(vehicle,newIndex,0,0)
			lib.notify({
				title = '系统提醒',
				description = "已开启"..Config.windows[index].." 车窗",
				type = 'success'
			})	
		else
			RollUpWindow(vehicle,newIndex,0)
			lib.notify({
				title = '系统提醒',
				description = "已关闭 "..Config.windows[index].." 车窗",
				type = 'success'
			})	
		end
    end 
end

function openDynamicMenu(vehicle)
	_menuPool:Remove()
	if vehMenu ~= nil and vehMenu:Visible() then
		vehMenu:Visible(false)
		return
	end
	vehMenu = NativeUI.CreateMenu(Config.mTitle, '编辑我的车辆', 5, 100,Config.mBG[1],Config.mBG[2]) 
	_menuPool:Add(vehMenu)
	LiveryMenu(vehicle, vehMenu)
	ExtrasMenu(vehicle, vehMenu)
	AddDoorsMenu(vehicle, vehMenu)
	AddWindowsMenu(vehicle, vehMenu)
	AddLocksEngineMenu(vehicle, vehMenu)
	
	_menuPool:RefreshIndex()
	_menuPool:MouseControlsEnabled (false);
	_menuPool:MouseEdgeEnabled (false);
	_menuPool:ControlDisablingEnabled(false);
end

ESX                           = nil
local PlayerData              = {}

Citizen.CreateThread(function ()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
        PlayerData = ESX.GetPlayerData()
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

Citizen.CreateThread(function()

    while true do

        Citizen.Wait(0)

        _menuPool:ProcessMenus()

       

        local ped = GetPlayerPed(-1)

        local vehicle = GetVehiclePedIsIn(ped, false)

        local health = GetVehicleBodyHealth (ped)

       

        if IsControlJustReleased(1, Config.menuKey) then
			if PlayerData.job.name == 'police' then
            	if IsPedInAnyVehicle(ped, false) and GetPedInVehicleSeat(vehicle, -1) == ped and GetVehicleBodyHealth(vehicle) == 1000 then

               	 	collectgarbage()

               		 openDynamicMenu(vehicle)

                	vehMenu:Visible(not vehMenu:Visible())

            	end
			else
				lib.notify({
					title = '系统提醒',
					description = '很抱歉！您无权于车内使用此快捷选单',
					type = 'success'
				})	
			end
        end

        if IsControlJustReleased(1, Config.menuKey) then
			if PlayerData.job.name == 'police' then
            	if GetVehicleBodyHealth(vehicle) ~= 1000 then
					lib.notify({
						title = '系统提醒',
						description = '车辆严重损坏！请先维修',
						type = 'success',
					})	
           		 end
			end

        end

        if IsPedInAnyVehicle(ped, false) == false then

            if vehMenu ~= nil and vehMenu:Visible() then

                vehMenu:Visible(false)

            end

        end

    end
end)