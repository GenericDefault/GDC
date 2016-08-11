AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

local mats={					// Multipliers for materials
	[MAT_FOLIAGE]			={5},
	[MAT_SLOSH]			={3},
	[MAT_ALIENFLESH]		={2},
	[MAT_ANTLION]			={2},
	[MAT_BLOODYFLESH]		={2},
	[MAT_FLESH]			={2},
	[45]				={2},	// Metrocop heads are a source glitch, they have no enumeration
	[MAT_DIRT]			={2},
	[MAT_WOOD]			={1.5},
	[MAT_SAND]			={1.3},
	[MAT_GLASS]			={1.2},
	[MAT_CLIP]			={1},
	[MAT_COMPUTER]			={1},
	[MAT_PLASTIC]			={1},
	[MAT_TILE]			={1},
	[MAT_CONCRETE]			={1},
	[MAT_GRATE]			={0.8},
	[MAT_VENT]			={0.8},
	[MAT_METAL]			={0.5},
}						// This determines how much the bullet will penetrate in stuff

function ENT:Initialize()   
math.randomseed(CurTime())

self.Penetrate 		= 20					// How deep Generic Default goes (in yo mama)
self.Flightvector 	= self.Entity:GetUp()*500		// Velocity in inches/sec
self.Timeleft 		= CurTime() + 5				// How long before auto-remove?
self.Impacted 		= false					// Important for flight continuation, see line 152
self.EffectSize		= 2.5					// How much stuff gets kicked up on impact
self.BlastDamage	= 70					// How much it dislodges your small intestine
self.BlastRadius	= 170					// How big impact radius is
self.Drift		= 0.5					// How much the bullet will drift in flight (Inaccuracy)

self.Entity:SetModel( "models/led.mdl" )
self.Entity:PhysicsInit( SOLID_VPHYSICS )
self.Entity:SetMoveType( MOVETYPE_NONE )
self.Entity:SetSolid( SOLID_NONE )

self:Think()
end   


function ENT:Think()

	if self.Impacted  then self.Impacted = false end	// Reset this part so it can tell at the end

		if self.Timeleft < CurTime() then		// In case of an error, all rounds will self-remove after a few seconds
		self.Entity:Remove()			
		end

	local trace 	= {}
	trace.start 	= self.Entity:GetPos()
	trace.endpos 	= self.Entity:GetPos() + self.Flightvector	// Trace to where it will be next tick
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
				effectdata:SetScale( 15*self.EffectSize )	// Big splash for big bullets
				util.Effect( "watersplash", effectdata )
				self.Entity:Remove()
				return true
				end

		util.BlastDamage(self.Entity, self.Entity, tr.HitPos, self.BlastRadius, self.BlastDamage)	// Radius, Damage
			local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos)				// Position of Impact
			effectdata:SetNormal(tr.HitNormal)			// Direction of Impact
			effectdata:SetStart(self.Flightvector:GetNormalized())	// Direction of Round
			effectdata:SetScale(self.EffectSize)			// Size of explosion
			effectdata:SetRadius(tr.MatType)			// Texture of Impact
			util.Effect("gdca_universal_impact",effectdata)
			util.ScreenShake(tr.HitPos, 10, 5, 0.1, self.BlastRadius*2 )
			util.Decal("ExplosiveGunshot", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)

	// THIS IS BULLET RICOCHET	
		local Dot = self.Entity:GetUp():DotProduct(tr.HitNormal)
		if (Dot*math.Rand(0.04,1)*mats[tr.MatType][1])>-0.04 then		// If it doesnt hit head on,
			self.Flightvector = (self.Flightvector:Length()*(1+Dot*1.2)) * (self.Entity:GetUp()+(tr.HitNormal*Dot*-0.8)+(VectorRand()*0.1))
			self.Entity:SetAngles(self.Flightvector:Angle() + Angle(90,0,0))
			self.Entity:SetPos(tr.HitPos+tr.HitNormal)
			self.Entity:NextThink( CurTime() )
			return true
			end	

			if tr.Entity:IsValid() and GDCENGINE then
			local attack =  gdc.caphit( tr.Entity, 300) 	// Entity, Damage
			end
			///

				// This part is for realistic bullet penetration
				// Generic Default penetrated your mom......

	self.Mat = math.ceil(tr.MatType)								// Multiplier for materials
	local trace = {}
	trace.start = tr.HitPos + self.Flightvector:GetNormalized()*(self.Penetrate*mats[self.Mat][1])	// Start in front of the bullet
	trace.endpos = tr.HitPos									// Trace back to the impact
	trace.filter = self.Entity 
	trace.mask 	= MASK_SHOT
	local pr = util.TraceLine( trace )

	if pr.StartSolid || tr.Hit and !pr.Hit || self.Penetrate<=0 then	// If you start inside something, it's too thick
	self.Entity:Remove()							// So remove the bullet
	return true
	else
	///

	self.Penetrate = self.Penetrate-(tr.HitPos:Distance(pr.HitPos)/mats[self.Mat][1])	// Subtract to get the penetration depth
	if self.Penetrate<=0 then								// If it runs out of inertia, remove it
	self.Entity:Remove()
	return true							
	end

	self.Entity:SetPos(pr.HitPos + self.Flightvector:GetNormalized())	// Start at the point of exit + 1
	self.Impacted = true							// This prevents it from moving twice later on

	local effectdata = EffectData()
	effectdata:SetOrigin(pr.HitPos)						// Position of Impact
	effectdata:SetNormal(self.Flightvector:GetNormalized())			// Direction of Impact
	effectdata:SetScale(self.EffectSize)					// Size of explosion
	effectdata:SetRadius(pr.MatType)					// Texture of Impact
	util.Effect( "gdca_universal_penetrate", effectdata )			// Make some debris
	util.ScreenShake(pr.HitPos, 10, 5, 0.1, self.BlastRadius*2 )				// Compression in the material
	util.Decal("ExplosiveGunshot", pr.HitPos + pr.HitNormal,pr.HitPos - pr.HitNormal)	// Bullet hole in the exit

	end									// This one ends the penetration code
	end									// This one ends the impact code

	if !self.Impacted then
	self.Entity:SetPos(self.Entity:GetPos() + self.Flightvector)
	end									// This one sets a normal flight path if there is no impact

self.Flightvector = self.Flightvector + (VectorRand():GetNormalized()*self.Drift) + Vector(0,0,-0.2)
self.Entity:SetAngles(self.Flightvector:Angle() + Angle(90,0,0))
self.Entity:NextThink( CurTime() )
return true
end								// Ends the think function and loops the bullet code
