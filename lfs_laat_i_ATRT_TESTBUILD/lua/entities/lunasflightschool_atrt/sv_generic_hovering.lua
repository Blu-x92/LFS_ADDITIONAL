
-- DO NOT EDIT OR REUPLOAD THIS FILE

-- IF YOU WANT TO USE THIS ADD THIS ADDON TO YOUR REQUIREMENTS AND PUT THIS IN YOUR INIT.LUA:
-- include("entities/lunasflightschool_atrt/sv_generic_hovering.lua")

-- NO MODIFICATIONS ALLOWED. STOLEN ASSETS WILL BE DMCA'd

-- IF YOU HAVE QUESTIONS CONTACT ME HERE: https://s.team/chat/gnKPhT4M

ENT.RunSpeed = 200
ENT.WalkSpeed = 100

ENT.HoverDist = 140
ENT.TraceLengthAdd = 60
ENT.TraceHullRadius = 20

ENT.TurnRate = 0.5
ENT.AngularForceMul = 10
ENT.AngularVelDamping = 1

ENT.NormalAlignLever = 1000
ENT.NormalAlignMul = 1

ENT.AlignToGround = true

ENT.StrafeAngle = 45

ENT.ForceMul1 = 3
ENT.ForceMul2 = 0.5

ENT.GroupCollideFilter = {
	[COLLISION_GROUP_DEBRIS] = true,
	[COLLISION_GROUP_DEBRIS_TRIGGER] = true,
	[COLLISION_GROUP_PLAYER] = true,
	[COLLISION_GROUP_WEAPON] = true,
	[COLLISION_GROUP_VEHICLE_CLIP] = true,
	[COLLISION_GROUP_WORLD] = true,
}


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
	self:RunOnSpawn()
	self:InitWheels()
end

function ENT:RunOnSpawn()
end

function ENT:OnTick()
end

function ENT:MainGunPoser( EyeAngles )
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

function ENT:ApplyThrustVtol( PhysObj, vDirection, fForce )
end

function ENT:ApplyThrust( PObj, vDirection, fForce )
end

local function CalcHover( self )
	local PObj = self:GetPhysicsObject()
	
	if not IsValid( PObj ) then return end

	if self:GetAI() then self:SetAI( false ) end
	if not self:GetEngineActive() then self:SetEngineActive( true ) end

	local Pod = self:GetDriverSeat()
	if not IsValid( Pod ) then return end

	local Driver = Pod:GetDriver()

	local FT = FrameTime()
	local FTtoTick = FT * 66.66666
	local TurnRate = FTtoTick * self.TurnRate

	local Mass = PObj:GetMass()

	local Vel = self:GetVelocity()

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
	local MoveSpeed = Sprint and self.RunSpeed or self.WalkSpeed
	self.smSpeed = self.smSpeed and self.smSpeed + ((KeyForward and MoveSpeed or 0) - (KeyBack and MoveSpeed or 0) - self.smSpeed) * FTtoTick * 0.05 or 0

	local MassCenter = self:LocalToWorld( PObj:GetMassCenter() )
	
	local Forward = self:GetForward()
	local Right = self:GetRight()
	local Up = self:GetUp()

	local Trace = util.TraceHull( {
		start = MassCenter, 
		endpos = MassCenter - Up * (self.HoverDist + self.TraceLengthAdd),
		
		filter = function( ent ) 
			if ent == self or ent:IsPlayer() or ent:IsNPC() or ent:IsVehicle() or self.GroupCollideFilter[ ent:GetCollisionGroup() ] then
				return false
			end
			
			return true
		end,
		
		mins = Vector( -self.TraceHullRadius, -self.TraceHullRadius, 0 ),
		maxs = Vector( self.TraceHullRadius, self.TraceHullRadius, 0 ),
	})

	self.bOnGround = Trace.Hit and math.deg( math.acos( math.Clamp( Trace.HitNormal:Dot( Vector(0,0,1) ) ,-1,1) ) ) < 70
	PObj:EnableGravity( not self.bOnGround )

	local Dist = (Trace.HitPos - MassCenter):Length()

	local VelL = self:WorldToLocal( self:GetPos() + Vel )

	local Force = (Up * (self.HoverDist - Dist) * self.ForceMul1 - Up * VelL.z + Right * VelL.y) * self.ForceMul2 + Forward * (self.smSpeed - VelL.x)
	local HitNormal = self.AlignToGround and Trace.HitNormal or Vector(0,0,1)

	if self.bOnGround then
		PObj:ApplyForceCenter( Force * Mass * FTtoTick )
		
		self.smNormal = self.smNormal and self.smNormal + (HitNormal - self.smNormal) * FTtoTick * 0.01 or HitNormal
	else
		self.smNormal = self.smNormal and self.smNormal + (Vector(0,0,1) - self.smNormal) * FTtoTick * 0.01 or HitNormal
	end
	self.mP = self.mP or 0
	self.mR = self.mR or 0

	local Normal = (self.smNormal + self:LocalToWorldAngles( Angle(self.mP,0,self.mR) ):Up() * 0.1):GetNormalized()

	local AngForce = Angle(0,0,0) 
	if IsValid( Driver ) then
		self.smY = self.smY and self.smY or self:GetAngles().y

		if Driver:lfsGetInput( "FREELOOK" ) then
			if isangle( self.StoredEyeAnglesATTE ) then
				EyeAngles = self.StoredEyeAnglesATTE 
			end
		else
			self.StoredEyeAnglesATTE  = EyeAngles
		end
		local AddYaw = (KeyRight and self.StrafeAngle or 0) - (KeyLeft and self.StrafeAngle or 0)
		local NEWsmY = math.ApproachAngle( self.smY, Pod:WorldToLocalAngles( EyeAngles + Angle(0,AddYaw,0) ).y, TurnRate )
		
		self.IsTurnMove = math.abs( NEWsmY - self.smY ) >= TurnRate * 0.99

		self.smY = self.smY and NEWsmY or self:GetAngles().y
	else
		self.IsTurnMove = false
		self.smY = self:GetAngles().y
	end
	
	AngForce.y = self:WorldToLocalAngles( Angle(0,self.smY,0) ).y

	self:ApplyAngForce( (AngForce * self.AngularForceMul - self:GetAngVel() * self.AngularVelDamping) * Mass * FTtoTick )

	PObj:ApplyForceOffset( -Normal * Mass * FTtoTick * self.NormalAlignMul, -Up * self.NormalAlignLever )
	PObj:ApplyForceOffset( Normal * Mass * FTtoTick * self.NormalAlignMul, Up * self.NormalAlignLever )
end

function ENT:CalcFlightOverride( Pitch, Yaw, Roll, Stability )
	CalcHover( self )
	return 0,0,0,0,0,0
end
