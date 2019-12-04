--DO NOT EDIT OR REUPLOAD THIS FILE
--DO NOT EDIT OR REUPLOAD THIS FILE
--DO NOT EDIT OR REUPLOAD THIS FILE
--DO NOT EDIT OR REUPLOAD THIS FILE
--DO NOT EDIT OR REUPLOAD THIS FILE
--DO NOT EDIT OR REUPLOAD THIS FILE
--DO NOT EDIT OR REUPLOAD THIS FILE
--DO NOT EDIT OR REUPLOAD THIS FILE
--DO NOT EDIT OR REUPLOAD THIS FILE
--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:SpawnFunction( ply, tr, ClassName )
	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent.dOwnerEntLFS = ply
	ent:SetPos( tr.HitPos + tr.HitNormal )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize() -- overwriting initialize function is bad and a big nono, but in this special case we are just using the vehicle framework and not the actual planescript so it should be ok
	self:SetModel( self.MDL )
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	
	local PObj = self:GetPhysicsObject()
	
	if not IsValid( PObj ) then 
		self:Remove()
		
		print("LFS: missing model. Plane terminated.")
		
		return
	end
	
	PObj:EnableMotion( false )
	PObj:SetMass( self.Mass ) 
	PObj:SetDragCoefficient( self.Drag )
	self.LFSInertiaDefault = PObj:GetInertia()
	self.Inertia = self.LFSInertiaDefault
	PObj:SetInertia( self.Inertia )
	
	self:InitPod()

	local ent = ents.Create( "gmod_atte_rear" )
	ent:SetPos( self:GetPos() )
	ent:SetAngles( self:GetAngles() )
	ent:Spawn()
	ent:Activate()
	ent:DeleteOnRemove( self )
	self:DeleteOnRemove( ent )
	
	self:dOwner( ent )
	
	ent.ATTEBaseEnt = self
	ent.DoNotDuplicate = true
	
	local PObj = ent:GetPhysicsObject()
	
	if not IsValid( PObj ) then 
		self:Remove()
		
		print("LFS: missing model. Plane terminated.")
		
		return
	end
	
	self:SetRearEnt( ent )
	
	PObj:SetMass( self.Mass ) 
	
	local ballsocket = constraint.AdvBallsocket(ent, self,0,0,Vector(35,0,128),Vector(35,0,128),0,0, -20, -20, -20, 20, 20, 20, 0, 0, 0, 0, 1)
	self:dOwner( ballsocket )
	ballsocket.DoNotDuplicate = true

	ballsocket:DeleteOnRemove( self )
	ballsocket:DeleteOnRemove( ent )
	
	self:RunOnSpawn()
	self:InitWheels() -- im too lazy to call unfreeze and wake so i will just let initwheels do the job
end

function ENT:RunOnSpawn()
	local TurretSeat = self:AddPassengerSeat( Vector(150,0,150), Angle(0,-90,0) )
	
	local ID = self:LookupAttachment( "driver_turret" )
	local TSAttachment = self:GetAttachment( ID )
	
	if TSAttachment then
		local Pos,Ang = LocalToWorld( Vector(0,-5,8), Angle(180,0,-55), TSAttachment.Pos, TSAttachment.Ang )
		
		TurretSeat:SetParent( NULL )
		TurretSeat:SetPos( Pos )
		TurretSeat:SetAngles( Ang )
		TurretSeat:SetParent( self, ID )
		self:SetTurretSeat( TurretSeat )
	end

	local GunnerSeat = self:AddPassengerSeat( Vector(150,0,150), Angle(0,-90,0) )
	self:SetGunnerSeat( GunnerSeat )
end

function ENT:ApplyThrustVtol( PhysObj, vDirection, fForce ) -- kill vtol function
end

function ENT:ApplyThrust( PhysObj, vDirection, fForce ) -- kill thrust
end

function ENT:CalcFlightOverride( Pitch, Yaw, Roll, Stability ) -- kill planescript handling
	return 0,0,0,0,0,0
end

function ENT:CreateAI()
end

function ENT:RemoveAI()
end

function ENT:OnKeyThrottle( bPressed )
end

function ENT:OnVtolMode( IsOn )
end

function ENT:OnLandingGearToggled( bOn )
end

function ENT:SetNextAltPrimary( delay )
	self.NextAltPrimary = CurTime() + delay
end

