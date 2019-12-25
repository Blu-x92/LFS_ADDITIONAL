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

ENT.PrintName = "ATRT"
ENT.Author = "Blu"
ENT.Information = ""
ENT.Category = "[LFS]"

ENT.Spawnable		= true
ENT.AdminSpawnable	= false
ENT.ATRT = true

ENT.MDL = "models/blu/atrt.mdl"
ENT.GibModels = {
	"models/blu/atrt.mdl",
	"models/blu/atrt_leftleg2.mdl",
	"models/blu/atrt_leftleg1.mdl",
	"models/blu/atrt_leftfoot.mdl",
	"models/blu/atrt_leftleg2.mdl",
	"models/blu/atrt_leftleg1.mdl",
	"models/blu/atrt_leftfoot.mdl",
}

ENT.MaxPrimaryAmmo = 10
ENT.MaxSecondaryAmmo = -1

ENT.AITEAM = 2

ENT.Mass = 1000

ENT.SeatPos = Vector(-20,0,92)
ENT.SeatAng = Angle(0,-90,-20)

ENT.MaxHealth = 1000

ENT.RotorPos = Vector(-50,0,90)

function ENT:AddDataTables()
	self:NetworkVar( "Float",22, "Move" )
	self:NetworkVar( "Bool",19, "IsMoving" )
	self:NetworkVar( "Bool",20, "IsSprinting" )
	self:NetworkVar( "Bool",21, "FrontInRange" )
end

sound.Add( {
	name = "LAATi_ATRT_FIRE",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 125,
	pitch = {95, 110},
	sound = "lfs/atrt/fire_mel.mp3"
} )

sound.Add( {
	name = "LAATi_ATRT_FIRE_POP",
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 125,
	pitch = 100,
	sound = "lfs/atrt/fire_pop.mp3"
} )

sound.Add( {
	name = "LAATi_ATRT_CHARGE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 90,
	pitch = 100,
	sound = "lfs/atrt/fire_start.ogg"
} )

sound.Add( {
	name = "LAATi_ATRT_STOPCHARGE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 90,
	pitch = 100,
	sound = "lfs/atrt/fire_stop.ogg"
} )