-- NotifyFrame.lua
-- @Author : DengSir (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 9/22/2018, 11:26:58 AM

local MAJOR, MINOR = 'NotifyFrame', 1
local GUI = LibStub('tdGUI-1.0')
local NotifyFrame, oldminor, ns = GUI:NewClass(MAJOR, MINOR, 'Button')
if not NotifyFrame then return end

NotifyFrame.opts = {}

local DEFAULT_ICON = [[Interface\Icons\INV_Misc_QuestionMark]]

function NotifyFrame:Constructor()
    self:Hide()
    self:SetSize(350, 50)
    self:SetBackdrop{
        bgFile = [[Interface\DialogFrame\UI-DialogBox-Background-Dark]],
        edgeFile = nil,
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = 1, right = 1, top = 1, bottom = 1}
    }
    self:SetBackdropColor(0, 0, 0, 1)
    self:SetFrameStrata('DIALOG')
    self:RegisterForClicks('LeftButtonUp', 'RightButtonUp')

    self:SetScript('OnClick', self.OnClick)
    self:SetScript('OnHide', self.OnHide)

    local Close = CreateFrame('Button', nil, self, 'UIPanelCloseButton') do
        Close:SetPoint('TOPRIGHT', 2, 2)
        Close:SetSize(25, 25)
        Close:SetScript('OnClick', function()
            self:OnClick('RightButton')
        end)
    end

    local Icon = self:CreateTexture(nil, 'ARTWORK') do
        Icon:SetPoint('LEFT', 4, 0)
        Icon:SetSize(42, 42)
        Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    end

    local Text = self:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightLeft') do
        Text:SetPoint('TOPRIGHT', -25, -5)
        Text:SetPoint('LEFT', Icon, 'RIGHT', 5, 0)
    end

    local HelpText = self:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLeft') do
        HelpText:SetWordWrap(false)
        HelpText:SetPoint('BOTTOM', 0, 4)
        HelpText:SetPoint('LEFT', Icon, 'RIGHT', 5, 0)
        HelpText:SetFont(HelpText:GetFont(), 9)
        HelpText:SetTextColor(0.8, 0.8, 0.3)
    end

    local Anim = self:CreateAnimationGroup() do
        Anim:SetToFinalAlpha(true)
        Anim:SetScript('OnFinished', function()
            if self:GetAlpha() == 0 then
                self:Hide()
            end
        end)
    end

    local Alpha = Anim:CreateAnimation('Alpha') do
        Alpha:SetDuration(0.5)
    end

    self.Anim     = Anim
    self.Alpha    = Alpha
    self.Text     = Text
    self.Icon     = Icon
    self.HelpText = HelpText
end

function NotifyFrame:SetText(text)
    self.Text:SetText(text)
    self:SetHeight(max(50, self.Text:GetStringHeight() + self.HelpText:GetStringHeight() + 10))
end

function NotifyFrame:FadeIn()
    self:Show()
    self.Anim:Stop()
    self.Alpha:SetFromAlpha(0)
    self.Alpha:SetToAlpha(1)
    self.Anim:Play()
end

function NotifyFrame:FadeOut()
    self.Anim:Stop()
    self.Alpha:SetFromAlpha(1)
    self.Alpha:SetToAlpha(0)
    self.Anim:Play()
end

function NotifyFrame:OnClick(click)
    if self.Anim:IsPlaying() then
        return
    end
    if click == 'LeftButton' then
        if self.opts.OnAccept then
            self.opts.OnAccept()
            self:FadeOut()
        end
    else
        if self.opts.OnCancel then
            self.opts.OnCancel()
        end
        self:FadeOut()
    end
end

function NotifyFrame:OnHide()
    self.opts = nil
    self:Fire('OnHide')
end

-- public

local MAX_NOTIFIES = 4

ns.used = ns.used or {}
ns.unused = ns.unused or {}
ns.queue = ns.queue or {}

local NotifyManager = {}

function NotifyManager:Pop()
    while self:Update() do
    end
    self:UpdatePosition()
end

function NotifyManager:UpdatePosition()
    for i, frame in ipairs(ns.used) do
        if i == 1 then
            frame:SetPoint('BOTTOMRIGHT', -25, 77)
        else
            frame:SetPoint('BOTTOMRIGHT', ns.used[i-1], 'TOPRIGHT', 0, 2)
        end
    end
end

function NotifyManager:Update()
    if #ns.used >= MAX_NOTIFIES then
        return
    end

    local opts = table.remove(ns.queue, 1)
    if not opts then
        return
    end

    if opts.type then
        local t = opts.storage[opts.id]
        if t then
            if opts.type == 'ONCE' then
                return true
            end
            if opts.type == 'DAY' and t == date('%Y/%m/%d') then
                return true
            end
        end
    end

    local notify = table.remove(ns.unused, 1) or NotifyFrame:New(UIParent)
    notify:SetPoint('BOTTOMRIGHT', -25, 77)
    table.insert(ns.used, notify)
    notify:SetCallback('OnHide', function(notify)
        tDeleteItem(ns.used, notify)
        table.insert(ns.unused, notify)
        self:Pop()
    end)

    notify:SetText(opts.text)
    notify.Icon:SetTexture(opts.icon or DEFAULT_ICON)
    notify.HelpText:SetText(opts.help or 'Right click to close')
    notify.opts = opts
    notify:FadeIn()

    if opts.type then
        opts.storage[opts.id] = date('%Y/%m/%d')
    end
end

function GUI:Notify(opts)
    assert(type(opts) == 'table')
    assert(opts.text)
    assert(not opts.type or opts.type == 'ONCE' or opts.type == 'DAY')

    if opts.type then
        assert(type(opts.storage) == 'table')
        assert(opts.id)
    end

    table.insert(ns.queue, opts)
    NotifyManager:Pop()
end

function GUI:NotifyOnce(opts)
    opts.type = 'ONCE'
    return self:Notify(opts)
end

function GUI:NotifyDay(opts)
    opts.type = 'DAY'
    return self:Notify(opts)
end
