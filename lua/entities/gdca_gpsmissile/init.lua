
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

util.PrecacheSound( "weapons/rpg/rocket1.wav" )

function ENT:Initialize()   

self.Target = self.Entity:GetVar("Target")
self.Accelerator 	= 20
self.AccelRate		= 1
self.AccelMax		= 170
self.flightvector = self.Entity:GetUp() * 30
self.timeleft = CurTime() + 7
self.nexttarGet = CurTime()
self.Entity:SetModel( "models/props_c17/canister01a.mdl" ) 	
self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
self.Entity:SetMoveType( MOVETYPE_NONE )   --after all, gmod is a physics  	
self.Entity:SetSolid( SOLID_NONE )        -- CHEESECAKE!    >:3 
self.Sound = CreateSound( self.Entity, Sound( "Phx.HoverHeavy" ) ) 
self.Sound:Play()

SmokeTrail = ents.Create("env_spritetrail")
SmokeTrail:SetKeyValue("lifetime","1")
SmokeTrail:SetKeyValue("startwidth","40")
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
Glow:SetKeyValue("scale", "2.5")
Glow:SetKeyValue("GlowProxySize", "50")
Glow:SetParent(self.Entity)
Glow:Spawn()
Glow:Activate()

self:Think()
end   

function ENT:OnRemove()
	self.Sound:Stop()
end

 function ENT:Think()
	
if (self.Accelerator<self.AccelMax) then self.Accelerator = self.Accelerator+self.AccelRate	end	// Speed it up!

	if self.timeleft < CurTime() then
	self.Entity:Remove()				
	end

	local trace = {}
		trace.start 	= self.Entity:GetPos()
		trace.endpos 	= self.Entity:GetPos() + self.flightvector*1.1
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
					effectdata:SetScale( 70 )			// Big splash for big bullets
					util.Effect( "watersplash", effectdata )
					self.Entity:Remove()
					return true
					end

			util.BlastDamage(self.Entity, self.Entity, tr.HitPos, 600, 150)
			local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos)				// Position of Impact
			effectdata:SetNormal(tr.HitNormal)			// Direction of Impact
			effectdata:SetStart(self.flightvector:GetNormalized())	// Direction of Round
			effectdata:SetEntity(self.Entity)			// Who done it?
			effectdata:SetScale(2.8)					// Size of explosion
			effectdata:SetRadius(tr.MatType)			// Texture of Impact
			effectdata:SetMagnitude(16)				// Length of explosion trails
			util.Effect( "gdca_cinematicboom", effectdata )
			util.ScreenShake(tr.HitPos, 10, 5, 1, 2000 )
			util.Decal("Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
			if GDCENGINE then
			gdc.gdcheat( tr.HitPos+(tr.HitNormal*5), self.Entity:GetUp(), 400, 400, 100, 1000, self.Entity)	
			//position, direction, sphereradius, spheredamage, coneradius, conedamage, shell)	
			end	
			self.Entity:Remove()
			end


	if self.Target != Vector(0,0,0) then
	ForwardAngle = self.Entity:GetUp():Angle()
	TangY = (self.Target - self:GetPos()):GetNormalized():Angle().y
	AddY = math.Clamp(math.AngleDifference(TangY, self.Entity:GetUp():Angle().y)*5,-self.Accelerator/100,self.Accelerator/100)
	TangP = (self.Target - self:GetPos()):GetNormalized():Angle().p
	AddP = math.Clamp(math.AngleDifference(TangP, self.Entity:GetUp():Angle().p)*5,-self.Accelerator/100,self.Accelerator/100)
	self.Entity:SetAngles((Angle(AddP,AddY,0) + ForwardAngle) + Angle(90,0,0) + Angle(math.Rand(-0.8,0.8),math.Rand(-0.8,0.8),math.Rand(-0.8,0.8)))
	else
	self.Entity:SetAngles(self.flightvector:Angle() + Angle(90,0,0))
	end

	self.flightvector = self.Entity:GetUp()*self.Accelerator
	self.Entity:SetPos(self.Entity:GetPos() + self.flightvector)
	self.Entity:NextThink( CurTime() )
	return true
end
 
 