function ENT:CanAltPrimaryAttack()
	self.NextAltPrimary = self.NextAltPrimary or 0
	return self.NextAltPrimary < CurTime() and self:GetAmmoPrimary() > 0
end

function ENT:FireRearGun()
	local RearEnt = self:GetRearEnt()
	
	if not self:CanAltPrimaryAttack() or not IsValid( RearEnt ) then return end

	self:SetNextAltPrimary( 0.3 )
	
	local ID1 = RearEnt:LookupAttachment( "muzzle_right" )
	local ID2 = RearEnt:LookupAttachment( "muzzle_left" )

	local Muzzle1 = RearEnt:GetAttachment( ID1 )
	local Muzzle2 = RearEnt:GetAttachment( ID2 )
	
	if not Muzzle1 or not Muzzle2 then return end
	
	local FirePos = { [1] = Muzzle1, [2] = Muzzle2 }
	
	self.FireIndexRear = self.FireIndexRear and self.FireIndexRear + 1 or 1
	
	if self.FireIndexRear > 2 then
		self.FireIndexRear = 1
	end
	
	RearEnt:EmitSound( "LAATc_ATTE_FIRE" )

	local Pos = FirePos[self.FireIndexRear].Pos
	local Dir =  FirePos[self.FireIndexRear].Ang:Up()
	
	local bullet = {}
	bullet.Num 	= 1
	bullet.Src 	= Pos
	bullet.Dir 	= Dir
	bullet.Spread 	= Vector( 0.01,  0.01, 0 )
	bullet.Tracer	= 1
	bullet.TracerName	= "lfs_laser_green"
	bullet.Force	= 100
	bullet.HullSize 	= 22
	bullet.Damage	= 150
	bullet.Attacker 	= self:GetGunner()
	bullet.AmmoType = "Pistol"
	bullet.Callback = function(att, tr, dmginfo)
		if tr.Entity.IsSimfphyscar then
			dmginfo:SetDamageType(DMG_DIRECT)
		else
			dmginfo:SetDamageType(DMG_AIRBOAT)
		end
	end
	RearEnt:FireBullets( bullet )
	
	self:TakePrimaryAmmo()
end

function ENT:PrimaryAttack()
	if self:GetIsCarried() then return end
	if not self:CanPrimaryAttack() or not self.MainGunDir then return end

	local ID1 = self:LookupAttachment( "muzzle_right_up" )
	local ID2 = self:LookupAttachment( "muzzle_left_up" )
	local ID3 = self:LookupAttachment( "muzzle_right_dn" )
	local ID4 = self:LookupAttachment( "muzzle_left_dn" )

	local Muzzle1 = self:GetAttachment( ID3 )
	local Muzzle2 = self:GetAttachment( ID2 )
	local Muzzle3 = self:GetAttachment( ID1 )
	local Muzzle4 = self:GetAttachment( ID4 )
	
	if not Muzzle1 or not Muzzle2 or not Muzzle3 or not Muzzle4 then return end
	
	local FirePos = {
		[1] = Muzzle1,
		[2] = Muzzle2,
		[3] = Muzzle3,
		[4] = Muzzle4,
	}
	
	self.FireIndex = self.FireIndex and self.FireIndex + 1 or 2
	
	if self.FireIndex > 4 then
		self.FireIndex = 1
		self:SetNextPrimary( 0.5 )
	else
		if self.FireIndex == 3 then
			self:SetNextPrimary( 0.2 )
		else
			self:SetNextPrimary( 0.08 )
		end
	end
	
	self:EmitSound( "LAATc_ATTE_FIRE" )

	local Pos = FirePos[self.FireIndex].Pos
	local Dir =  FirePos[self.FireIndex].Ang:Up()
	
	if math.deg( math.acos( math.Clamp( Dir:Dot( self.MainGunDir ) ,-1,1) ) ) < 8 then
		Dir = self.MainGunDir
	end
	
	local bullet = {}
	bullet.Num 	= 1
	bullet.Src 	= Pos
	bullet.Dir 	= Dir
	bullet.Spread 	= Vector( 0.01,  0.01, 0 )
	bullet.Tracer	= 1
	bullet.TracerName	= "lfs_laser_green"
	bullet.Force	= 100
	bullet.HullSize 	= 22
	bullet.Damage	= 150
	bullet.Attacker 	= self:GetDriver()
	bullet.AmmoType = "Pistol"
	bullet.Callback = function(att, tr, dmginfo)
		if tr.Entity.IsSimfphyscar then
			dmginfo:SetDamageType(DMG_DIRECT)
		else
			dmginfo:SetDamageType(DMG_AIRBOAT)
		end
	end
	self:FireBullets( bullet )
	
	self:TakePrimaryAmmo()
