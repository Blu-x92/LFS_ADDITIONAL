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

AddCSLuaFile()

ENT.Type            = "anim"

ENT.PrintName = "ATTE"
ENT.Author = "Blu"
ENT.AutomaticFrameAdvance = true
ENT.DoNotDuplicate = true

if SERVER then
	function ENT:Initialize()	
		self:SetModel( "models/blu/atte_rear.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
	end

	function ENT:Use( ply )
		if IsValid( self.ATTEBaseEnt ) then
			self.ATTEBaseEnt:SetPassenger( ply )
		end
	end

	function ENT:Think()
		self:NextThink( CurTime() )
		return true
	end

	function ENT:OnTakeDamage( dmginfo )
		self:TakePhysicsDamage( dmginfo )
		
		if IsValid( self.ATTEBaseEnt ) then
			self.ATTEBaseEnt:TakeDamageInfo( dmginfo ) 
		end
	end
else 
	AddCSLuaFile("entities/lunasflightschool_atte/cl_ikfunctions.lua")
	include("entities/lunasflightschool_atte/cl_ikfunctions.lua")

	function ENT:OnRemoveAdd() -- since ENT:OnRemove() is used by the IK script we need to do our stuff here
	end

	function ENT:DrawAdd() -- ENT:Draw() is used by the IK script we need to do our stuff here instead
		self:DrawModel()
	end
	
	function ENT:ThinkAdd() -- ENT:Think() is used by the IK script we need to do our stuff here instead
	end
end