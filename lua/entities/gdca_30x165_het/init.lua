AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()   

math.randomseed(CurTime())
self.tracer = false
self.flightvector = self.Entity:GetUp() * 500
self.timeleft = CurTime() + 5
if self.Gun.Airburst>0.1 				then
self.AirburstTime = CurTime() + self.Gun.Airburst 	else
self.AirburstTime = CurTime() + 5 			end
self.Entity:SetModel( "models/led2.mdl" ) 	
self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
self.Entity:SetMoveType( MOVETYPE_NONE )   --after all, gmod is a physics  	
self.Entity:SetSolid( SOLID_NONE )        -- CHEESECAKE!    >:3       
     
Tracer = ents.Create("env_spritetrail")
Tracer:SetKeyValue("lifetime","0.1")
Tracer:SetKeyValue("startwidth","70")
Tracer:SetKeyValue("endwidth","20")
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
Glow:SetKeyValue("scale","0.3")
Glow:SetPos(self.Entity:GetPos())
Glow:SetParent(self.Entity)
Glow:Spawn()
Glow:Activate()

Shine = ents.Create("env_sprite")
Shine:SetPos(self.Entity:GetPos())
Shine:SetKeyValue("renderfx", "0")
Shine:SetKeyValue("rendermode", "5")
Shine:SetKeyValue("renderamt", "255")
Shine:SetKeyValue("rendercolor", "255 130 80")
Shine:SetKeyValue("framerate12", "20")
Shine:SetKeyValue("model", "light_glow03.spr")
Shine:SetKeyValue("scale", "0.7")
Shine:SetKeyValue("GlowProxySize", "50")
Shine:SetParent(self.Entity)
Shine:Spawn()
Shine:Activate()
self:Think()
 
end   

function ENT:Think()

		if self.timeleft < CurTime() then
		self.Entity:Remove()			
		end

			if self.AirburstTime < CurTime() then
			util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 600, 60)
					local effectdata = EffectData()
					effectdata:SetOrigin(self.Entity:GetPos())	// Position of Impact
					effectdata:SetNormal(Vector(0,0,1))		// Direction of Impact
					effectdata:SetStart(Vector(0,0,1))		// Direction of Round
					effectdata:SetScale(1.0)			// Size of explosion
					effectdata:SetRadius(1)				// Texture of Impact
					effectdata:SetMagnitude(15)			// Length of explosion trails
					util.Effect( "gdcw_nadeairburst", effectdata )
			if GDCENGINE then	
			local attack = gdc.gdcsplode( self.Entity:GetPos(), 500, 70, self.Entity)	// Position, Radius, Damage, Self		
			end	
			self.Entity:Remove()	end


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
					effectdata:SetScale( 45 )	// Big splash for big bullets
					util.Effect( "watersplash", effectdata )
					self.Entity:Remove()
					return true
					end

					util.BlastDamage(self.Entity, self.Entity, tr.HitPos, 300, 70)
					local effectdata = EffectData()
					effectdata:SetOrigin(tr.HitPos)				// Position of Impact
					effectdata:SetNormal(tr.HitNormal)			// Direction of Impact
					effectdata:SetStart(self.flightvector:GetNormalized())	// Direction of Round
					effectdata:SetEntity(self.Entity)			// Who done it?
					effectdata:SetScale(1.3)				// Size of explosion
					effectdata:SetRadius(tr.MatType)			// Texture of Impact
					effectdata:SetMagnitude(15)				// Length of explosion trails	
					util.Effect( "gdca_cinematicboom", effectdata )
					util.ScreenShake(tr.HitPos, 10, 5, 0.5, 1000 )
					util.Decal("Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)

			if GDCENGINE then	
			local attack = gdc.gdcsplode( tr.HitPos, 140, 120, self.Entity)	// Position, Radius, Damage, Self		
			end	
			///

				self.Entity:Remove()
				end

	self.Entity:SetPos(self.Entity:GetPos() + self.flightvector)
	self.flightvector = self.flightvector + Vector(math.Rand(-0.40,0.40), math.Rand(-0.4,0.4),math.Rand(-0.4,0.4)) + Vector(0,0,-0.2)
	self.Entity:SetAngles(self.flightvector:Angle() + Angle(90,0,0))
	self.Entity:NextThink( CurTime() )
	return true
	end
 
 
