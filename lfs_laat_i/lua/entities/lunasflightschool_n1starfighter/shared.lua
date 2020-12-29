--DO NOT EDIT OR REUPLOAD THIS FILE

ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName = "N1 Starfighter"
ENT.Author = "Luna"
ENT.Information = "Starfighter of the Royal Naboo Security Force"
ENT.Category = "[LFS] - Star Wars Pack"

ENT.Spawnable		= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/blu/naboostarfighter.mdl"

ENT.AITEAM = 2

ENT.Mass = 5000
ENT.Inertia = Vector(250000,250000,250000)
ENT.Drag = -1

ENT.SeatPos = Vector(-30,0,33)
ENT.SeatAng = Angle(0,-90,0)

ENT.IdleRPM = 1
ENT.MaxRPM = 2200
ENT.LimitRPM = 3000

ENT.RotorPos = Vector(90,0,35)
ENT.WingPos = Vector(98.33,0,36.63)
ENT.ElevatorPos = Vector(-300,0,54.62)
ENT.RudderPos = Vector(-300,0,54.62)

ENT.MaxVelocity = 3000

ENT.MaxThrust = 25000

ENT.MaxTurnPitch = 800
ENT.MaxTurnYaw = 800
ENT.MaxTurnRoll = 300

ENT.MaxPerfVelocity = 1500

ENT.MaxHealth = 450
ENT.MaxShield = 400

ENT.Stability = 0.7

ENT.VerticalTakeoff = true
ENT.VtolAllowInputBelowThrottle = 10
ENT.MaxThrustVtol = 10000

ENT.MaxPrimaryAmmo = 400
ENT.MaxSecondaryAmmo = 10

sound.Add( {
	name = "N1_FIRE",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 125,
	pitch = {90, 95},
	sound = "lfs/naboo_n1_starfighter/fire.mp3"
} )

sound.Add( {
	name = "N1_FIRE2",
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 125,
	pitch = {95, 105},
	sound = "lfs/naboo_n1_starfighter/proton_fire.mp3"
} )

sound.Add( {
	name = "N1_ENGINE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 120,
	sound = "lfs/naboo_n1_starfighter/loop.wav"
} )

sound.Add( {
	name = "N1_BOOST",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "lfs/naboo_n1_starfighter/boost.wav"
} )

sound.Add( {
	name = "N1_BRAKE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "lfs/naboo_n1_starfighter/brake.wav"
} )