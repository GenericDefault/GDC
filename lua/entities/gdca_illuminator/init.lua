AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()

	self.Entity:SetModel("models/combine_helicopter/helicopter_bomb01.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow( false )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.Entity:SetMaterial("lights/white")
	self.Entity:DrawShadow( false )
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
	phys:Wake()
	phys:SetMass( 1 )
	end

	self.timeleft = CurTime() + math.Rand(25, 30)


Glow = ents.Create("env_sprite")
Glow:SetPos(self.Entity:GetPos())
Glow:SetKeyValue("renderfx", "0")
Glow:SetKeyValue("rendermode", "5")
Glow:SetKeyValue("renderamt", "255")
Glow:SetKeyValue("rendercolor", "255 255 255")
Glow:SetKeyValue("framerate12", "20")
Glow:SetKeyValue("model", "light_glow03.spr")
Glow:SetKeyValue("scale", "30")
Glow:SetKeyValue("GlowProxySize", "50")
Glow:SetParent(self.Entity)
Glow:Spawn()
Glow:Activate()

self:Think()
end

 function ENT:Think()
	
	if self.timeleft < CurTime() then
	self.Entity:Remove()	
	end

	self.Entity:NextThink( CurTime() )
	return true
end

function ENT:PhysicsUpdate()
return true
end

function ENT:PhysicsCollide( data, physobj )
self.Entity:Remove()
end