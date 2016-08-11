
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')


function ENT:Initialize()   

	math.randomseed(CurTime())
	self.exploded = false
	self.fuseleft = CurTime() + math.random(5,10)
	self.minsmoke = CurTime() + 0.5
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS ) 
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
	local phys = self.Entity:GetPhysicsObject()  	
	local pos = self.Entity:GetPos()
	local mass = phys:GetMass()
	self.Cola = self.Entity:GetColor()

	if phys:IsValid() then  		
	phys:Wake()
	phys:EnableGravity(true)
	phys:ApplyForceCenter(VectorRand():GetNormalized() * math.random(200,400))
	end 
 
end   
 
function ENT:Think()
	if (self.fuseleft < CurTime()) then
	self.Entity:Remove()
	end
	 
	self.Entity:NextThink( CurTime() + 0.3)
										//models/props_wasteland/metal_tram001a
	return true
end

function ENT:OnTakeDamage( dmginfo )
self.Entity:TakePhysicsDamage( dmginfo )
end

function ENT:PhysicsUpdate()
return true
end

function ENT:PhysicsCollide( data, physobj )
if (self.minsmoke < CurTime()) then
self.Entity:Remove()
end
end