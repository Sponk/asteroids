-- Copyright (c) 2014 Yannick Pflanzer <scary-squid.de>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

-- Dieses Programm ist Freie Software: Sie können es unter den Bedingungen
-- der GNU General Public License, wie von der Free Software Foundation,
-- Version 3 der Lizenz oder (nach Ihrer Wahl) jeder neueren
-- veröffentlichten Version, weiterverbreiten und/oder modifizieren.

-- Dieses Programm wird in der Hoffnung, dass es nützlich sein wird, aber
-- OHNE JEDE GEWÄHRLEISTUNG, bereitgestellt; sogar ohne die implizite
-- Gewährleistung der MARKTFÄHIGKEIT oder EIGNUNG FÜR EINEN BESTIMMTEN ZWECK.
-- Siehe die GNU General Public License für weitere Details.

-- Sie sollten eine Kopie der GNU General Public License zusammen mit diesem
-- Programm erhalten haben. Wenn nicht, siehe <http://www.gnu.org/licenses/>.

dofile("libobject.lua")
dofile("levels.lua")

local player = getObject("Player")
local body = getObject("Body")
local camera = getObject("Camera0")
local gun_exit = getObject("GunExit")

local gui_scene = getScene("GuiScene")
local score_label = getObject(gui_scene, "ScoreLabel")
local life_label = getObject(gui_scene, "LifeLabel")
local game_over_label = getObject(gui_scene, "GameOverSign")

deactivate(game_over_label)

local spawn_points = getObjectsWithPrefix("SpawnPoint")

local mouse_controls = false

enableCameraLayer(camera, gui_scene)
setPhysicsQuality(2)

showCursor()

RAD_TO_DEG = 57.29578
DEG_TO_RAD = 0.01745329238

local playerData = {
    movement_speed = 2.5,
    bullet_power = 1,
    default_bullet = getObject("DefaultBullet"),
    bullet_speed = 4,
    bullet_spread = 0,
    bullet_emission_count = 1,
    bullet_delay = 100,
    max_bullet_distance = 500,
    max_bullets_number = 100,
    
    default_enemy = getObject("Enemy1"),
    max_enemies = 40,
    
    enemy01_life = 3,
    enemy01_speed = 2,
    enemy01_score = 10,
    enemy01_damage = 5,
    
    bullet_timer = 0,
    
    life = 100,
    score = 0,
    score_multiplier = 1,
    level = 0,
}

local bullets_on_field = {}
local enemies_on_field = {}
local items_on_field = {}

function getRandomVector3(max)
    if max == 0 then return vec3(0,0,0) end
    return vec3(math.random(max), math.random(max), math.random(max))
end

function pointPair2Degrees(startingPoint, endingPoint)
    local originPoint = startingPoint - endingPoint
    local bearingRadians = math.atan2(-originPoint[2], -originPoint[1]);
    local bearingDegrees = bearingRadians * RAD_TO_DEG;
    return bearingDegrees + 180
end

function createItem(itemtype, itemmodel, position)
    nitem = {
        item_type = itemtype,
        model = itemmodel
    }
    
    setPosition(itemmodel, position)
    return nitem
end

