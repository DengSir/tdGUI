--[[
EditBox.lua
@Date    : 2016/9/18 下午12:20:22
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]

local MAJOR, MINOR = 'EditBox', 1
local EditBox = LibStub('tdGUI-1.0'):NewClass(MAJOR, MINOR, 'Frame')
if not EditBox then return end

function EditBox:Constructor(parent)
    self:SetBackdrop(GameTooltip:GetBackdrop())

    local ScrollFrame = CreateFrame('ScrollFrame', nil, self, 'UIPanelScrollFrameTemplate') do
        ScrollFrame:SetPoint('TOPLEFT', 10, -10)
        ScrollFrame:SetPoint('BOTTOMRIGHT', -28, 10)
    end

    local EditBox = CreateFrame('EditBox', nil, ScrollFrame) do
        EditBox:SetFontObject('GameFontHighlightSmall')
        EditBox:SetPoint('TOPLEFT')
        EditBox:SetSize(64, 64)
        EditBox:SetCountInvisibleLetters(true)
        EditBox:SetMaxLetters(140)
        EditBox:SetMultiLine(true)
        EditBox:SetScript('OnTextChanged', ScrollingEdit_OnTextChanged)
        EditBox:SetScript('OnCursorChanged', ScrollingEdit_OnCursorChanged)
        EditBox:SetScript('OnUpdate', ScrollingEdit_OnUpdate)
        EditBox:SetScript('OnEscapePressed', EditBox.ClearFocus)

    end

    ScrollFrame:SetScript('OnSizeChanged', function()
        EditBox:SetSize(ScrollFrame:GetSize())
    end)

    ScrollFrame:SetScrollChild(EditBox)

    positionhelper(self)
end

local f = EditBox:New(UIParent)
f:SetSize(300, 300)
f:SetPoint('CENTER')
