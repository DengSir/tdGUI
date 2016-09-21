--[[
EditBox.lua
@Date    : 2016/9/18 下午12:20:22
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]

local MAJOR, MINOR = 'EditBox', 1
local EditBox = LibStub('tdGUI-1.0'):NewClass(MAJOR, MINOR, 'Frame')
if not EditBox then return end

function EditBox:Constructor(parent, bg)
    ---- bg
    if bg then
        local TL = self:CreateTexture(nil, 'BACKGROUND') do
            TL:SetPoint('TOPLEFT')
            TL:SetSize(8, 8)
            TL:SetTexture([[Interface\COMMON\Common-Input-Border-TL]])
        end

        local TR = self:CreateTexture(nil, 'BACKGROUND') do
            TR:SetPoint('TOPRIGHT')
            TR:SetSize(8, 8)
            TR:SetTexture([[Interface\COMMON\Common-Input-Border-TR]])
        end

        local BL = self:CreateTexture(nil, 'BACKGROUND') do
            BL:SetPoint('BOTTOMLEFT')
            BL:SetSize(8, 8)
            BL:SetTexture([[Interface\COMMON\Common-Input-Border-BL]])
        end

        local BR = self:CreateTexture(nil, 'BACKGROUND') do
            BR:SetPoint('BOTTOMRIGHT')
            BR:SetSize(8, 8)
            BR:SetTexture([[Interface\COMMON\Common-Input-Border-BR]])
        end

        local T = self:CreateTexture(nil, 'BACKGROUND') do
            T:SetPoint('TOPLEFT', TL, 'TOPRIGHT')
            T:SetPoint('BOTTOMRIGHT', TR, 'BOTTOMLEFT')
            T:SetTexture([[Interface\COMMON\Common-Input-Border-T]])
        end

        local B = self:CreateTexture(nil, 'BACKGROUND') do
            B:SetPoint('TOPLEFT', BL, 'TOPRIGHT')
            B:SetPoint('BOTTOMRIGHT', BR, 'BOTTOMLEFT')
            B:SetTexture([[Interface\COMMON\Common-Input-Border-B]])
        end

        local L = self:CreateTexture(nil, 'BACKGROUND') do
            L:SetPoint('TOPLEFT', TL, 'BOTTOMLEFT')
            L:SetPoint('BOTTOMRIGHT', BL, 'TOPRIGHT')
            L:SetTexture([[Interface\COMMON\Common-Input-Border-L]])
        end

        local R = self:CreateTexture(nil, 'BACKGROUND') do
            R:SetPoint('TOPLEFT', TR, 'BOTTOMLEFT')
            R:SetPoint('BOTTOMRIGHT', BR, 'TOPRIGHT')
            R:SetTexture([[Interface\COMMON\Common-Input-Border-R]])
        end

        local M = self:CreateTexture(nil, 'BACKGROUND') do
            M:SetPoint('TOPLEFT', TL, 'BOTTOMRIGHT')
            M:SetPoint('BOTTOMRIGHT', BR, 'TOPLEFT')
            M:SetTexture([[Interface\COMMON\Common-Input-Border-M]])
        end
    end

    local ScrollFrame = CreateFrame('ScrollFrame', nil, self, 'UIPanelScrollFrameTemplate') do
        ScrollFrame:SetPoint('TOPLEFT', 5, -5)
        ScrollFrame:SetPoint('BOTTOMRIGHT', -26, 5)
    end

    local EditBox = CreateFrame('EditBox', nil, ScrollFrame) do
        EditBox:SetFontObject('GameFontHighlightSmall')
        EditBox:SetPoint('TOPLEFT')
        EditBox:SetSize(64, 64)
        EditBox:SetAutoFocus(false)
        EditBox:SetMultiLine(true)
        EditBox:SetScript('OnCursorChanged', ScrollingEdit_OnCursorChanged)
        EditBox:SetScript('OnTextChanged', function(EditBox, ...)
            ScrollingEdit_OnTextChanged(EditBox, EditBox:GetParent())
            self:Fire('OnTextChanged', ...)
        end)
        EditBox:SetScript('OnUpdate', ScrollingEdit_OnUpdate)
        EditBox:SetScript('OnEscapePressed', EditBox.ClearFocus)
        EditBox:SetScript('OnEditFocusGained', function()
            self.FocusGrabber:Hide()
            self:Fire('OnEditFocusGained')
        end)
        EditBox:SetScript('OnEditFocusLost', function()
            self.FocusGrabber:Show()
            self:Fire('OnEditFocusLost')
        end)
    end

    local FocusGrabber = CreateFrame('Button', nil, self) do
        FocusGrabber:SetAllPoints(ScrollFrame)
        FocusGrabber:SetFrameLevel(EditBox:GetFrameLevel() + 5)
        FocusGrabber:SetScript('OnClick', function()
            self.EditBox:SetCursorPosition(self.EditBox:GetText():len())
            self.EditBox:SetFocus()
        end)
    end

    ScrollFrame:SetScript('OnSizeChanged', function(ScrollFrame)
        self.EditBox:SetWidth(ScrollFrame:GetWidth() - 30)
    end)

    ScrollFrame:SetScrollChild(EditBox)

    self.ScrollFrame  = ScrollFrame
    self.EditBox      = EditBox
    self.FocusGrabber = FocusGrabber
end

local externs = {
    'AddHistoryLine',
    'ClearFocus',
    'ClearHistory',
    'Disable',
    'Enable',
    'GetAltArrowKeyMode',
    'GetBlinkSpeed',
    'GetCursorPosition',
    'GetHistoryLines',
    'GetHyperlinksEnabled',
    'GetIndentedWordWrap',
    'GetInputLanguage',
    'GetMaxBytes',
    'GetMaxLetters',
    'GetNumLetters',
    'GetNumber',
    'GetText',
    'GetTextInsets',
    'GetUTF8CursorPosition',
    'HasFocus',
    'HighlightText',
    'Insert',
    'IsAutoFocus',
    'IsCountInvisibleLetters',
    'IsEnabled',
    'IsInIMECompositionMode',
    'IsMultiLine',
    'IsNumeric',
    'IsPassword',
    'SetAltArrowKeyMode',
    'SetAutoFocus',
    'SetBlinkSpeed',
    'SetCountInvisibleLetters',
    'SetCursorPosition',
    'SetEnabled',
    'SetFocus',
    'SetHistoryLines',
    'SetHyperlinksEnabled',
    'SetIndentedWordWrap',
    'SetMaxBytes',
    'SetMaxLetters',
    'SetMultiLine',
    'SetNumber',
    'SetNumeric',
    'SetPassword',
    'SetText',
    'SetTextInsets',
    'ToggleInputLanguage',

    'GetFont',
    'GetFontObject',
    'GetJustifyH',
    'GetJustifyV',
    'GetShadowColor',
    'GetShadowOffset',
    'GetSpacing',
    'GetTextColor',
    'SetFont',
    'SetFontObject',
    'SetJustifyH',
    'SetJustifyV',
    'SetShadowColor',
    'SetShadowOffset',
    'SetSpacing',
    'SetTextColor',
}

for i, v in ipairs(externs) do
    EditBox[v] = function(self, ...)
        return self.EditBox[v](self.EditBox, ...)
    end
end
