--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:SpawnFunction( ply, tr, ClassName )
	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent.dOwnerEntLFS = ply
	ent:SetPos( tr.HitPos + tr.HitNormal * 80 )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:RunOnSpawn()
	local GunnerSeat = self:AddPassengerSeat( Vector(0,0,0), Angle(0,-90,0) )
	self:SetGunnerSeat( GunnerSeat )

	local ID = self:LookupAttachment( "gunner" )
	local Attachment = self:GetAttachment( ID )
	
	if Attachment then
		local Pos,Ang = LocalToWorld( Vector(0,-15,0), Angle(180,0,-90), Attachment.Pos, Attachment.Ang )
		
		GunnerSeat:SetParent( NULL )
		GunnerSeat:SetPos( Pos )
		GunnerSeat:SetAngles( Ang )
		GunnerSeat:SetParent( self, ID )
	end
end

function ENT:PrimaryAttack()
	if self:GetIsCarried() then return end
	if not self:CanPrimaryAttack() then return end

	local ID_L = self:LookupAttachment( "muzzle_left" )
	local ID_R = self:LookupAttachment( "muzzle_right" )
	local MuzzleL = self:GetAttachment( ID_L )
	local MuzzleR= self:GetAttachment( ID_R )
	
	if not MuzzleL or not MuzzleR then return end

	self:SetNextPrimary( 0.2 )
	self:EmitSound( "LAATc_IFTX_FIRE" )

	self.MirrorPrimary = not self.MirrorPrimary

	local Pos = self.MirrorPrimary and MuzzleL.Pos or MuzzleR.Pos
	local Dir =  (self.MirrorPrimary and MuzzleL.Ang or MuzzleR.Ang):Up()
	
	local bullet = {}
	bullet.Num 	= 1
	bullet.Src 	= Pos
	bullet.Dir 	= Dir
	bullet.Spread 	= Vector( 0.01,  0.01, 0 )
	bullet.Tracer	= 1
	bullet.TracerName	= "lfs_laser_blue"
	bullet.Force	= 100
	bullet.HullSize 	= 2
	bullet.Damage	= 50
	bullet.Attacker 	= self:GetDriver()
	bullet.AmmoType = "Pistol"
	bullet.Callback = function(att, tr, dmginfo)
		dmginfo:SetDamageType(DMG_AIRBOAT)
	end
	self:FireBullets( bullet )
	
	self:TakePrimaryAmmo()

	self:PlayAnimation( self.MirrorPrimary and "fire_left" or "fire_right" )
end


function ENT:SecondaryAttack()
	if self:GetIsCarried() then return end
	if self:GetAI() then return end
	
	if not self:CanSecondaryAttack() then return end

	self:SetNextSecondary( 6 )

	for i = 1, 6 do
		timer.Simple( (i / 5) * 0.75, function()
			if not IsValid( self ) then return end
			if not IsValid( self:GetDriver() ) then return end
			if self:GetAmmoSecondary() <= 0 then return end

			self:EmitSound( "LAATc_IFTX_FIRE_MISSILE" )

			self:TakeSecondaryAmmo()
		
			local ID_L = self:LookupAttachment( "muzzle_left" )
			local ID_R = self:LookupAttachment( "muzzle_right" )
			local MuzzleL = self:GetAttachment( ID_L )
			local MuzzleR= self:GetAttachment( ID_R )
			
			if not MuzzleL or not MuzzleR then return end

			self.MirrorPrimary = not self.MirrorPrimary

			local Pos = self.MirrorPrimary and MuzzleL.Pos or MuzzleR.Pos
			local Dir =  (self.MirrorPrimary and MuzzleL.Ang or MuzzleR.Ang):Up()

			local ent = ents.Create( "lfs_iftx_missile" )
			ent:SetPos( Pos )
			ent:SetAngles( Dir:Angle() )
			ent:Spawn()
			ent:Activate()
			ent:SetAttacker( self:GetDriver() )
			ent:SetInflictor( self )
		end)
	end
end

