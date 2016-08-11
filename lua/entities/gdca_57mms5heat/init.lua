AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()   
self.flightvector = self.Entity:GetUp() * 200
self.timeleft = CurTime() + 5
self.Entity:SetModel( "models/props_junk/garbage_glassbottle001a.mdl" )	
self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
self.Entity:SetMoveType( MOVETYPE_NONE )   --after all, gmod is a physics  	
self.Entity:SetSolid( SOLID_NONE )        -- CHEESECAKE!    >:3           

SmokeTrail = ents.Create("env_spritetrail")
SmokeTrail:SetKeyValue("lifetime","0.5")
SmokeTrail:SetKeyValue("startwidth","20")
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
Glow:SetKeyValue("scale", "1.5")
Glow:SetKeyValue("GlowProxySize", "50")
Glow:SetParent(self.Entity)
Glow:Spawn()
Glow:Activate()

end   

 function ENT:Think()

		if self.timeleft < CurTime() then
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

					util.BlastDamage(self.Entity, self.Entity, tr.HitPos, 500, 100)
					local effectdata = EffectData()
					effectdata:SetOrigin(tr.HitPos)				// Position of Impact
					effectdata:SetNormal(tr.HitNormal)			// Direction of Impact
					effectdata:SetStart(self.flightvector:GetNormalized())	// Direction of Round
					effectdata:SetEntity(self.Entity)			// Who done it?
					effectdata:SetScale(1.6)					// Size of explosion
					effectdata:SetRadius(tr.MatType)			// Texture of Impact
					effectdata:SetMagnitude(16)				// Length of explosion trails	
					util.Effect( "gdca_cinematicboom", effectdata )
					util.ScreenShake(tr.HitPos, 10, 5, 1, 2000 )
					util.Decal("Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)

			if GDCENGINE then	
			gdc.gdcheat( tr.HitPos+(tr.HitNormal*5), self.Entity:GetUp(), 200, 200, 100, 1000, self.Entity)	
			//position, direction, sphereradius, spheredamage, coneradius, conedamage, shell)
			end	

					self.Entity:Remove()	
					end
	
	self.Entity:SetPos(self.Entity:GetPos() + self.flightvector)
	self.flightvector =  self.flightvector - self.flightvector/80 + self.Entity:GetUp()*5 + Vector(math.Rand(-0.2,0.2), math.Rand(-0.2,0.2),math.Rand(-0.2,0.2)) + Vector(0,0,-0.111)
	self.Entity:SetAngles(self.flightvector:Angle() + Angle(90,0,0))
	self.Entity:NextThink( CurTime() )
	return true
end
 
 