end

function ENT:SecondaryAttack()
end

function ENT:MainGunPoser( EyeAngles )
	
	self.MainGunDir = EyeAngles:Forward()
	
	local startpos = self:GetRotorPos()
	local TracePlane = util.TraceHull( {
		start = startpos,
		endpos = (startpos + self.MainGunDir * 50000),
		mins = Vector( -10, -10, -10 ),
		maxs = Vector( 10, 10, 10 ),
		filter = {self,self:GetRearEnt()}
	} )
	
	local AimAngles = self:WorldToLocalAngles( (TracePlane.HitPos - self:LocalToWorld( Vector(265,0,100)) ):GetNormalized():Angle() )
	
	self:SetPoseParameter("frontgun_pitch", math.Clamp(AimAngles.p,-5,5) )
	self:SetPoseParameter("frontgun_yaw", AimAngles.y )

	local ID = self:LookupAttachment( "muzzle_right_up" )
	local Muzzle = self:GetAttachment( ID )
	
	if Muzzle then
		self:SetFrontInRange( math.deg( math.acos( math.Clamp( Muzzle.Ang:Up():Dot( self.MainGunDir ) ,-1,1) ) ) < 8 )
	end
end

local GroupCollide = {
	[COLLISION_GROUP_DEBRIS] = true,
	[COLLISION_GROUP_DEBRIS_TRIGGER] = true,
	[COLLISION_GROUP_PLAYER] = true,
	[COLLISION_GROUP_WEAPON] = true,
	[COLLISION_GROUP_VEHICLE_CLIP] = true,
	[COLLISION_GROUP_WORLD] = true,
}

local CanMoveOn = {
	["func_door"] = true,
	["func_movelinear"] = true,
	["prop_physics"] = true, -- nice to have if someone wants to build his own eleveator using props.
}

function ENT:VeryLowTick()
	return FrameTime() > (1 / 30)
end