function ENT:FireTurret( Driver )
	if self:GetIsCarried() then return end
	if not self:CanAltPrimaryAttack() then return end

	local ID = self:LookupAttachment( "muzzle_turret" )
	local Muzzle = self:GetAttachment( ID )
	
	if not Muzzle then return end

	self:SetNextAltPrimary( 0.1 )
	self:EmitSound( "LAATc_IFTX_FIRE_TURRET" )

	local bullet = {}
	bullet.Num 	= 1
	bullet.Src 	= Muzzle.Pos
	bullet.Dir 	= Muzzle.Ang:Up()
	bullet.Spread 	= Vector( 0.035,  0.035, 0 )
	bullet.Tracer	= 1
	bullet.TracerName	= "lfs_laser_blue"
	bullet.Force	= 5
	bullet.HullSize 	= 1
	bullet.Damage	= 35
	bullet.Attacker 	= Driver
	bullet.AmmoType = "Pistol"
	bullet.Callback = function(att, tr, dmginfo)
		dmginfo:SetDamageType(DMG_AIRBOAT)
	end
	self:FireBullets( bullet )
end

function ENT:PhysicsCollide( data, physobj )
	if self:IsDestroyed() then
		self.MarkForDestruction = true
	end
	
	if IsValid( data.HitEntity ) then
		if data.HitEntity:IsPlayer() or data.HitEntity:IsNPC() or simfphys.LFS.CollisionFilter[ data.HitEntity:GetClass():lower() ] then
			return
		end
	end

	if self:WorldToLocal( data.HitPos ).z > 0 then -- no collision sound when the lower part of the model touches the ground
		if data.Speed > 60 and data.DeltaTime > 0.2 then
			if data.Speed > 500 then
				self:EmitSound( "Airboat_impact_hard" )
				
				self:TakeDamage( 400, data.HitEntity, data.HitEntity )
			else
				self:EmitSound( "MetalVehicle.ImpactSoft" )
			end
		end
	end
end

function ENT:SetNextAltPrimary( delay )
	self.NextAltPrimary = CurTime() + delay
end

function ENT:CanAltPrimaryAttack()
	self.NextAltPrimary = self.NextAltPrimary or 0
	return self.NextAltPrimary < CurTime()
end

function ENT:MainGunPoser( EyeAngles )
	local startpos =  self:GetRotorPos()
	local TracePlane = util.TraceHull( {
		start = startpos,
		endpos = (startpos + EyeAngles:Forward() * 50000),
		mins = Vector( -10, -10, -10 ),
		maxs = Vector( 10, 10, 10 ),
		filter = function( ent ) 
			if IsValid( ent ) then
				if ent == self or ent:GetClass() == "lfs_iftx_missile" then 
					return false
				end
			end
			return true
		end
	} )

	local AimAnglesR = self:WorldToLocalAngles( (TracePlane.HitPos - self:LocalToWorld( Vector(-60,-51,43) ) ):GetNormalized():Angle() )
	local AimAnglesL = self:WorldToLocalAngles( (TracePlane.HitPos - self:LocalToWorld( Vector(-60,51,43) ) ):GetNormalized():Angle() )
	
	self:SetPoseParameter("cannon_right_pitch", AimAnglesR.p )
	self:SetPoseParameter("cannon_right_yaw", AimAnglesR.y )

	self:SetPoseParameter("cannon_left_pitch", AimAnglesL.p )
	self:SetPoseParameter("cannon_left_yaw", AimAnglesL.y )

	self:SetWeaponOutOfRange( (AimAnglesR.p >= 10 and AimAnglesL.p >= 10) or (AimAnglesR.p <= -25 and AimAnglesL.p <= -25) or (math.abs(AimAnglesL.y) + math.abs(AimAnglesL.y)) >= 30 )
end

