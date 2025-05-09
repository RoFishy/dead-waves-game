-- // Terrain
local Terrain = workspace.Terrain

-- // TerrainUtil
local TerrainUtils = {}

--[[
    Returns a Region3 value from a basepart
]]--
function TerrainUtils.reg3FromPart(part)
	return Region3.new(part.Position - (0.5 * part.Size),  part.Position + (0.5 * part.Size));
end

--[[
    Returns a Region3int16 value from a basepart
]]--
function TerrainUtils.Reg3int16_FromPart(part : BasePart )
	local min =  part.Position - (0.5 * part.Size)
	local max = part.Position + (0.5 * part.Size)
    local reg16 = Region3int16.new(Vector3int16.new(min.X // 4, min.Y // 4, min.Z // 4), Vector3int16.new(max.X // 4, max.Y // 4, max.Z // 4))
	return reg16
end

function TerrainUtils.fillPart(Part : BasePart, Material : Enum.Material)
    Terrain:FillBlock(Part.CFrame, Part.Size, Material)
end

--[[
    Returns a copied terrain region and its corner
]]--
function TerrainUtils.copyReg(region:Region3int16 | BasePart)
    if typeof(region) == "Instance" then
        region = TerrainUtils.Reg3int16_FromPart(region)
    end
	local newTerrainReg = workspace.Terrain:CopyRegion(region)
	return newTerrainReg
end

--[[
    Allows you to paste a terrain region by adding the region and its corner
]]--
function TerrainUtils.pasteReg(terrainRegion: TerrainRegion, corner: Vector3int16 | BasePart)
    if typeof(corner) == "Instance" then
        corner = TerrainUtils.Reg3int16_FromPart(corner).Min
    end
	if typeof(terrainRegion) ~= "Instance" or not terrainRegion:IsA("TerrainRegion") then 
        warn("Incorrect terrain passed!") 
        return 
    end
	Terrain:PasteRegion(terrainRegion, corner, false)
end

--[[
    Deletes all the terrain in a region. Pass through a region or a part
]]--
function TerrainUtils.deleteReg(reg3:Region3|BasePart)
    local region = typeof(reg3) == "Instance" and TerrainUtils.reg3FromPart(reg3) or reg3
    -- Expand the region to align with the terrain grid
    region = region:ExpandToGrid(4)
    Terrain:FillRegion(region, 4, Enum.Material.Air)
end
return TerrainUtils