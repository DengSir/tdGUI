--[[
BasicPanel.lua
@Date    : 2016/9/21 下午5:45:13
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]

local MAJOR, MINOR = 'BasicPanel', 1
local GUI = LibStub('tdGUI-1.0')
local BasicPanel, oldminor = GUI:NewClass(MAJOR, MINOR, 'Frame.BasicFrameTemplate')
if not BasicPanel then return end

function BasicPanel:Constructor()
    self:SetClampedToScreen(true)
    self:EnableMouse(true)

    local Drag = CreateFrame('Frame', nil, self) do
        Drag:Hide()
        Drag:SetPoint('TOPLEFT', 20, 0)
        Drag:SetPoint('TOPRIGHT', -20, 0)
        Drag:SetHeight(22)
        Drag:EnableMouse(true)
        Drag:RegisterForDrag('LeftButton')
        Drag:SetScript('OnDragStart', function()
            self:StartMoving()
        end)
        Drag:SetScript('OnDragStop', function()
            self:StopMovingOrSizing()
        end)
    end

    local Resize = CreateFrame('Button', nil, self) do
        Resize:Hide()
        Resize:SetSize(16, 16)
        Resize:SetPoint('BOTTOMRIGHT')
        Resize:SetFrameLevel(self:GetFrameLevel() + 10)
        Resize:SetNormalTexture([[Interface\CHATFRAME\UI-ChatIM-SizeGrabber-Up]])
        Resize:SetPushedTexture([[Interface\CHATFRAME\UI-ChatIM-SizeGrabber-Down]])
        Resize:SetHighlightTexture([[Interface\CHATFRAME\UI-ChatIM-SizeGrabber-Highlight]])
        Resize:SetScript('OnMouseDown', function()
            self:StartSizing('BOTTOMRIGHT')
        end)
        Resize:SetScript('OnMouseUp', function()
            self:StopMovingOrSizing()
        end)
    end

    self.Drag   = Drag
    self.Resize = Resize
end

function BasicPanel:SetMovable(flag)
    self:SuperCall('SetMovable', flag)
    self.Drag:SetShown(flag)
end

function BasicPanel:SetResizable(flag)
    self:SuperCall('SetResizable', flag)
    self.Resize:SetShown(flag)
end

function BasicPanel:SetText(text)
    self.TitleText:SetText(text)
end

function BasicPanel:GetText()
    return self.TitleText:GetText()
end
