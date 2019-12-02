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

function ENT:Initialize()
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

	local ent = ents.Create( "prop_physics" )
	ent:SetPos( self:GetPos() )
	ent:SetAngles( self:GetAngles() )
	ent:SetModel( "models/blu/atte_rear.mdl" )
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
	
	self:InitWheels()
	self:RunOnSpawn()
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


function ENT:PrimaryAttack()
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
	
	self.FireIndex = self.FireIndex and self.FireIndex + 1 or 1
	
	if self.FireIndex > 4 then
		self.FireIndex = 1
		self:SetNextPrimary( 0.5 )
	else
		if self.FireIndex == 3 then
			self:SetNextPrimary( 0.21)
		else
			self:SetNextPrimary( 0.1 )
		end
	end
	
	self:EmitSound( "LAATc_ATTE_FIRE" )

	local Pos = FirePos[self.FireIndex].Pos
	local Dir =  FirePos[self.FireIndex].Ang:Up()
	
	if math.deg( math.acos( math.Clamp( Dir:Dot( self.MainGunDir ) ,-1,1) ) ) < 5 then
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
end

local GroupCollide = {
	[COLLISION_GROUP_DEBRIS] = true,
	[COLLISION_GROUP_DEBRIS_TRIGGER] = true,
	[COLLISION_GROUP_PLAYER] = true,
	[COLLISION_GROUP_WEAPON] = true,
	[COLLISION_GROUP_VEHICLE_CLIP] = true,
	[COLLISION_GROUP_WORLD] = true,
}

function ENT:OnTick()
	if self:GetIsCarried() then 
		for _, ent in pairs( {self,self:GetRearEnt()} ) do
			if IsValid( ent ) then
				local PObj = ent:GetPhysicsObject()
				PObj:EnableGravity( false ) 
			end
		end
		
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
	local Vel = self:GetVelocity()
	
	self:SetMove( self:GetMove() + self:WorldToLocal( self:GetPos() + Vel ).x * FT * 1.8 )

	local Move = self:GetMove()
	
	if Move > 360 then self:SetMove( Move - 360 ) end
	if Move < -360 then self:SetMove( Move + 360 ) end
	
	local EyeAngles = Angle(0,0,0)
	local KeyForward = false
	local KeyBack = false
	local Sprint = false
	
	if IsValid( Driver ) then
		EyeAngles = Driver:EyeAngles()
		KeyForward = Driver:lfsGetInput( "+THROTTLE" ) or self.IsTurnMove
		KeyBack = Driver:lfsGetInput( "-THROTTLE" )
		if KeyBack then
			KeyForward = false
		end
		
		Sprint = Driver:lfsGetInput( "VSPEC" ) or Driver:lfsGetInput( "+PITCH" ) or Driver:lfsGetInput( "-PITCH" )
		
		self:MainGunPoser( Pod:WorldToLocalAngles( EyeAngles ) )
	end
	local MoveSpeed = Sprint and 250 or 150
	self.smSpeed = self.smSpeed and self.smSpeed + ((KeyForward and MoveSpeed or 0) - (KeyBack and MoveSpeed or 0) - self.smSpeed) * FTtoTick * 0.05 or 0
	
	self:SetIsMoving(math.abs(self.smSpeed) > 1)
	
	for _, ent in pairs( {self,self:GetRearEnt()} ) do
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
					endpos = MassCenter - Up * 160,
					
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
					
					local Force = Up * (TargetDist - Dist) * 7 - Up * VelL.z + Right * VelL.y
					
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
							
							local NEWsmY = math.ApproachAngle( self.smY, Pod:WorldToLocalAngles( EyeAngles ).y, TurnRate )
							
							self.IsTurnMove = math.abs( NEWsmY - self.smY ) >= TurnRate * 0.99

							self.smY = self.smY and NEWsmY or ent:GetAngles().y
						else
							self.IsTurnMove = false
							self.smY = ent:GetAngles().y
						end
						
						AngForce.y = self:WorldToLocalAngles( Angle(0,self.smY,0) ).y
					end
					
					self:ApplyAngForceTo( ent, (AngForce * 50 - self:GetAngVelFrom( ent ) * 2) * Mass * 10 * FTtoTick )
					
					PObj:ApplyForceOffset( -Normal * Mass * 5 * FTtoTick, -Up * 2000 )
					PObj:ApplyForceOffset( Normal * Mass * 5 * FTtoTick, Up * 2000 )
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

		PObj:ApplyForceCenter( Force * Mass * FTtoTick )
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

function ENT:ApplyThrustVtol( PhysObj, vDirection, fForce )
end

function ENT:ApplyThrust( PhysObj, vDirection, fForce )
end

function ENT:CalcFlightOverride( Pitch, Yaw, Roll, Stability )
	return 0,0,0,0,0,0
end

function ENT:RunOnSpawn()
end

hook.Add( "EntityTakeDamage", "ATTE_DMG_TRANSMIT", function( target, dmginfo )
	if IsValid( target.ATTEBaseEnt ) then
		target.ATTEBaseEnt:TakeDamageInfo( dmginfo ) 
	end
end )