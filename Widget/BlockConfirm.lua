--[[
BlockConfirm.lua
@Date    : 2016/9/21 上午11:10:56
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]

local ns           = select(2, ...)
local Addon        = ns.Addon
local BlockConfirm = Addon:NewClass('BlockConfirm', 'Frame')

LibStub('AceTimer-3.0'):Embed(BlockConfirm)

function BlockConfirm:Constructor(parent)
    self:Hide()
    self:EnableMouse(true)
    self:EnableMouseWheel(true)
    self:SetScript('OnMouseWheel', nop)
    self:SetScript('OnHide', self.OnHide)

    local Bg = self:CreateTexture(nil, 'BACKGROUND') do
        Bg:SetAllPoints(true)
        Bg:SetColorTexture(0, 0, 0, 0.8)
    end

    local Text = self:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight') do
        Text:SetPoint('BOTTOM', self, 'CENTER', 0, 20)
        Text:SetPoint('LEFT', 10, 0)
        Text:SetPoint('RIGHT', -10, 0)
    end

    local AcceptButton = CreateFrame('Button', nil, self, 'UIPanelButtonTemplate') do
        AcceptButton:SetPoint('TOPRIGHT', self, 'CENTER', -2, -5)
        AcceptButton:SetSize(80, 22)
        AcceptButton:SetScript('OnClick', function()
            self:OnAcceptClick()
        end)
    end

    local CancelButton = CreateFrame('Button', nil, self, 'UIPanelButtonTemplate') do
        CancelButton:SetPoint('TOPLEFT', self, 'CENTER', 2, -5)
        CancelButton:SetSize(80, 22)
        CancelButton:SetScript('OnClick', function()
            self:OnCancelClick()
        end)
    end

    self.Text         = Text
    self.AcceptButton = AcceptButton
    self.CancelButton = CancelButton
end

function BlockConfirm:Open(parent, opts)
    self.AcceptButton:SetText(opts.acceptText or ACCEPT)
    self.CancelButton:SetText(opts.cancelText or CANCEL)
    self.Text:SetText(opts.text)

    self.OnAccept  = opts.OnAccept or nop
    self.OnCancel  = opts.OnCancel or nop

    self.closeType = nil
    self.ctx       = opts.ctx

    if opts.delay and opts.delay > 0 then
        self.acceptText = opts.acceptText or ACCEPT
        self.delay      = opts.delay
        self:OnTimer()
        self:ScheduleRepeatingTimer('OnTimer', 1)
    else
        self.delay      = nil
        self.acceptText = nil
        self:CancelAllTimers()
        self.AcceptButton:Enable()
    end
    self:Show()
end

function BlockConfirm:OnAcceptClick()
    self.closeType = 'OnAccept'
    self:Hide()
end

function BlockConfirm:OnCancelClick()
    self:Hide()
end

function BlockConfirm:OnHide()
    self[self.closeType or 'OnCancel'](self.ctx)
    self:Hide()
    self:CancelAllTimers()
end

function BlockConfirm:OnTimer()
    if self.delay <= 0 then
        self:CancelAllTimers()
        self.AcceptButton:SetText(self.acceptText)
        self.AcceptButton:Enable()
    else
        self.AcceptButton:SetText(format('%s (%d)', self.acceptText, ceil(self.delay)))
        self.AcceptButton:Disable()
        self.delay = self.delay - 1
    end
end
