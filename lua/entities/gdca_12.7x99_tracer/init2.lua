AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()   

math.randomseed(CurTime())
self.flightvector = self.Entity:GetUp() * 450
self.tracer = false
self.timeleft = CurTime() + 5
self.Entity:SetModel( "models/led2.mdl" ) 	
self.Entity:PhysicsInit( SOLID_VPHYSICS )	
self.Entity:SetMoveType( MOVETYPE_NONE )
self.Entity:SetSolid( SOLID_VPHYSICS )

Tracer = ents.Create("env_spritetrail")
Tracer:SetKeyValue("lifetime","0.1")
Tracer:SetKeyValue("startwidth","35")
Tracer:SetKeyValue("endwidth","0")
Tracer:SetKeyValue("spritename","trails/laser.vmt")
Tracer:SetKeyValue("rendermode","5")
Tracer:SetKeyValue("rendercolor","255 150 100")
Tracer:SetPos(self.Entity:GetPos())
Tracer:SetParent(self.Entity)
Tracer:Spawn()
Tracer:Activate()

Glow = ents.Create("env_sprite")
Glow:SetKeyValue("model","orangecore2.vmt")
Glow:SetKeyValue("rendercolor","255 150 100")
Glow:SetKeyValue("scale","0.2")
Glow:SetPos(self.Entity:GetPos())
Glow:SetParent(self.Entity)
Glow:Spawn()
Glow:Activate()

self:Think()

end   

function ENT:Think()	

	if self.timeleft < CurTime() then
		self.Entity:Remove()
		end

	local trace = {}
		trace.start = self.Entity:GetPos()
		trace.endpos = self.Entity:GetPos() + self.flightvector
		trace.filter = self.Entity 
		local tr = util.TraceLine( trace )

		if tr.HitSky then
			self.Entity:Remove()
			return true
			end	
	
		if tr.Hit then
			util.BlastDamage(self.Entity, self.Entity, tr.HitPos, 90, 70)		// Radius, Damage
			local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos)
			effectdata:SetScale(1.35)
			effectdata:SetRadius(tr.MatType)
			effectdata:SetNormal(tr.HitNormal)
			util.Effect("gdca_universal_impact",effectdata)
			util.ScreenShake(tr.HitPos, 10, 5, 0.3, 300 )
			util.Decal("ExplosiveGunshot", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)

			if tr.Entity:IsValid() then
			local attack = gcombat.hcghit( tr.Entity, 120, 15, tr.HitPos, tr.HitPos)
			end

			self.Entity:Remove()
			return true
		end

self.flightvector = self.flightvector + Vector(math.Rand(-0.4,0.4), math.Rand(-0.4,0.4),math.Rand(-0.4,0.4)) + Vector(0,0,-0.1)
self.Entity:SetPos(self.Entity:GetPos() + self.flightvector)
self.Entity:SetAngles(self.flightvector:Angle() + Angle(90,0,0))
self.Entity:NextThink( CurTime() )
return true
end
 
 