function ENT:OnIsCarried( name, old, new)
	if new == old then return end

	if new then
		self:SetPoseParameter("cannon_right_pitch", 0 )
		self:SetPoseParameter("cannon_right_yaw", 0 )

		self:SetPoseParameter("cannon_left_pitch", 0 )
		self:SetPoseParameter("cannon_left_yaw", 0 )

		self:SetPoseParameter( "move_x", 0 )
		self:SetPoseParameter( "move_y", 0 )
	
		self:SetPoseParameter("turret_pitch", 0 )
		self:SetPoseParameter("turret_yaw", 0 )

		self:SetWeaponOutOfRange( true )
		self:SetBTLFire( false )
	end
end

function ENT:OnGravityModeChanged( b )
end

function ENT:CreateAI()
end

function ENT:RemoveAI()
end

function ENT:OnKeyThrottle( bPressed )
end

function ENT:OnEngineStarted()
end

function ENT:OnEngineStarted()
end

function ENT:OnEngineStopped()
	self:SetGravityMode( true )
end

function ENT:OnVtolMode( IsOn )
end

function ENT:OnLandingGearToggled( bOn )
end

function ENT:OnTick()
	if self:GetAI() then self:SetAI( false ) end

	local HasTurret = self:GetBodygroup(1) == 2 and not IsValid( self:GetGunner() )

	local Rate = FrameTime() * 5
	self.smHatch = self.smHatch and self.smHatch + math.Clamp((HasTurret and 1 or 0) - self.smHatch,-Rate,Rate) or 0

	if not HasTurret and self.smHatch > 0.7 then self.smHatch = 0.7 end

	self:SetPoseParameter( "close_hatch", self.smHatch )

	if self:GetIsCarried() then 
		local Angles = self:GetAngles()

		self.smP = Angles.p
		self.smY = Angles.y
		self.smR = Angles.r
		
		return
	end

	local PhysObj = self:GetPhysicsObject()

	if not IsValid( PhysObj ) then return end

	local Pod = self:GetDriverSeat()
	if not IsValid( Pod ) then return end

	local Mass = PhysObj:GetMass()
	local Driver = Pod:GetDriver()

	local VelL = self:WorldToLocal( self:GetPos() + self:GetVelocity() )
	local FT =  FrameTime()

	local MoveX = 0
	local MoveY = 0
	local Boost = false
	local EyeAngles = Angle(0,0,0)

	if IsValid( Driver ) then 
		Boost = Driver:lfsGetInput( "+PITCH" )
		local Forward = Driver:lfsGetInput( "+THROTTLE" ) and 1 or 0
		local Backward = Driver:lfsGetInput( "-THROTTLE" ) and 1 or 0
		local Right = Driver:lfsGetInput( "+ROLL" ) and 1 or 0
		local Left = Driver:lfsGetInput( "-ROLL" ) and 1 or 0

		MoveX = Forward - Backward
		MoveY = Right - Left

		EyeAngles = Pod:WorldToLocalAngles( Driver:EyeAngles() )
		
		self:MainGunPoser( EyeAngles )
		
		if Driver:lfsGetInput( "FREELOOK" ) then
			if isangle( self.StoredEyeAngles ) then
				EyeAngles = self.StoredEyeAngles
				EyeAngles.r = 0
			end
		else
			self.StoredEyeAngles = EyeAngles
		end
	else
		EyeAngles = self:GetAngles()
	end

	local Angles = self:GetAngles()
	local TargetAngle = EyeAngles

	self.smP = self.smP and math.ApproachAngle( self.smP, TargetAngle.p, self.MaxTurnPitch * FT ) or Angles.p
	self.smY = self.smY and math.ApproachAngle( self.smY, TargetAngle.y, self.MaxTurnYaw * FT ) or Angles.y
	self.smR = self.smR and math.ApproachAngle( self.smR, TargetAngle.r, self.MaxTurnRoll * FT ) or Angles.r

	local LocalAngles = self:WorldToLocalAngles( Angle(self.smP,self.smY,self.smR) )
	
	LocalAngles.p = LocalAngles.p * 4
	LocalAngles.y = LocalAngles.y * 4
	LocalAngles.r = LocalAngles.r * 4

	local AngVel = self:GetAngVel()
	AngVel.p = AngVel.p * self.PitchDamping 
	AngVel.y = AngVel.y * self.YawDamping 
	AngVel.r = AngVel.r * self.RollDamping 
	
	local AngForce = (LocalAngles - AngVel)
	AngForce.p = AngForce.p * self.TurnForcePitch
	AngForce.y = AngForce.y * self.TurnForceYaw
	AngForce.r = AngForce.r * self.TurnForceRoll


	self:SetRPM( math.min(VelL:Length() / self.MaxVelocity,1) * 100 )

	self:SetPoseParameter( "move_x", math.Clamp(-VelL.x / self.MaxVelocity,-1,1) )
	self:SetPoseParameter( "move_y", math.Clamp(-VelL.y / self.MaxVelocity + self:GetAngVel().y / 100,-1,1) )

	self:ApplyAngForce( AngForce *  Mass * FT )

	self:GunnerWeapons( self:GetGunner(),self:GetGunnerSeat() )

	if not self:HitGround() then return end

	local Speed = self.MaxVelocity - (Boost and 0 or self.BoostVelAdd)
	PhysObj:ApplyForceCenter( ((self:GetForward() * MoveX + self:GetRight() * MoveY):GetNormalized() * Speed + (-self:GetForward() * VelL.x + self:GetRight() * VelL.y) * self.DampingMul) * self.ThrustMul  * Mass * FT ) 
