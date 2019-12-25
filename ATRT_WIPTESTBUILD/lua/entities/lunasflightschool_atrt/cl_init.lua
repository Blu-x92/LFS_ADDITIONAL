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


include("shared.lua")
include("entities/lunasflightschool_atte/cl_ikfunctions.lua")

function ENT:DamageFX()
	local HP = self:GetHP()
	if HP == 0 or HP > self:GetMaxHP() * 0.5 then return end
	
	self.nextDFX = self.nextDFX or 0
	
	if self.nextDFX < CurTime() then
		self.nextDFX = CurTime() + 0.05
		
		local effectdata = EffectData()
			effectdata:SetOrigin( self:LocalToWorld( Vector(-10,0,90) ) )
		util.Effect( "lfs_blacksmoke", effectdata )
	end
end

function ENT:OnRemoveAdd() -- since ENT:OnRemove() is used by the IK script we need to do our stuff here
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:LFSCalcViewFirstPerson( view, ply )
	return view
end

function ENT:LFSCalcViewThirdPerson( view, ply )
	return view
end

function ENT:LFSHudPaintInfoText( X, Y, speed, alt, AmmoPrimary, AmmoSecondary, Throttle )
	draw.SimpleText( "SPEED", "LFS_FONT", 10, 10, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( speed.."km/h", "LFS_FONT", 120, 10, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

	draw.SimpleText( "PRI", "LFS_FONT", 10, 35, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( AmmoPrimary, "LFS_FONT", 120, 35, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
end

function ENT:LFSHudPaintInfoLine( HitPlane, HitPilot, LFS_TIME_NOTIFY, Dir, Len, FREELOOK )
end

function ENT:LFSHudPaintCrosshair( HitEnt, HitPly)
	local startpos = self:GetRotorPos()
	local TracePilot = util.TraceHull( {
		start = startpos,
		endpos = (startpos + LocalPlayer():EyeAngles():Forward() * 50000),
		mins = Vector( -10, -10, -10 ),
		maxs = Vector( 10, 10, 10 ),
		filter = self
	} )
	local HitPilot = TracePilot.HitPos:ToScreen()

	local X = HitPilot.x
	local Y = HitPilot.y
	
	if self:GetFrontInRange() then
		surface.SetDrawColor( 255, 255, 255, 255 )
	else
		surface.SetDrawColor( 255, 0, 0, 255 )
	end

	simfphys.LFS.DrawCircle( X, Y, 10 )
	surface.DrawLine( X + 10, Y, X + 20, Y ) 
	surface.DrawLine( X - 10, Y, X - 20, Y ) 
	surface.DrawLine( X, Y + 10, X, Y + 20 ) 
	surface.DrawLine( X, Y - 10, X, Y - 20 ) 
	
	-- shadow
	surface.SetDrawColor( 0, 0, 0, 80 )
	simfphys.LFS.DrawCircle( X + 1, Y + 1, 10 )
	surface.DrawLine( X + 11, Y + 1, X + 21, Y + 1 ) 
	surface.DrawLine( X - 9, Y + 1, X - 16, Y + 1 ) 
	surface.DrawLine( X + 1, Y + 11, X + 1, Y + 21 ) 
	surface.DrawLine( X + 1, Y - 19, X + 1, Y - 16 ) 
end

function ENT:LFSHudPaintRollIndicator( HitPlane, Enabled ) -- roll indicator
end

local GroupCollide = {
	[COLLISION_GROUP_DEBRIS] = true,
	[COLLISION_GROUP_DEBRIS_TRIGGER] = true,
	[COLLISION_GROUP_PLAYER] = true,
	[COLLISION_GROUP_WEAPON] = true,
	[COLLISION_GROUP_VEHICLE_CLIP] = true,
	[COLLISION_GROUP_WORLD] = true,
}

function ENT:Think()
	self:DamageFX()
	
	local Up = self:GetUp()
	local Forward = self:GetForward()
	local Vel = self:GetVelocity()
	
	local Sprinting = self:GetIsSprinting() 

	local Stride = Sprinting and 80 or 30
	local Lift = Sprinting and 30 or 25
	local FootP = Sprinting and 55 or 35
	local FootPO = Sprinting and 45 or 55
	local XO = Sprinting and 35 or 20
	local FT = FrameTime()
	local Rate = FT * 20
	local PPMul = 1
	local MoveSpeed = Sprinting and 1.5 or 3

	local IsMoving = self:GetIsMoving()
	if not IsMoving then
		Lift = 0
		FootP = 0
		PPMul = 0
	
		self.Move = self:GetMove()
	else
		self.Move = self.Move and self.Move + self:WorldToLocal( self:GetPos() + Vel ).x * FT * MoveSpeed or 0
	end
	
	local Cycl1 = self.Move
	local Cycl2 = self.Move + 180

	-- LEFT
	local X = -XO + math.cos( math.rad(Cycl1) ) * Stride
	local Z = math.max( math.sin( math.rad(-Cycl1) ), 0)
	
	local STARTPOS = self:LocalToWorld( Vector(1.76,14.41,68.43) )
	self.TRACEPOS1 = self.TRACEPOS1 and self.TRACEPOS1 or STARTPOS
	if Z > 0 or not IsMoving then 
		self.TRACEPOS1 = self.TRACEPOS1 + (STARTPOS + Forward * X - self.TRACEPOS1) * Rate + Vel*FT
		self.FSOG1 = false
	else
		self.FSOG1 = true
	end
	local ENDPOS = util.TraceLine( { start = self.TRACEPOS1 - Up * 50, endpos = self.TRACEPOS1 - Up * 160, filter = function( ent ) if ent == self or GroupCollide[ ent:GetCollisionGroup() ] then return false end return true end,} ).HitPos + Vector(0,0,35+Z*Lift)
	if self.FSOG1 ~= self.oldFSOG1 then
		self.oldFSOG1 = self.FSOG1
		if self.FSOG1 then
			sound.Play( Sound( "lfs/atrt/foot_drop.ogg" ), ENDPOS, SNDLVL_70dB )
		end
	end
	
	local ATTACHMENTS = {
		Leg1 = {MDL = "models/blu/atrt_leftleg2.mdl", Ang = Angle(-90,0,-90), Pos = Vector(0,0,0)},
		Leg2 = {MDL = "models/blu/atrt_leftleg1.mdl", Ang = Angle(-90,0,-90), Pos = Vector(0,0,0)},
		Foot = {MDL = "models/blu/atrt_leftfoot.mdl", Ang = Angle( -math.min(math.cos( math.rad(-Cycl1 + FootPO) ),0) * FootP,0,0), Pos = Vector(0,0,0)}
	}
	self:GetLegEnts( 1, 26, 30.5, self:LocalToWorldAngles( Angle(90,0,0) ), STARTPOS, ENDPOS, ATTACHMENTS )

	if self.IK_Joints then
		if self.IK_Joints[ 1 ].Attachment3 then
			self.IK_Joints[ 1 ].Attachment3:SetPoseParameter( "move", Z * PPMul )
			self.IK_Joints[ 1 ].Attachment3:InvalidateBoneCache() 
		end
	end
	
	-- RIGHT
	local X = -XO + math.cos( math.rad(Cycl2) ) * Stride
	local Z = math.max( math.sin( math.rad(-Cycl2) ), 0)
	local ZOffset = math.Clamp((X / Stride),0,1)

	local STARTPOS = self:LocalToWorld( Vector(1.76,-14.41,68.43) )
	self.TRACEPOS2 = self.TRACEPOS2 and self.TRACEPOS2 or STARTPOS
	if Z > 0 or not IsMoving then 
		self.TRACEPOS2 = self.TRACEPOS2 + (STARTPOS + Forward * X - self.TRACEPOS2) * Rate + Vel*FT
		self.FSOG2 = false
	else
		self.FSOG2 = true
	end
	local ENDPOS = util.TraceLine( { start = self.TRACEPOS2 - Up * 50, endpos = self.TRACEPOS2 - Up * 160, filter = function( ent ) if ent == self or GroupCollide[ ent:GetCollisionGroup() ] then return false end return true end,} ).HitPos + Vector(0,0,35+Z*Lift)
	if self.FSOG2 ~= self.oldFSOG2 then
		self.oldFSOG2 = self.FSOG2
		if self.FSOG2 then
			sound.Play( Sound( "lfs/atrt/foot_drop.ogg" ), ENDPOS, SNDLVL_70dB )
		end
	end
	
	local ATTACHMENTS = {
		Leg1 = {MDL = "models/blu/atrt_rightleg2.mdl", Ang = Angle(-90,0,90), Pos = Vector(0,0,0)},
		Leg2 = {MDL = "models/blu/atrt_rightleg1.mdl", Ang = Angle(-90,0,90), Pos = Vector(0,0,0)},
		Foot = {MDL = "models/blu/atrt_rightfoot.mdl", Ang = Angle(-math.min(math.cos( math.rad(-Cycl2 + FootPO) ),0) * FootP,0,0), Pos = Vector(0,0,0)}
	}
	self:GetLegEnts( 2, 26, 30.5, self:LocalToWorldAngles( Angle(90,0,0) ), STARTPOS, ENDPOS, ATTACHMENTS )
	
	if self.IK_Joints then
		if self.IK_Joints[ 2 ].Attachment3 then
			self.IK_Joints[ 2 ].Attachment3:SetPoseParameter( "move", Z * PPMul )
			self.IK_Joints[ 2 ].Attachment3:InvalidateBoneCache() 
		end
	end
end