function ENT:OnTick()

	if self:GetAI() then self:SetAI( false ) end
	
	local ATTE = {self,self:GetRearEnt()}
	
	local TurretPod = self:GetTurretSeat()
	if IsValid( TurretPod ) then
		local TurretDriver = TurretPod:GetDriver()
		if TurretDriver ~= self:GetTurretDriver() then
			self:SetTurretDriver( TurretDriver )
		end
	end
	
	if self:GetIsCarried() then 
		for _, ent in pairs( ATTE ) do
			if IsValid( ent ) then
				local PObj = ent:GetPhysicsObject()
				PObj:EnableGravity( false ) 
				if not PObj:IsMotionEnabled() then
					PObj:EnableMotion( true )
				end
			end
		end
		
		self.sm_ppmg_pitch = 0
		self.sm_ppmg_yaw = 180

		self:SetPoseParameter("cannon_pitch", 0 )
		self:SetPoseParameter("cannon_yaw", 180 )
		
		self:SetFrontInRange( false )
		self:SetRearInRange( false )
		
		return
	end
	
	if not self:GetEngineActive() then self:SetEngineActive( true ) end

	local Pod = self:GetDriverSeat()
	if not IsValid( Pod ) then return end
	
	local Driver = Pod:GetDriver()

	local FT = FrameTime()
	local FTtoTick = FT * 66.66666
	local TurnRate = FTtoTick * 0.6
	
	local Hit = 0
	local HitMoveable = false
	local Vel = self:GetVelocity()
	
	self:SetMove( self:GetMove() + self:WorldToLocal( self:GetPos() + Vel ).x * FT * 1.8 )

	local Move = self:GetMove()
	
	if Move > 360 then self:SetMove( Move - 360 ) end
	if Move < -360 then self:SetMove( Move + 360 ) end
	
	local EyeAngles = Angle(0,0,0)
	local KeyForward = false
	local KeyBack = false
	local KeyLeft = false
	local KeyRight = false
	
	local Sprint = false
	
	if IsValid( Driver ) then
		EyeAngles = Driver:EyeAngles()
		KeyForward = Driver:lfsGetInput( "+THROTTLE" ) or self.IsTurnMove
		KeyBack = Driver:lfsGetInput( "-THROTTLE" )
		KeyLeft = Driver:lfsGetInput( "+ROLL" )
		KeyRight = Driver:lfsGetInput( "-ROLL" ) 
		
		if KeyBack then
			KeyForward = false
		end
		
		Sprint = Driver:lfsGetInput( "VSPEC" ) or Driver:lfsGetInput( "+PITCH" ) or Driver:lfsGetInput( "-PITCH" )
		
		self:MainGunPoser( Pod:WorldToLocalAngles( EyeAngles ) )
	end
	local MoveSpeed = Sprint and 250 or 150
	self.smSpeed = self.smSpeed and self.smSpeed + ((KeyForward and MoveSpeed or 0) - (KeyBack and MoveSpeed or 0) - self.smSpeed) * FTtoTick * 0.05 or 0
	
	self:SetIsMoving(math.abs(self.smSpeed) > 1)
	
	for _, ent in pairs( ATTE ) do
		if IsValid( ent ) then
			local PObj = ent:GetPhysicsObject()
			
			local IsFront = ent == self
			
			if IsValid( PObj ) then
				local MassCenterL = PObj:GetMassCenter()
				MassCenterL.z = 140
				
				local MassCenter = ent:LocalToWorld( MassCenterL )
				
				local Forward = ent:GetForward()
				local Right = ent:GetRight()
				local Up = ent:GetUp()
				
				local Trace = util.TraceHull( {
					start = MassCenter, 
					endpos = MassCenter - Up * 200,
					
					filter = function( ent ) 
						if ent == self or ent == self:GetRearEnt() or ent:IsPlayer() or ent:IsNPC() or ent:IsVehicle() or GroupCollide[ ent:GetCollisionGroup() ] then
							return false
						end
						
						return true
					end,
					
					mins = Vector( -20, -20, 0 ),
					maxs = Vector( 20, 20, 0 ),
				})

				PObj:EnableGravity( not Trace.Hit )
				
				if not HitMoveable then
					if IsValid( Trace.Entity ) then
						HitMoveable = CanMoveOn[ Trace.Entity:GetClass() ]
					end
				end

				if Trace.Hit and math.deg( math.acos( math.Clamp( Trace.HitNormal:Dot( Vector(0,0,1) ) ,-1,1) ) ) < 70 then
					Hit = Hit + 1
					local Mass = PObj:GetMass()
					local TargetDist = 140
					local Dist = (Trace.HitPos - MassCenter):Length()
					
					local Vel = ent:GetVelocity()
					local VelL = ent:WorldToLocal( ent:GetPos() + Vel )
					
					local P = 0
					local R = 0
					
					if IsFront then
						P = math.cos( math.rad(Move * 2) ) * 15
						R = math.cos( math.rad(Move) ) * 15
					else
						R = math.cos( math.rad(Move + 90) ) * 15
					end
					
					ent.smNormal = ent.smNormal and ent.smNormal + (Trace.HitNormal - ent.smNormal) * FTtoTick * 0.01 or Trace.HitNormal
					local Normal = (ent.smNormal + self:LocalToWorldAngles( Angle(P,0,R) ):Up() * 0.1):GetNormalized()
					
					local Force = (Up * (TargetDist - Dist) * 3 - Up * VelL.z + Right * VelL.y) * 0.5
					
					if self:VeryLowTick() then
						Force = (Up * (TargetDist - Dist) * 1 - Up * VelL.z * 0.5 + Right * VelL.y * 0.5) * 0.5
					end
					
					PObj:ApplyForceCenter( Force * Mass * FTtoTick )
					
					local AngForce = Angle(0,0,0) 
					if IsFront then
						if IsValid( Driver ) then
							if Driver:lfsGetInput( "FREELOOK" ) then
								if isangle( self.StoredEyeAnglesATTE ) then
									EyeAngles = self.StoredEyeAnglesATTE 
								end
							else
								self.StoredEyeAnglesATTE  = EyeAngles
							end
							local AddYaw = (KeyRight and 30 or 0) - (KeyLeft and 30 or 0)
							local NEWsmY = math.ApproachAngle( self.smY, Pod:WorldToLocalAngles( EyeAngles + Angle(0,AddYaw,0) ).y, TurnRate )
							
							self.IsTurnMove = math.abs( NEWsmY - self.smY ) >= TurnRate * 0.99

							self.smY = self.smY and NEWsmY or ent:GetAngles().y
						else
							self.IsTurnMove = false
							self.smY = ent:GetAngles().y
						end
						
						AngForce.y = self:WorldToLocalAngles( Angle(0,self.smY,0) ).y
					end
					
					if self:VeryLowTick() then
						self:ApplyAngForceTo( ent, (AngForce * 50 - self:GetAngVelFrom( ent ) * 4) * Mass * 2 * FTtoTick )
						
						PObj:ApplyForceOffset( -Normal * Mass * 5 * FTtoTick, -Up * 200 )
						PObj:ApplyForceOffset( Normal * Mass * 5 * FTtoTick, Up * 200 )
					else
						self:ApplyAngForceTo( ent, (AngForce * 50 - self:GetAngVelFrom( ent ) * 2) * Mass * 10 * FTtoTick )
					
						PObj:ApplyForceOffset( -Normal * Mass * 5 * FTtoTick, -Up * 2000 )
						PObj:ApplyForceOffset( Normal * Mass * 5 * FTtoTick, Up * 2000 )
					end
				end
			end
		end
	end
	
	if Hit >= 2 and not HitMoveable then
		local IsHeld = self:IsPlayerHolding() or self:GetRearEnt():IsPlayerHolding() 
		local ShouldMotionEnable = self:GetIsMoving() or IsHeld
		
		if IsHeld then
			self.smSpeed = 200
		end
		
		for _, ent in pairs( ATTE ) do
			if IsValid( ent ) then
				local PObj = ent:GetPhysicsObject()

				
				if PObj:IsMotionEnabled() ~= ShouldMotionEnable then
					PObj:EnableMotion( ShouldMotionEnable )
				end
			end
		end
	else
		local ShouldMotionEnable = self:GetIsMoving() or IsHeld or HitMoveable
		
		for _, ent in pairs( ATTE ) do
			if IsValid( ent ) then
				local PObj = ent:GetPhysicsObject()

				if not PObj:IsMotionEnabled() then
					PObj:EnableMotion( ShouldMotionEnable )
				end
			end
		end
	end
	
	if Hit > 0 then
		local PObj = self:GetPhysicsObject()
		local Mass = PObj:GetMass()

		local Vel = self:GetVelocity()
		local VelL = self:WorldToLocal( self:GetPos() + Vel )

		local Force = self:GetForward() * (self.smSpeed - VelL.x)
		
		if self:VeryLowTick() then
			PObj:ApplyForceCenter( Force * Mass * FTtoTick * 0.1 )
		else
			PObj:ApplyForceCenter( Force * Mass * FTtoTick )
		end
	end
	
	self:GunnerWeapons( self:GetRearEnt(), self:GetGunner(), self:GetGunnerSeat() )
	self:Turret( self:GetTurretDriver(), TurretPod )
