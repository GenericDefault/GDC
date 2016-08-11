AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()   

self.flightvector = self.Entity:GetUp() * 150
self.timeleft = CurTime() + 1.5
self.Entity:SetModel( "models/props_junk/garbage_glassbottle001a.mdl" )	
self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
self.Entity:SetMoveType( MOVETYPE_NONE )   --after all, gmod is a physics  	
self.Entity:SetSolid( SOLID_NONE )        -- CHEESECAKE!    >:3           
self.Sound = CreateSound( self.Entity, Sound( "Phx.Turbine" ) ) 
self.Sound:Play()

SmokeTrail = ents.Create("env_spritetrail")
SmokeTrail:SetKeyValue("lifetime","1")
SmokeTrail:SetKeyValue("startwidth","30")
SmokeTrail:SetKeyValue("endwidth","200")
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
Glow:SetKeyValue("rendercolor", "250 200 150")
Glow:SetKeyValue("framerate12", "20")
Glow:SetKeyValue("model", "light_glow03.spr")
Glow:SetKeyValue("scale", "5")
Glow:SetKeyValue("GlowProxySize", "50")
Glow:SetParent(self.Entity)
Glow:Spawn()
Glow:Activate()
end   
function ENT:OnRemove()
	self.Sound:Stop()
end
 function ENT:Think()
	
		if self.timeleft < CurTime() then
		local ent = ents.Create( "gdca_illuminator" )
		ent:SetPos( self.Entity:GetPos())
		ent:SetAngles( self.Entity:GetAngles() )
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		phys:ApplyForceCenter(self.flightvector*66)
		ent:Activate()
		self.Entity:Remove()				
		end

	local trace = {}
		trace.start 	= self.Entity:GetPos()
		trace.endpos 	= self.Entity:GetPos() + self.flightvector
		trace.filter 	= self.Entity 
		trace.mask 	= MASK_SHOT + MASK_WATER			// Trace for stuff that bullets would normally hit
	local tr = util.TraceLine( trace )


				if tr.Hit then
					if tr.HitSky || tr.StartSolid then
					self.Entity:Remove()
					return true
					end

					if tr.MatType==83 then				//83 is wata
					local effectdata = EffectData()
					effectdata:SetOrigin( tr.HitPos )
					effectdata:SetNormal( tr.HitNormal )		// In case you hit sideways water?
					effectdata:SetScale( 60 )			// Big splash for big bullets
					util.Effect( "watersplash", effectdata )
					self.Entity:Remove()
					return true
					end

			self.Entity:Remove()
			end
	
	self.Entity:SetPos(self.Entity:GetPos() + self.flightvector)
	self.flightvector =  self.flightvector - self.flightvector/80 + self.Entity:GetUp()*3 + Vector(math.Rand(-0.2,0.2), math.Rand(-0.2,0.2),math.Rand(-0.2,0.2)) + Vector(0,0,-0.111)
	self.Entity:SetAngles(self.flightvector:Angle() + Angle(90,0,0))
	self.Entity:NextThink( CurTime() )
	return true
end
 
