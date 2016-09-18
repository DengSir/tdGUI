--[[
ListView2.lua
@Date    : 2016/9/16 上午9:25:40
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]

local MAJOR, MINOR = 'ListView', 1
local ListView = LibStub('tdGUI-1.0'):NewClass(MAJOR, MINOR, 'ScrollFrame.BasicHybridScrollFrameTemplate', 'Refresh', 'View', 'Select')
if not ListView then return end

function ListView:Constructor(parent)
    self._buttons = {}
    self.update = self.Refresh
    -- self:SetScrollChild(CreateFrame('Frame', nil, self))
    self:SetScript('OnSizeChanged', self.OnSizeChanged)

    self.scrollBar:ClearAllPoints()
    self.scrollBar:SetPoint('TOPRIGHT', 0, -18)
    self.scrollBar:SetPoint('BOTTOMRIGHT', 0, 18)

    self:SetSelectMode('NONE')
    self:ClearAllPoints()
end

function ListView:OnSizeChanged()
    self._maxCount = nil
    self._needUpdateScroll = true
    self.scrollChild:SetWidth(self:GetWidth() - 18)

    print(self:GetWidth(), self.scrollChild:GetWidth())

    self:Refresh()
end

function ListView:Update()
    if self._needUpdateLayout then
        self:UpdateLayout()
        self._needUpdateLayout = nil
    end
    if self._needUpdateScroll then
        self:UpdateScroll()
        self._needUpdateScroll = nil
    end
    self:UpdateItems()
end

function ListView:UpdateLayout()
    for i in ipairs(self._buttons) do
        self:UpdateItemPosition(i)
    end
end

function ListView:UpdateScroll()
    local maxCount = self:GetMaxCount()
    local buttonHeight = self:GetButtonHeight()
    local maxHeight = maxCount * buttonHeight

    self.buttonHeight = buttonHeight

    self:GetScrollChild():SetSize(self:GetWidth(), maxHeight)
	self:SetVerticalScroll(0)
	self:UpdateScrollChildRect()

    self.scrollBar:SetMinMaxValues(0, maxHeight)
    self.scrollBar.buttonHeight = buttonHeight
    self.scrollBar:SetValueStep(buttonHeight)
    self.scrollBar:SetStepsPerPage(maxCount - 2)
    self.scrollBar:SetValue(0)
end

function ListView:UpdateItems()
    local offset      = HybridScrollFrame_GetOffset(self)
    local itemCount   = self:GetItemCount()
    local maxCount    = self:GetMaxCount()
    local itemHeight  = self:GetItemHeight()
    local itemSpacing = self:GetItemSpacing()
    local realCount   = min(itemCount, maxCount)

    for i = 1, realCount do
        local index = offset + i
        local button = self:GetButton(i)

        button:SetID(index)
        button:SetHeight(itemHeight)
        button:Show()

        button:FireFormat()
    end

    for i = realCount + 1, #self._buttons do
        self:GetButton(i):Hide()
    end
    HybridScrollFrame_Update(self, self:GetItemCount() * self:GetButtonHeight(), self:GetHeight());
end

function ListView:UpdateItemPosition(i)
    local itemSpacing = self:GetItemSpacing()
    local button = self:GetButton(i)

    button:ClearAllPoints()

    if i == 1 then
        button:SetPoint('TOPLEFT')
        button:SetPoint('TOPRIGHT', -18, 0)
    else
        button:SetPoint('TOPLEFT', self:GetButton(i-1), 'BOTTOMLEFT', 0, -itemSpacing)
        button:SetPoint('TOPRIGHT', self:GetButton(i-1), 'BOTTOMRIGHT', 0, -itemSpacing)
    end
end

function ListView:GetMaxCount()
    if not self._maxCount then
        local itemHeight = self:GetItemHeight()
        local itemSpacing = self:GetItemSpacing()
        local height = self:GetHeight()

        self._maxCount = math.ceil(height / (itemHeight + itemSpacing)) + 1
    end
    return self._maxCount
end

function ListView:GetButtonHeight()
    return self:GetItemHeight() + self:GetItemSpacing()
end

---- override

function ListView:SetItemHeight(itemHeight)
    self._itemHeight = itemHeight
    self._needUpdateScroll = true
end

function ListView:SetItemSpacing(itemSpacing)
    self._itemSpacing = itemSpacing
    self._needUpdateScroll = true
end

-- ListView.GetOffset = HybridScrollFrame_GetOffset
-- ListView.SetOffset = HybridScrollFrame_SetOffset
-- ListView.ExpandButton = HybridScrollFrame_ExpandButton
-- ListView.CollapseButton = HybridScrollFrame_CollapseButton
