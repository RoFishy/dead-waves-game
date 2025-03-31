local List = {}
List.__index = List

function List.new()
    local self = setmetatable({}, List)
    self.List = {}
    return self
end

function List:Append(Value : {})
    table.insert(self.List, Value)
end

function List:GetTotalItems()
    return #self.List
end

function List:GetIndexByValue(Value : {})
    for index, value in self.List do
        if Value == value then
            return index
        end
    end
    return nil
end

function List:GetValueByIndex(Index : number)
    return table.find(self.List, Index)
end

function List:Pop(Index : number)
    table.remove(self.List, Index)
end

function List:GetLastItem()
    return table.find(self.List, self:GetTotalItems())
end

return List