function weapon_crate_item()
    playerData.score = playerData.score + 20
    local newWeapon = weapon_crate_contents[math.random(1, #weapon_crate_contents)]
    
    playerData.bullet_power = newWeapon.power
    playerData.bullet_speed = newWeapon.speed
    playerData.bullet_emission_count = newWeapon.emission_count
    playerData.bullet_delay = newWeapon.delay
    playerData.bullet_spread = newWeapon.spread
end

function health_crate_item()
    playerData.life = playerData.life + 10
end

local item_callbacks = {
weapon_crate_item,
health_crate_item
}

local item_models = {
getObject("WeaponCrate"),
getObject("HealthCrate")
}

function onSceneUpdate()   
    -- Set texts
    setText(score_label, playerData.score)
    setText(life_label, playerData.life)
    
    if onKeyDown("ESCAPE") then
        quit()
    end
    
    if playerData.life <= 0 then
        activate(game_over_label)
        playerData.life = 0
        return
    end   
    
    if onKeyDown("MOUSE_BUTTON_LEFT") then
        mouse_controls = true
    elseif onKeyDown("JOY1_BUTTON_A") or onKeyDown("JOY1_BUTTON_DPADLEFT") or onKeyDown("JOY1_BUTTON_DPADRIGHT") or onKeyDown("JOY1_BUTTON_DPADUP") or onKeyDown("JOY1_BUTTON_DPADDOWN") then
        mouse_controls = false
    end
    
    -- Rotate to face mouse cursor
    if mouse_controls then
        local mx = getAxis("MOUSE_X")
        local my = getAxis("MOUSE_Y")
        local camPos = getPosition(camera)
        local playerPos = getPosition(player)           
            
        local point = getUnProjectedPoint(camera, vec3(mx, my, playerPos[3]))

        local newRot = pointPair2Degrees(getPosition(player), point)
        local rotation = getRotation(player)
        
        rotation[3] = newRot - 90
        setRotation(player, rotation)    
    else
        if isKeyPressed("JOY1_BUTTON_DPADLEFT") then
            rotate(player, {0,0,1}, 3)
        elseif isKeyPressed("JOY1_BUTTON_DPADRIGHT") then
            rotate(player, {0,0,-1}, 3)
        end
    
        if getAxis("JOY1_AXIS_LEFTX") < -0.3 or getAxis("JOY1_AXIS_LEFTX") > 0.3 then
            rotate(player, {0,0,1}, 3*-getAxis("JOY1_AXIS_LEFTX"))
        end
    end
    
    -- Translate according to input
    if isKeyPressed("W") or isKeyPressed("JOY1_BUTTON_DPADUP") then
        translate(player, {0,playerData.movement_speed,0}, "local")
    elseif isKeyPressed("S") or isKeyPressed("JOY1_BUTTON_DPADDOWN") then
        translate(player, {0,-playerData.movement_speed,0}, "local")
    end
    
    if getAxis("JOY1_AXIS_LEFTY") > 0.3 or getAxis("JOY1_AXIS_LEFTY") < -0.3 then
            translate(player, {0,getAxis("JOY1_AXIS_LEFTY")*-playerData.movement_speed,0}, "local")
    end 
    
    local playerPosition = getPosition(player)
    setPosition(camera, playerPosition+{0,0,400})
    
    -- Shooting
    if isKeyPressed("MOUSE_BUTTON_LEFT") or isKeyPressed("JOY1_BUTTON_A") then
        
        local time = getSystemTick()
        local emitted = false

        for i = 1, playerData.bullet_emission_count, 1 do
            local idx = #bullets_on_field+1    
            if idx < playerData.max_bullets_number and time > playerData.bullet_timer then
        
                local spread = getRandomVector3(playerData.bullet_spread) - vec3(playerData.bullet_spread,playerData.bullet_spread,0)*0.5
                spread[3] = 0
        
                bullets_on_field[idx] = {
                    bullet = getClone(playerData.default_bullet),
                    direction = getRotatedVector(player, {0,playerData.bullet_speed,0}+spread)
                }
            
                setPosition(bullets_on_field[idx].bullet, getTransformedPosition(gun_exit))
                setInvisible(bullets_on_field[idx].bullet, false)
                emitted = true
            end
        end
        
        if emitted then playerData.bullet_timer = time + playerData.bullet_delay end
    end   
    
    -- Update all items
    for k = #items_on_field, 1, -1 do
        local item = items_on_field[k]
        if isCollisionBetween(player, item.model) then
            item_callbacks[item.item_type]()
            deleteObject(item.model)
            table.remove(items_on_field, k)
        end
    end
    
    local enemy_spawn = spawn_points[math.random(#spawn_points-1)+1]
    local enemies_number = #enemies_on_field
        
    if enemies_number < playerData.max_enemies then
            
        enemies_on_field[enemies_number+1] = {
            enemy = deepClone(playerData.default_enemy),
            life = playerData.enemy01_life,
            damage = playerData.enemy01_damage,
            score = playerData.enemy01_score,
        }
            
        local children = getChilds(enemies_on_field[enemies_number+1].enemy)
        for i = 1, #children, 1 do
            if string.find(getName(children[i]), "Bombhit") ~= nil then
                    enemies_on_field[enemies_number+1].sound = children[i]
                    i = #children + 1
            end
        end
            
        local vec = getRandomVector3(1000)
        vec[3] = 0
        setPosition(enemies_on_field[enemies_number+1].enemy, getPosition(enemy_spawn) + vec)
    end
    
    -- Update all enemies
    for i = #enemies_on_field, 1, -1 do
        if enemies_on_field[i].life <= 0 then
        
            local children = getChilds(enemies_on_field[i].enemy)
            if children ~= nil then
                for i = 1, #children, 1 do
                    deleteObject(children[i])
                end
            end
            
            children = nil
            
            local index = math.random(1, #item_models)
            if math.random(10) == 5 then
                items_on_field[#items_on_field+1] = createItem(index, getClone(item_models[index]), getPosition(enemies_on_field[i].enemy))
            end
            
            deleteObject(enemies_on_field[i].enemy)
            table.remove(enemies_on_field, i)
        else
            direction = getPosition(player) - getPosition(enemies_on_field[i].enemy)
            newRot = math.atan2(direction[1], direction[2]) * RAD_TO_DEG * -1
            
            rotation = getRotation(enemies_on_field[i].enemy)	
            rotation[3] = newRot
            setRotation(enemies_on_field[i].enemy, rotation)
        
            addCentralForce(enemies_on_field[i].enemy, {0,playerData.enemy01_speed,0}, "local")
        end
    end
    
    if isCollisionTest(player) then
        for j = 1, #enemies_on_field, 1 do
            if isCollisionBetween(enemies_on_field[j].enemy, player) then
                playerData.life = playerData.life - enemies_on_field[j].damage
            end
        end
    end
    
    -- Update all bullets
    for i = #bullets_on_field, 1, -1 do
        local bullet_data = bullets_on_field[i]
        local position = getPosition(bullet_data.bullet)
        
        if length(position-playerPosition) > playerData.max_bullet_distance then
            deleteObject(bullet_data.bullet)
            table.remove(bullets_on_field, i)
            return
        else            
            if isCollisionTest(bullet_data.bullet) then               
                
                for j = 1, #enemies_on_field, 1 do
                    if isCollisionBetween(bullet_data.bullet, enemies_on_field[j].enemy) then
                        enemies_on_field[j].life = enemies_on_field[j].life - playerData.bullet_power
                        
                        playSound(enemies_on_field[j].sound)       
                        
                        playerData.score = playerData.score + enemies_on_field[j].score * playerData.score_multiplier
            
                        -- Update player level
                        if playerData.score % 1000 == 0 then
                            playerData.level = playerData.level + 1
                            if playerData.level < #enemy01_statistics then
                                playerData.enemy01_life = enemy01_statistics[playerData.level].life
                                playerData.enemy01_speed = enemy01_statistics[playerData.level].speed
                                playerData.enemy01_damage = enemy01_statistics[playerData.level].damage
                            end        
                        end            
            
                        j = #enemies_on_field + 1                       
                        
                        deleteObject(bullet_data.bullet)
                        table.remove(bullets_on_field, i)
                        return
                    end
                end
        
                --if (not isCollisionBetween(player, bullet_data.bullet)) 
                  --  or (not isCollisionBetween(player_bounding, bullet_data.bullet)) then
                        --print("Destroying")
                        --deleteObject(bullet_data.bullet)
                        --table.remove(bullets_on_field, i)
                        --return
                --end
            end
            
            setPosition(bullet_data.bullet, position + bullet_data.direction)
        end
    end
end