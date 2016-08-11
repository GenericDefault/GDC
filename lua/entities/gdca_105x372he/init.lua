
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()   

self.flightvector = self.Entity:GetUp() * 200
self.timeleft = CurTime() + 35
self.Entity:SetModel( "models/props_junk/garbage_plasticbottle003a.mdl" )
self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
self.Entity:SetMoveType( MOVETYPE_NONE )   --after all, gmod is a physics  	
self.Entity:SetSolid( SOLID_NONE )        -- CHEESECAKE!    >:3           
 
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


				if tr.Hit and !tr.HitSky then
					if tr.StartSolid then
					self.Entity:Remove()
					return true
					end

					if tr.MatType==83 then				//83 is wata
					local effectdata = EffectData()
					effectdata:SetOrigin( tr.HitPos )
					effectdata:SetNormal( tr.HitNormal )		// In case you hit sideways water?
					effectdata:SetScale( 120 )			// Big splash for big bullets
					util.Effect( "watersplash", effectdata )
					self.Entity:Remove()
					return true
					end

				util.BlastDamage(self.Entity, self.Entity, tr.HitPos, 1200, 200)		// Radius, Damage
					local effectdata = EffectData()
					effectdata:SetOrigin(tr.HitPos)				// Position of Impact
					effectdata:SetNormal(tr.HitNormal)			// Direction of Impact
					effectdata:SetStart(self.flightvector:GetNormalized())	// Direction of Round
					effectdata:SetEntity(self.Entity)			// Who done it?
					effectdata:SetScale(4.0)				// Size of explosion
					effectdata:SetRadius(tr.MatType)			// Texture of Impact
					effectdata:SetMagnitude(20)				// Length of explosion trails	
				util.Effect( "gdca_cinematicboom", effectdata )
				util.ScreenShake(tr.HitPos, 20, 5, 1, 2500 )
				util.Decal("Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)

			if GDCENGINE then	
			local attack = gdc.gdcsplode( tr.HitPos, 700, 400, self.Entity)	// Position, Radius, Damage, Self		
			end	
				self.Entity:Remove()
				end
	
	self.Entity:SetPos(self.Entity:GetPos() + self.flightvector)
	self.flightvector = self.flightvector + Vector(math.Rand(-0.02,0.02), math.Rand(-0.02,0.02),math.Rand(-0.02,0.02)) + Vector(0,0,-0.2)
	self.Entity:SetAngles(self.flightvector:Angle() + Angle(90,0,0))
	self.Entity:NextThink( CurTime() )
	return true
end
 
 
