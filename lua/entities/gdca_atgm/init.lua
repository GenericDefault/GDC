
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

util.PrecacheSound( "weapons/rpg/rocket1.wav" )

function ENT:Initialize()   

	local CheckHo = ents.FindByClass( "gdca_atgm" )		
	for _,t in pairs(CheckHo) do
	if t.Entity:IsValid() and (t.Entity!=self.Entity) and (t.Entity:GetClass()=="gdca_atgm") then
	if t:GetPos():Distance(self:GetPos())<800 then
	self.Entity:Remove()
	end
	end
	end

self.Target 		= self.Guider:GetVar("Target",Vector)		//print(tostring(self.Target))

if self.Guider.Wobbliness!=0.5 		then
self.W = self.Guider.Wobbliness 	else
self.W = 0.5 				end

if self.Guider.Zmod!=0.0 		then
self.Zmod = self.Guider.Zmod 		else
self.Zmod = 0.0 			end

if self.Guider.DistanceCutoff 				then
self.DistanceCutoff = self.Guider.DistanceCutoff 	else
self.DistanceCutoff = 5000 				end

self.Accelerator 	= 20
self.AccelRate		= 1
self.AccelMax		= 100
self.flightvector = self.Entity:GetUp() * self.Accelerator
self.timeleft = CurTime() + 10
self.ArmedTime = CurTime() + 1
self.Armed = false
self.Entity:SetModel( "models/props_c17/canister01a.mdl" ) 	
self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
self.Entity:SetMoveType( MOVETYPE_NONE )   --after all, gmod is a physics  	
self.Entity:SetSolid( SOLID_NONE )        -- CHEESECAKE!    >:3 
self.Sound = CreateSound( self.Entity, Sound( "Phx.Turbine" ) ) 
self.Sound:Play()

Glow = ents.Create("env_sprite")
Glow:SetKeyValue("model","orangecore2.vmt")
Glow:SetKeyValue("rendercolor","255 150 100")
Glow:SetKeyValue("scale","0.25")
Glow:SetPos(self.Entity:GetPos()-(self.Entity:GetUp()*30))
Glow:SetParent(self.Entity)
Glow:Spawn()
Glow:Activate()

Shine = ents.Create("env_sprite")
Shine:SetPos(self.Entity:GetPos()-(self.Entity:GetUp()*30))
Shine:SetKeyValue("renderfx", "0")
Shine:SetKeyValue("rendermode", "5")
Shine:SetKeyValue("renderamt", "255")
Shine:SetKeyValue("rendercolor", "255 150 100")
Shine:SetKeyValue("framerate12", "20")
Shine:SetKeyValue("model", "light_glow03.spr")
Shine:SetKeyValue("scale", "0.3")
Shine:SetKeyValue("GlowProxySize", "50")
Shine:SetParent(self.Entity)
Shine:Spawn()
Shine:Activate()

self:Think()
end   

function ENT:OnRemove()
	self.Sound:Stop()
end

 function ENT:Think()
	
if (self.Accelerator<self.AccelMax) then self.Accelerator = self.Accelerator+self.AccelRate	end	// Speed it up!

if !self.Guider:IsValid() then self.Guider = self.Entity end
	self.Target = self.Guider:GetVar("Target",Vector) 		// Refresh target position

	if self.Target!=Vector(0,0,0) then
	self.Distance = ((self.Target-Vector(0,0,self.Target.z))-self:GetPos()):Length()// Horizontal Distance
	

	if self.Distance>self.DistanceCutoff then					// If you are far away
	self.Zadd = Vector(0,0,	self.Distance*self.Zmod	)				// Add to the Z coordinate
	else self.Zadd = Vector(0,0,0) end						// Or else go straight for it

	self.Target = self.Target + self.Zadd						// Add Distance * Z Multiplier
	end

	if self.timeleft < CurTime() || !self.Guider:IsValid() then
	self.Entity:Remove()				
	end

		if self.ArmedTime < CurTime() and !self.Armed then
		self.Armed = true				
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
			if (self.Armed) then
			util.BlastDamage(self.Entity, self.Entity, tr.HitPos, 900, 150)
			local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos)				// Position of Impact
			effectdata:SetNormal(tr.HitNormal)			// Direction of Impact
			effectdata:SetStart(self.flightvector:GetNormalized())	// Direction of Round
			effectdata:SetEntity(self.Entity)			// Who done it?
			effectdata:SetScale(3.7)				// Size of explosion
			effectdata:SetRadius(tr.MatType)			// Texture of Impact
			effectdata:SetMagnitude(18)				// Length of explosion trails
			util.Effect( "gdca_cinematicboom", effectdata )
			util.ScreenShake(tr.HitPos, 10, 5, 1, 4000 )
			util.Decal("Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
			if GDCENGINE then
			gdc.gdcheat( tr.HitPos+(tr.HitNormal*5), self.Entity:GetUp(), 500, 600, 100, 3000, self.Entity)	
			//position, direction, sphereradius, spheredamage, coneradius, conedamage, shell)	
			end	
			self.Entity:Remove()
			else 
			util.BlastDamage(self.Entity, self.Entity, tr.HitPos, 90, 100)	// Without detonation
			local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos)				// Position of Impact
			effectdata:SetNormal(tr.HitNormal)			// Direction of Impact
			effectdata:SetStart(self.flightvector:GetNormalized())	// Direction of Round
			effectdata:SetEntity(self.Entity)			// Who done it?
			effectdata:SetScale(0.8)				// Size of explosion
			effectdata:SetRadius(tr.MatType)			// Texture of Impact
			effectdata:SetMagnitude(18)				// Length of explosion trails
			util.Effect( "gdca_cinematicboom", effectdata )
			self.Entity:Remove()
			end
			end


	if self.Target != Vector(0,0,0) then
	ForwardAngle = self.Entity:GetUp():Angle()
	TangY = math.NormalizeAngle((self.Target - self:GetPos()):GetNormalized():Angle().y)
	AddY = math.Clamp(math.AngleDifference(TangY, self.Entity:GetUp():Angle().y)*1,-self.Accelerator/200,self.Accelerator/200)
	TangP = math.NormalizeAngle((self.Target - self:GetPos()):GetNormalized():Angle().p)
	AddP = math.Clamp(math.AngleDifference(TangP, self.Entity:GetUp():Angle().p)*5,-0.5,1.0)
	self.Entity:SetAngles((Angle(AddP,AddY,0) + ForwardAngle) + Angle(90,0,0) + Angle(math.Rand(-self.W,self.W),math.Rand(-self.W,self.W),math.Rand(-self.W,self.W)))
	else
	self.Entity:SetAngles(self.flightvector:Angle() + Angle(90,0,0) + Angle(math.Rand(-self.W,self.W)/8,math.Rand(-self.W,self.W)/8,math.Rand(-self.W,self.W)/8) )
	end

	self.flightvector = self.Entity:GetUp()*self.Accelerator
	self.Entity:SetPos(self.Entity:GetPos() + self.flightvector)
	self.Entity:NextThink( CurTime() )
	return true
end
 
 
