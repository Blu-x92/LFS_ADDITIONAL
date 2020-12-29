--DO NOT EDIT OR REUPLOAD THIS FILE

ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName = "ARC-170 fighter"
ENT.Author = "Luna"
ENT.Information = "Heavy-Duty Starfighter of the Galactic Republic"
ENT.Category = "[LFS] - Star Wars Pack"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/blu/arc170.mdl"
ENT.GibModels = {
	"models/salza/arc170_gib1.mdl",
	"models/salza/arc170_gib2.mdl",
	"models/salza/arc170_gib3.mdl",
	"models/salza/arc170_gib4.mdl",
	"models/salza/arc170_gib5.mdl",
	"models/salza/arc170_gib6.mdl"
}

ENT.AITEAM = 2

ENT.Mass = 5000
ENT.Inertia = Vector(400000,400000,400000)
ENT.Drag = 1

ENT.SeatPos = Vector(45,0,5)
ENT.SeatAng = Angle(0,-90,0)

ENT.IdleRPM = 1
ENT.MaxRPM = 2600
ENT.LimitRPM = 3200

ENT.RotorPos = Vector(225,0,10)
ENT.WingPos = Vector(100,0,10)
ENT.ElevatorPos = Vector(-200,0,10)
ENT.RudderPos = Vector(-200,0,10)

ENT.MaxVelocity = 2500

ENT.MaxThrust = 50000

ENT.MaxTurnPitch = 550
ENT.MaxTurnYaw = 550
ENT.MaxTurnRoll = 300

ENT.MaxPerfVelocity = 1500

ENT.MaxHealth = 1600
ENT.MaxShield = 600

ENT.Stability = 0.7

ENT.VerticalTakeoff = true
ENT.VtolAllowInputBelowThrottle = 10
ENT.MaxThrustVtol = 12000

ENT.MaxPrimaryAmmo = 1000
ENT.MaxSecondaryAmmo = 6

sound.Add( {
	name = "ARC170_FIRE",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 125,
	pitch = {95, 105},
	sound = "lfs/arc170/fire.mp3"
} )

sound.Add( {
	name = "ARC170_FIRE2",
	channel = CHAN_STREAM,
	volume = 1.0,
	level = 125,
	pitch = {95, 105},
	sound = "lfs/arc170/fire_gunner.mp3"
} )

sound.Add( {
	name = "ARC170_ENGINE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 120,
	sound = "lfs/arc170/loop.wav"
} )

sound.Add( {
	name = "ARC170_BOOST",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "lfs/arc170/boost.wav"
} )

sound.Add( {
	name = "ARC170_FOILS",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "lfs/arc170/sfoils.wav"
} )

sound.Add( {
	name = "ARC170_BRAKE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "lfs/arc170/brake.wav"
} )