end

function ENT:Turret( Driver, Pod )
	if not IsValid( Pod ) or not IsValid( Driver ) then 
		return
	end
	
	local EyeAngles = Pod:WorldToLocalAngles( Driver:EyeAngles() )
	
	local AimDir = EyeAngles:Forward()
	
	local KeyAttack = Driver:KeyDown( IN_ATTACK )
	
	local TurretPos = self:LocalToWorld( Vector(94.13,0,216.8) )
	
	local startpos = TurretPos + EyeAngles:Up() * 100
	local TracePlane = util.TraceLine( {
		start = startpos,
		endpos = (startpos + AimDir * 50000),
		filter = {self:GetRearEnt(),self}
	} )

	local Pos,Ang = WorldToLocal( Vector(0,0,0), (TracePlane.HitPos - TurretPos ):GetNormalized():Angle(), Vector(0,0,0),self:GetAngles() )
	
	local AimRate = 100 * FrameTime() 
	
	self.sm_ppmg_pitch = self.sm_ppmg_pitch and math.ApproachAngle( self.sm_ppmg_pitch, Ang.p, AimRate ) or 0
	self.sm_ppmg_yaw = self.sm_ppmg_yaw and math.ApproachAngle( self.sm_ppmg_yaw, Ang.y, AimRate ) or 0
	
	local TargetAng = Angle(self.sm_ppmg_pitch,self.sm_ppmg_yaw,0)
	TargetAng:Normalize() 
	
	self:SetPoseParameter("cannon_pitch", TargetAng.p )
	self:SetPoseParameter("cannon_yaw", TargetAng.y )
	
	if KeyAttack then
		self:FireTurret( Driver )
	end
	
	if (self.cFireIndex or 0) > 0 and Driver:KeyDown( IN_RELOAD ) then
		self.cFireIndex = 0
		self:SetNextSecondary( 2 )
		Pod:EmitSound("LAATc_ATTE_CANNONRELOAD")
	end
