--[[
AutoHideController.lua
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]

local MAJOR, MINOR = 'AutoHideController', 1
local GUI = LibStub('tdGUI-1.0')
local AutoHideController, oldminor, ns = GUI:NewClass(MAJOR, MINOR, 'Frame')
if not AutoHideController then return end

LibStub('AceTimer-3.0'):Embed(AutoHideController)

ns._Objects   = ns._Objects or {}
ns.ESCHandler = ns.ESCHandler or CreateFrame('Frame', nil, UIParent)
ns.ESCHandler:Hide()
ns.ESCHandler:SetScript('OnKeyDown', function(self, key)
    local found = false
    if key == GetBindingKey('TOGGLEGAMEMENU') then
        for object in pairs(ns._Objects) do
            if object:IsVisible() then
                object:OnTimer()
                found = true
            end
        end
        self:Hide()
    end
    self:SetPropagateKeyboardInput(not found)
end)


function AutoHideController:Constructor()
    self:SetScript('OnUpdate', self.OnUpdate)
    self:SetScript('OnHide', self.OnTimer)
    self:SetScript('OnShow', self.OnShow)
    ns._Objects[self] = true
end

function AutoHideController:GetOwner()
    return self:GetParent():GetOwner()
end

function AutoHideController:IsOwnerVisible()
    return self:GetOwner() and self:GetOwner():IsVisible()
end

function AutoHideController:IsOwnerOver()
    return self:GetOwner() and self:GetOwner():IsMouseOver()
end

function AutoHideController:IsMenuOver()
    return self:GetParent():IsMouseOver()
end

function AutoHideController:OnUpdate(elapsed)
    if not self:IsOwnerVisible() or self:Fire('OnUpdateCheck') then
        return self:OnTimer()
    end

    self.updater = (self.updater or 0) - elapsed
    if self.updater > 0 then
        return
    end
    self.updater = 0.5

    if self:IsOwnerOver() or self:IsMenuOver() then
        self:CancelAllTimers()
        self.timer = nil
    elseif not self.timer then
        self.timer = self:ScheduleTimer('OnTimer', self:GetAutoHideDelay())
    end
end

function AutoHideController:OnTimer()
    self:GetParent():Hide()
    self:CancelAllTimers()
    self.timer = nil
end

function AutoHideController:OnShow()
    ns.ESCHandler:Show()
end

function AutoHideController:SetAutoHideDelay(delay)
    self.autoHideDelay = delay
end

function AutoHideController:GetAutoHideDelay()
    return self.autoHideDelay or 1.5
end
