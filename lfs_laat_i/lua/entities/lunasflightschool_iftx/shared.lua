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
DEFINE_BASECLASS( "lunasflightschool_basescript_gunship" )

ENT.PrintName = "LAAT/c (IFT-X)"
ENT.Author = "Blu"
ENT.Information = ""
ENT.Category = "[LFS]"

ENT.Spawnable		= true
ENT.AdminSpawnable	= false

ENT.MDL = "models/blu/iftx.mdl"

ENT.MaxPrimaryAmmo = 600
ENT.MaxSecondaryAmmo = 50

ENT.AITEAM = 2

ENT.Mass = 2500

ENT.HideDriver = true
ENT.SeatPos = Vector(-30,0,43)
ENT.SeatAng = Angle(0,-90,0)

ENT.MaxHealth = 2700

ENT.MaxTurnPitch = 1000
ENT.MaxTurnYaw = 80
ENT.MaxTurnRoll = 1000

ENT.PitchDamping = 1
ENT.YawDamping = 1.5
ENT.RollDamping = 1

ENT.TurnForcePitch = 25
ENT.TurnForceYaw = 800
ENT.TurnForceRoll = 25

ENT.RotorPos = Vector(70,0,43)

ENT.IdleRPM = 0
ENT.MaxRPM = 100
ENT.LimitRPM = 100
ENT.RPMThrottleIncrement = 250

ENT.MaxVelocity = 400
ENT.BoostVelAdd = 100
ENT.ThrustMul = 5
ENT.DampingMul = 1

ENT.DontPushMePlease = true

ENT.LAATC_PICKUPABLE = true
ENT.LAATC_PICKUP_POS = Vector(-200,0,25)
ENT.LAATC_PICKUP_Angle = Angle(0,0,0)

function ENT:AddDataTables()
	self:NetworkVar( "Bool",19, "BTLFire" )
	self:NetworkVar( "Bool",20, "IsCarried" )
	self:NetworkVar( "Bool",21, "WeaponOutOfRange" )

	if SERVER then
		self:NetworkVarNotify( "IsCarried", self.OnIsCarried )
	end
end


sound.Add( {
	name = "LAATc_IFTX_FIRE",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 125,
	pitch = {95, 105},
	sound = "lfs/iftx/fire.mp3"
} )

sound.Add( {
	name = "LAATc_IFTX_FIRE_TURRET",
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 125,
	pitch = {95, 105},
	sound = "lfs/iftx/fire_turret.mp3"
} )

sound.Add( {
	name = "LAATc_IFTX_FIRE_MISSILE",
	channel = CHAN_VOICE,
	volume = 1.0,
	level = 125,
	pitch = {95, 105},
	sound = "lfs/iftx/fire_MISSILE.mp3"
} )

sound.Add( {
	name = "LAATc_IFTX_ENGINE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 90,
	sound = "lfs/iftx/loop.wav"
} )

sound.Add( {
	name = "LAATc_IFTX_ENGINE_HI",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 90,
	sound = "lfs/iftx/loop_HI.wav"
} )


sound.Add( {
	name = "LAATc_IFTX_DIST",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 110,
	sound = "^lfs/iftx/dist.wav"
} )
