AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()   

self.flightvector = self.Dropper.Velo
self.Timeleft = CurTime() + 20
self.ArmedTime = CurTime() + 1
self.Armed = false
self.Entity:SetModel( "models/props_phx/ww2bomb.mdl" ) 
self.Entity:PhysicsInit( SOLID_VPHYSICS )
self.Entity:SetMoveType( MOVETYPE_NONE )
self.Entity:SetSolid( SOLID_VPHYSICS )
self.Entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
self.Entity:SetMaterial("models/props_lab/door_klab01")
 
end   

 function ENT:Think()
	
		if (self.Timeleft < CurTime()) || (!self.Entity:IsInWorld()) then
		self.Entity:Remove()				
		end

		if !self.Armed then
		if self.ArmedTime < CurTime() and self.flightvector:Length()>20 then
		self.Armed = true				
		end	end

	local trace = {}
		trace.start 	= self.Entity:GetPos()
		trace.endpos 	= self.Entity:GetPos() + self.flightvector
		trace.filter 	= self.Entity 
		trace.mask 	= MASK_SHOT + MASK_WATER			// Trace for stuff that bullets would normally hit
	local tr = util.TraceLine( trace )


				if self.Armed and tr.Hit then
					if tr.HitSky || tr.StartSolid then
					self.Entity:Remove()
					return true
					end

					if tr.MatType==83 then				//83 is wata
					local effectdata = EffectData()
					effectdata:SetOrigin( tr.HitPos )
					effectdata:SetNormal( tr.HitNormal )		// In case you hit sideways water?
					effectdata:SetScale( 70 )			// Big splash for big bullets
					util.Effect( "watersplash", effectdata )
					self.Entity:Remove()
					return true
					end

				for k, v in pairs ( ents.FindInSphere( self.Entity:GetPos(), 1300 ) ) do		// Find anything within ~50 feet
				if v:IsPlayer() || v:IsNPC() then					// If its alive then
				local trace = {}						// Make sure there's not a wall in between
				trace.start = tr.HitPos+tr.HitNormal*30
				trace.endpos = v:GetPos() + Vector(0,0,30)			// Trace to the torso
				trace.filter = self.Entity
				local tpa = util.TraceLine( trace )				// If the trace hits a living thing then
				if tpa.Entity:IsPlayer() || tpa.Entity:IsNPC() then v:Ignite( 6, 100 ) end end	// Fry it for 5 seconds
				end	

					util.BlastDamage(self.Entity, self.Entity, tr.HitPos, 1500, 70)
					local effectdata = EffectData()
					effectdata:SetOrigin(tr.HitPos)				// Position of Impact
					effectdata:SetNormal(tr.HitNormal)			// Direction of Impact
					effectdata:SetStart(self.flightvector:GetNormalized())	// Direction of Round
					effectdata:SetEntity(self.Entity)			// Who done it?
					effectdata:SetScale(4)					// Size of explosion
					effectdata:SetRadius(tr.MatType)			// Texture of Impact
					effectdata:SetMagnitude(20)				// Length of explosion trails	
				util.Effect( "gdca_tpaboom", effectdata )
				util.ScreenShake(tr.HitPos, 20, 5, 1, 4500 )
				util.Decal("Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
				if GDCENGINE then	
				local attack = gdc.gdcsplode( tr.HitPos, 800, 600, self.Entity)	// Position, Radius, Damage, Self		
				end	
				self.Entity:Remove()
				end
	
	self.Entity:SetPos(self.Entity:GetPos() + self.flightvector)
	self.flightvector = self.flightvector + Vector(math.Rand(-0.03,0.03), math.Rand(-0.03,0.03),math.Rand(-0.03,0.03)) + Vector(0,0,-0.111)
	self.Entity:SetAngles(self.flightvector:Angle())
	self.Entity:NextThink( CurTime() )
	return true
end
 
 