end

 function ENT:GunnerWeapons(Driver, Pod)
	if IsValid( Driver ) and IsValid( Pod ) then
		Driver:CrosshairDisable()

		if self:GetBodygroup(1) == 2 then
			self:SetPoseParameter("turret_pitch", 0 )
			self:SetPoseParameter("turret_yaw", 0 )

			self:SetBTLFire( false )
		else
			local EyeAngles = Pod:WorldToLocalAngles( Driver:EyeAngles() )

			local _,LocalAng = WorldToLocal( Vector(0,0,0), EyeAngles, Vector(0,0,0), self:LocalToWorldAngles( Angle(0,0,0)  ) )

			self:SetPoseParameter("turret_pitch", LocalAng.p )
			self:SetPoseParameter("turret_yaw", LocalAng.y )
			
			if self:GetBodygroup(1) == 0 then
				self:SetBTLFire( Driver:KeyDown( IN_ATTACK ) )

				if self:GetBTLFire() then
					local ID = self:LookupAttachment( "muzzle_ballturret_left" )
					local Muzzle = self:GetAttachment( ID )
					
					if Muzzle then
						local Dir = Muzzle.Ang:Up()
						local startpos = Muzzle.Pos
						
						local Trace = util.TraceLine( {
							start = startpos,
							endpos = (startpos + Dir * 50000),
						} )
						
						self:BallturretDamage( Trace.Entity, Driver, Trace.HitPos, Dir )
					end
				end
			else
				if Driver:KeyDown( IN_ATTACK ) then
					self:FireTurret( Driver )
				end
			end
		end
	else
		self:SetBTLFire( false )
	end
 end
 
 function ENT:BallturretDamage( target, attacker, HitPos, HitDir )
	if not IsValid( target ) or not IsValid( attacker ) then return end

	if target ~= self then
		local dmginfo = DamageInfo()
		dmginfo:SetDamage( 500 * FrameTime() )
		dmginfo:SetAttacker( attacker )
		dmginfo:SetDamageType( bit.bor( DMG_SHOCK, DMG_ENERGYBEAM ) )
		dmginfo:SetInflictor( self ) 
		dmginfo:SetDamagePosition( HitPos ) 
		dmginfo:SetDamageForce( HitDir * 10000 ) 
		target:TakeDamageInfo( dmginfo )
	end
end

function ENT:IsEngineStartAllowed() -- always allow it to be turned on
	return true
end

function ENT:HandleStart() -- autostart 
	local Driver = self:GetDriver()
	
	local Active = (IsValid( Driver ) or self:GetAI()) and not self:GetIsCarried()

	if Active then
		if not self:GetEngineActive() then
			self:StartEngine()
		end
	else
		if self:GetEngineActive() then
			self:StopEngine()
		end
	end
