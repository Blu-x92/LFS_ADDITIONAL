LFS_LOCALPHYSICS_CLASSES = {
	["lfs_crysis_vtol"] = true,
	["lunasflightschool_laatigunship"] = true,
}

hook.Add( "PlayerLeaveVehicle", "!!!_zz_laati_vtol_stuff", function( ply, veh )
	if ply.lfsEnterVehicleTime then
		if ply.lfsEnterVehicleTime > CurTime() then
			timer.Simple(FrameTime(), function()
				if not IsValid( veh ) or not IsValid( ply ) then return end
				ply:EnterVehicle( veh )
			end)
		end
	end
end)

hook.Add( "OnEntityCreated", "!!!_zz_laati_vtol_stuff", function( ent )
	if not IsValid( ent ) then return end

	local CLASS = ent:GetClass()

	if LFS_LOCALPHYSICS_CLASSES[ CLASS ] then

		if not GravHull then 
			print("[LFS] localphysics extension requires gravity hull designator to work")
			print("[LFS] Get (Official) Gravity Hull Designator - Localized Physics Addon:")
			print("[LFS] https://steamcommunity.com/sharedfiles/filedetails/?id=531849338")
			
			return
		end

		timer.Simple(FrameTime() * 2, 
			function()
				if not IsValid( ent ) then return end

				GravHull.RegisterHull(ent,0,100)
				GravHull.UpdateHull(ent,1, ent:GetUp())

				ent.Use = function(ent, ply )
					if not IsValid( ply ) then return end
					ply.lfsEnterVehicleTime = CurTime() + 0.1

					if ent:GetlfsLockedStatus() or (simfphys.LFS.TeamPassenger:GetBool() and ((ent:GetAITEAM() ~= ply:lfsGetAITeam()) and ply:lfsGetAITeam() ~= 0 and ent:GetAITEAM() ~= 0)) then 

						ent:EmitSound( "doors/default_locked.wav" )

						return
					end

					ent:SetPassenger( ply )
				end
				
				if CLASS:lower() == "lunasflightschool_laatigunship" then
					for _, Pod in pairs( ent:GetPassengerSeats() ) do
						if IsValid( Pod ) and Pod:GetNWInt( "pPodIndex", 0 ) > 4 then
							Pod:Remove()
						end
					end
				end
			end
		)
	end
end )
