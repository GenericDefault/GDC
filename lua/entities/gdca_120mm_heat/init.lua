AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()  
 
	local CheckHo = ents.FindByClass( "gdca_120mm_heat" )		
	for _,t in pairs(CheckHo) do
	if t.Entity:IsValid() and (t.Entity!=self.Entity) and (t.Entity:GetClass()=="gdca_120mm_heat") then
	if t:GetPos():Distance(self:GetPos())<800 then
	self.Entity:Remove()	
	end
	end
	end

self.flightvector = self.Entity:GetUp() * 300
self.timeleft = CurTime() + 5
self.Entity:SetModel( "models/props_junk/garbage_glassbottle001a.mdl" ) 	
self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
self.Entity:SetMoveType( MOVETYPE_NONE )   --after all, gmod is a physics  	
self.Entity:SetSolid( SOLID_VPHYSICS )        -- CHEESECAKE!    >:3         

Glow = ents.Create("env_sprite")
Glow:SetKeyValue("model","orangecore2.vmt")
Glow:SetKeyValue("rendercolor","255 200 150")
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
Shine:SetKeyValue("rendercolor", "255 140 80")
Shine:SetKeyValue("framerate12", "20")
Shine:SetKeyValue("model", "light_glow03.spr")
Shine:SetKeyValue("scale", "0.3")
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
					effectdata:SetScale( 120 )			// Big splash for big bullets
					util.Effect( "watersplash", effectdata )
					self.Entity:Remove()
					return true
					end

				util.BlastDamage(self.Entity, self.Entity, tr.HitPos, 700, 300)
					local effectdata = EffectData()
					effectdata:SetOrigin(tr.HitPos)				// Position of Impact
					effectdata:SetNormal(tr.HitNormal)			// Direction of Impact
					effectdata:SetStart(self.flightvector:GetNormalized())	// Direction of Round
					effectdata:SetEntity(self.Entity)			// Who done it?
					effectdata:SetScale(3.2)				// Size of explosion
					effectdata:SetRadius(tr.MatType)			// Texture of Impact
					effectdata:SetMagnitude(18)				// Length of explosion trails	
					util.Effect( "gdca_cinematicboom", effectdata )
					util.ScreenShake(tr.HitPos, 20, 5, 1, 1200 )
					util.Decal("Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
			if GDCENGINE then	
			gdc.gdcheat( tr.HitPos+(tr.HitNormal*5), self.Entity:GetUp(), 500, 600, 100, 3000, self.Entity)	
			//position, direction, sphereradius, spheredamage, coneradius, conedamage, shell)	
			end
					self.Entity:Remove()
					end


	self.Entity:SetPos(self.Entity:GetPos() + self.flightvector)
	self.flightvector = self.flightvector + Vector(math.Rand(-0.1,0.1), math.Rand(-0.1,0.1),math.Rand(-0.1,0.1)) + Vector(0,0,-0.111)
	self.Entity:SetAngles(self.flightvector:Angle() + Angle(90,0,0))
	self.Entity:NextThink( CurTime() )
	return true
	end
 
 