end

function ENT:InitWheels() -- technically where the hover magic happens
	self.FilterEnts = { self }

	local Wheels = {
		Vector(-85,-60,-12),
		Vector(-5,-60,-11),
		Vector(80,-60,-8),

		Vector(-85,60,-12),
		Vector(-5,60,-11),
		Vector(80,60,-8),
	}

	local mass = 25
	local radius = 14

	for _, pos in pairs( Wheels ) do
		local wheel = ents.Create( "prop_physics" )
	
		if IsValid( wheel ) then
			wheel:SetPos( self:LocalToWorld( pos ) )
			wheel:SetAngles( self:LocalToWorldAngles( Angle(0,90,0) ) )
			
			wheel:SetModel( "models/props_vehicles/tire001c_car.mdl" )
			wheel:Spawn()
			wheel:Activate()
			
			wheel:SetNoDraw( true )
			wheel:DrawShadow( false )
			wheel.DoNotDuplicate = true
			
			wheel:PhysicsInitSphere( radius, "gmod_silent")
			wheel:SetCollisionBounds( Vector(-radius,-radius,-radius), Vector(radius,radius,radius) )
			
			local WpObj = wheel:GetPhysicsObject()
			if not IsValid( WpObj ) then
				self:Remove()
				
				print("LFS: Failed to initialize landing gear phys model. Plane terminated.")
				return
			end

			WpObj:EnableMotion(false)
			WpObj:SetMass( mass )
			WpObj:SetBuoyancyRatio( 10 )
			
			self:DeleteOnRemove( wheel )
			wheel:DeleteOnRemove( self )
			self:dOwner( wheel )
			
			self:dOwner( constraint.AdvBallsocket(wheel, self,0,0,Vector(0,0,0),Vector(0,0,0),0,0, -180, -180, -180, 180, 180, 180, 0, 0, 0, 0, 1) )
			self:dOwner( constraint.NoCollide( wheel, self, 0, 0 ) )
			
			WpObj:EnableMotion( true )
			WpObj:EnableDrag( false ) 

			if WpObj:GetMaterial() ~= "gmod_silent" then
				self:Remove()

				print("LFS: Failed to initialize landing gear. Plane terminated.")

				return
			end
			table.insert(self.FilterEnts, wheel)
		else
			self:Remove()
		
			print("LFS: Failed to initialize landing gear. Plane terminated.")
		end
	end
	
	local PObj = self:GetPhysicsObject()
	
	if IsValid( PObj ) then 
		PObj:EnableMotion( true )
	end
	
	self:PhysWake() 
end

function ENT:ApplyThrust( PhysObj, vDirection, fForce ) 
end

function ENT:InWater()
	return false
end

function ENT:OnLandingGearToggled( bOn )
	self:SetBodygroup(2, (self:GetBodygroup(2) == 1) and 0 or 1 )
	self:EmitSound( "items/flashlight1.wav" )
end

function ENT:HitGround()
	if not istable( self.FilterEnts ) then return false end

	if not isvector( self.obbvc ) or not isnumber( self.obbvm ) then
		self.obbvc = self:OBBCenter() 
		self.obbvm = self:OBBMins().z
	end
	
	local tr = util.TraceHull( {
		start = self:LocalToWorld( self.obbvc ),
		endpos = self:LocalToWorld( self.obbvc + Vector(0,0,self.obbvm - 100) ),
		mins = Vector( -50, -50, 0 ),
		maxs = Vector( 50, 50, 0 ),
		filter = self.FilterEnts
	} )
	
	local tr_w = util.TraceHull( {
		start = self:LocalToWorld( self.obbvc ),
		endpos = self:LocalToWorld( self.obbvc + Vector(0,0,self.obbvm - 100) ),
		mins = Vector( -50, -50, 0 ),
		maxs = Vector( 50, 50, 0 ),
		filter = self.FilterEnts,
		mask = MASK_WATER
	} )
	
	return (tr.Hit or tr_w)
end