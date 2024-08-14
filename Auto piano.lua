shared.stop = true
wait(1)
shared.stop = false

shared.nospacedelay = shared.nospacedelay or false

local str = shared.scr or "qw[er]ty"
local FinishTime = shared.ftime or 10

local vim = game:GetService("VirtualInputManager")

local nstr = string.gsub(str,"[[\]\n]","")

local delay = shared.tempo and (6 / shared.tempo) or shared.delay or FinishTime / (string.len(nstr) / 1.05)

print("Finishing in",math.floor((delay*#nstr)/60),"minute/s",tostring(tonumber(tostring((delay*#nstr)/60):sub(3,8))*60):sub(1,2),"second/s")

local shifting = false

local function doshift(key)
    if key:upper() ~= key then return end
    if tonumber(key) then return end
    
    vim:SendKeyEvent(true, 304, false, nil)
    shifting = true
end

local function endshift()
    if not shifting then return end

    vim:SendKeyEvent(false, 304, false, nil)
    shifting = false
end

local queue = ""
local rem = true

for i=1, #str do
    if shared.stop == true then return end

    local c = str:sub(i,i)
    
    if c == "[" then
        rem = false
        continue
    elseif c == "]" then
        rem = true
        if string.find(queue," ") then
            for ii=1, #queue do
                local cc = queue:sub(ii,ii)
                pcall(function()
                    doshift(cc)
                    vim:SendKeyEvent(true, string.byte(cc:lower()), false, nil)
                    wait(delay/2)
                    vim:SendKeyEvent(false, string.byte(cc:lower()), false, nil)
                    endshift()
                end)
            
            end
        else
            for ii=1, #queue do
                local cc = queue:sub(ii,ii)
               
                pcall(function()
                    doshift(cc)
                    vim:SendKeyEvent(true, string.byte(cc:lower()), false, nil)
                    endshift()
                end)
               
                wait()
            end
            wait()
            for ii=1, #queue do
                local cc = queue:sub(ii,ii)
                pcall(function()
                    doshift(cc)
                    vim:SendKeyEvent(false, string.byte(cc:lower()), false, nil)
                    endshift()
                end)
  
                wait()
            end
        end
        queue = ""
        continue
    elseif c == " " or string.byte(c) == 10 then
        if shared.nospacedelay then continue end
        wait(delay)
        continue
    elseif c == "|" or c == "-" then
        wait(delay*2)
        continue
    end
    
    if not rem then
        queue=queue..c
        continue
    end

    pcall(function()
        doshift(c)
        vim:SendKeyEvent(true, string.byte(c:lower()), false, nil)
        wait()
        vim:SendKeyEvent(false, string.byte(c:lower()), false, nil)
        endshift()
    end)
   
    
    wait(delay)
end
