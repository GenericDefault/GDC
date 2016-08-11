AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()

	self.Entity:SetModel("models/props_junk/popcan01a.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow( false )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )

	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
	phys:Wake()
	end

	self.timeleft = CurTime() + math.Rand(4, 5)

SmokeTrail = ents.Create("env_spritetrail")
SmokeTrail:SetKeyValue("lifetime","1")
SmokeTrail:SetKeyValue("startwidth","20")
SmokeTrail:SetKeyValue("endwidth","100")
SmokeTrail:SetKeyValue("spritename","trails/smoke.vmt")
SmokeTrail:SetKeyValue("rendermode","5")
SmokeTrail:SetKeyValue("rendercolor","200 200 200")
SmokeTrail:SetPos(self.Entity:GetPos())
SmokeTrail:SetParent(self.Entity)
SmokeTrail:Spawn()
SmokeTrail:Activate()

Glow = ents.Create("env_sprite")
Glow:SetPos(self.Entity:GetPos())
Glow:SetKeyValue("renderfx", "0")
Glow:SetKeyValue("rendermode", "5")
Glow:SetKeyValue("renderamt", "255")
Glow:SetKeyValue("rendercolor", "255 200 150")
Glow:SetKeyValue("framerate12", "20")
Glow:SetKeyValue("model", "light_glow03.spr")
Glow:SetKeyValue("scale", "5")
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