end

function ENT:CanSecondaryAttack()
	self.NextSecondary = self.NextSecondary or 0

	return self.NextSecondary < CurTime() and self:GetAmmoSecondary() > 0
end

function ENT:FireTurret()
	if not self:CanSecondaryAttack() then return end
	
	self:SetNextSecondary( 0.5 )
	
	self.cFireIndex = self.cFireIndex and self.cFireIndex + 1 or 1
	if self.cFireIndex >= 3 then
		self.cFireIndex = 0
		self:SetNextSecondary( 2 )
		self:GetTurretSeat():EmitSound("LAATc_ATTE_CANNONRELOAD")
	end
	
	self:EmitSound( "LAATc_ATTE_CANNONFIRE" )
	
	local ID = self:LookupAttachment( "muzzle_cannon" )
	local Muzzle = self:GetAttachment( ID )

	if Muzzle then
		local ent = ents.Create( "lunasflightschool_missile" )
		ent:SetPos( Muzzle.Pos )
		ent:SetAngles( Muzzle.Ang:Up():Angle() )
		ent:Spawn()
		ent:Activate()
		ent:SetAttacker( self:GetTurretDriver() )
		ent:SetInflictor( self )
		ent:SetStartVelocity( 10000 )
		ent:SetCleanMissile( true )
		
		constraint.NoCollide( ent, self, 0, 0 ) 
		
		if IsValid( self:GetRearEnt() ) then
			constraint.NoCollide( ent, self:GetRearEnt(), 0, 0 )
		end
		
		self:TakeSecondaryAmmo()
	end
end

function ENT:GunnerWeapons( RearEnt, Driver, Pod )
	if not IsValid( RearEnt ) or not IsValid( Pod ) or not IsValid( Driver ) then 
		return
	else
		Driver:CrosshairDisable()
	end

	local EyeAngles = Pod:WorldToLocalAngles( Driver:EyeAngles() )
	local AimDir = EyeAngles:Forward()
	
	local KeyAttack = Driver:KeyDown( IN_ATTACK )

	local startpos = RearEnt:LocalToWorld( Vector(-200,0,180) ) + EyeAngles:Up() * 100
	local TracePlane = util.TraceLine( {
		start = startpos,
		endpos = (startpos + AimDir * 50000),
		filter = {RearEnt,self}
	} )

	local Pos,Ang = WorldToLocal( Vector(0,0,0), (TracePlane.HitPos - RearEnt:LocalToWorld( Vector(-230.76,0,165.42) ) ):GetNormalized():Angle(), Vector(0,0,0), RearEnt:LocalToWorldAngles( Angle(0,180,0) ) )
	
	RearEnt:SetPoseParameter("gun_pitch", math.Clamp(Ang.p,-10,30) )
	RearEnt:SetPoseParameter("gun_yaw", Ang.y )

	self:SetRearInRange( Ang.p < 30 and Ang.p > -10 and math.abs( Ang.y ) < 60 )
	
	if KeyAttack then
		self:FireRearGun()
	end
end

function ENT:GetAngVelFrom( ent )
	local phys = ent:GetPhysicsObject()
	if not IsValid( phys ) then return Angle(0,0,0) end
	
	local vec = phys:GetAngleVelocity()
	
	return Angle( vec.y, vec.z, vec.x )
end

function ENT:ApplyAngForceTo( ent, angForce )
	local phys = ent:GetPhysicsObject()

	if not IsValid( phys ) then return end
	
	local up = ent:GetUp()
	local left = ent:GetRight() * -1
	local forward = ent:GetForward()

	local pitch = up * (angForce.p * 0.5)
	phys:ApplyForceOffset( forward, pitch )
	phys:ApplyForceOffset( forward * -1, pitch * -1 )

	local yaw = forward * (angForce.y * 0.5)
	phys:ApplyForceOffset( left, yaw )
	phys:ApplyForceOffset( left * -1, yaw * -1 )

	local roll = left * (angForce.r * 0.5)
	phys:ApplyForceOffset( up, roll )
	phys:ApplyForceOffset( up * -1, roll * -1 )
end
