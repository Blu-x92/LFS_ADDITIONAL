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

ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName = "LAAT/c (ATTE)"
ENT.Author = "Blu"
ENT.Information = ""
ENT.Category = "[LFS]"

ENT.Spawnable		= true
ENT.AdminSpawnable	= false

ENT.RotorPos = Vector(200,0,185)

ENT.LAATC_PICKUPABLE = true
ENT.LAATC_PICKUP_POS = Vector(-220,0,-115)
ENT.LAATC_PICKUP_Angle = Angle(0,0,0)

ENT.MDL = "models/blu/atte.mdl"
ENT.GibModels = {
	"models/blu/atte.mdl",
	"models/blu/atte_rear.mdl",
	"models/blu/atte_bigfoot.mdl",
	"models/blu/atte_bigleg.mdl",
	"models/blu/atte_smallleg_part1.mdl",
	"models/blu/atte_smallleg_part2.mdl",
	"models/blu/atte_smallleg_part3.mdl"
}

ENT.MaxPrimaryAmmo = 1000
ENT.MaxSecondaryAmmo = 54

ENT.AITEAM = 2

ENT.Mass = 5000

ENT.SeatPos = Vector(218,0,148)
ENT.SeatAng = Angle(0,-90,0)

ENT.MaxHealth = 10000

function ENT:AddDataTables()
	self:NetworkVar( "Entity",22, "RearEnt" )
	
	self:NetworkVar( "Entity",23, "TurretDriver" )
	self:NetworkVar( "Entity",24, "TurretSeat" )
	
	self:NetworkVar( "Float",22, "Move" )

	self:NetworkVar( "Bool",19, "IsMoving" )
	self:NetworkVar( "Bool",20, "IsCarried" )
	self:NetworkVar( "Bool",21, "FrontInRange" )
	self:NetworkVar( "Bool",22, "RearInRange" )
end

sound.Add( {
	name = "LAATc_ATTE_FIRE",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 125,
	pitch = {95, 105},
	sound = "lfs/laatc_atte/fire.mp3"
} )

sound.Add( {
	name = "LAATc_ATTE_CANNONFIRE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	pitch = {90, 110},
	sound = "lfs/laatc_atte/fire_turret.mp3"
} )

sound.Add( {
	name = "LAATc_ATTE_CANNONRELOAD",
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 90,
	pitch = 100,
	sound = "lfs/laatc_atte/overheat.mp3"
} )

sound.Add( {
	name = "LAATc_ATTE_EXPLOSION",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	pitch = {90, 110},
	sound = "^lfs/laatc_atte/massdriver_impact.wav"
} )
