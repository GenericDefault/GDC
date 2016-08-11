AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()   

self.flightvector = self.Entity:GetUp() * 80
self.timeleft = CurTime() + 10
self.Entity:SetModel( "models/props_junk/garbage_glassbottle001a.mdl" )
self.Entity:SetGravity( 0.5 ) 	
self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
self.Entity:SetMoveType( MOVETYPE_NONE )   --after all, gmod is a physics  	
self.Entity:SetSolid( SOLID_VPHYSICS )        -- CHEESECAKE!    >:3           
 
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
					effectdata:SetScale( 30 )			// Big splash for big bullets
					util.Effect( "watersplash", effectdata )
					self.Entity:Remove()
					return true
					end

				for k, v in pairs ( ents.FindInSphere( self.Entity:GetPos(), 600 ) ) do		// Find anything within ~50 feet
				if v:IsPlayer() || v:IsNPC() then					// If its alive then
				local trace = {}						// Make sure there's not a wall in between
				trace.start = tr.HitPos+tr.HitNormal*30
				trace.endpos = v:GetPos() + Vector(0,0,30)			// Trace to the torso
				trace.filter = self.Entity
				local wp = util.TraceLine( trace )				// If the trace hits a living thing then
				if wp.Entity:IsPlayer() || wp.Entity:IsNPC() then v:Ignite( 5, 100 ) end end	// Fry it for 5 seconds
				end		

				util.BlastDamage(self.Entity, self.Entity, tr.HitPos, 600, 30)
				local effectdata = EffectData()
				effectdata:SetOrigin(tr.HitPos)
				effectdata:SetNormal(tr.HitNormal)
				effectdata:SetScale(3.0)
				effectdata:SetRadius(4.0)
				effectdata:SetMagnitude(20)
				util.Effect( "gdca_whitephosphorus", effectdata )
				util.ScreenShake(tr.HitPos, 10, 5, 1, 3000 )
				util.Decal("Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)

			if GDCENGINE then	
			local attack = gdc.gdcsplode( tr.HitPos, 200, 200, self.Entity)	// Position, Radius, Damage, Self		
			end	
				self.Entity:Remove()
				end
	
	self.Entity:SetPos(self.Entity:GetPos() + self.flightvector)
	self.flightvector = self.flightvector + Vector(math.Rand(-0.1,0.1), math.Rand(-0.1,0.1),math.Rand(-0.1,0.1)) + Vector(0,0,-0.3)
	self.Entity:SetAngles(self.flightvector:Angle() + Angle(90,0,0))
	self.Entity:NextThink( CurTime() )
	return true
end
 
 
