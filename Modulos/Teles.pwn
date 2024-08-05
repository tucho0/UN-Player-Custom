#define DIR_TELES "Teles/%i.tele"
#define MAX_TELES_COUNT 300

forward SaveTele(teleid, bool:update);
forward LoadTeles();
forward GetNextTeleID();
forward CrearTele(Float:x, Float:y, Float:z, Float:zz, worldid, interiorid);
forward BorrarTele(teleid);
forward CreateTeleDynamicPickup(modelid, teleid, Float:x, Float:y, Float:z, worldid, interiorid);
forward SetText3DTele(teleid, const text[]);
forward PlayerHaveTeleKeys(playerid, teleid, tipo, tipoid);

enum TelesEnum
{
	Float:PosX,
	Float:PosY,
	Float:PosZ,
	Float:PosZZ,
	PickupID,
	PickupIDGo,
	Text3D:TextLabel,
	World,
	Interior,
	Lock,
	Dueno,
	DuenoType, // 0: Faccion | 1: Negocio | 2: Casa | 3: Local
	IsBankTele,
	IsHotelTele,
	IsNegocioTele,
	IsCasaTele,
	IsLocalTele,
	PrecioEntrada,
	LugarText[128]
};

new Teles[MAX_TELES_COUNT][TelesEnum];
new MAX_TELES;
new TelesDuenoType[4][10] = {"Faccion","Negocio","Casa","Local"};

public SaveTele(teleid, bool:update)
{
    if (Teles[teleid][PickupID] != 0)
    {
        new teleInfo[300], teleDIR[20];
        format(teleDIR, sizeof(teleDIR), DIR_TELES, teleid);  
        new File:handle = fopen(teleDIR, io_write);
        
        format(teleInfo, sizeof(teleInfo), "%f|%f|%f|%f|%i|%i|%i|%i|%i|%i|%i|%i|%i|%i|%i|%i|%s|",
		    Teles[teleid][PosX],
		    Teles[teleid][PosY],
		    Teles[teleid][PosZ],
		    Teles[teleid][PosZZ],
		    Teles[teleid][PickupIDGo],
		    Teles[teleid][World],
		    Teles[teleid][Interior],
		    Teles[teleid][Lock],
		    Teles[teleid][Dueno],
		    Teles[teleid][DuenoType],
		    Teles[teleid][IsBankTele],
		    Teles[teleid][IsHotelTele],
		    Teles[teleid][IsNegocioTele],
		    Teles[teleid][IsCasaTele],
		    Teles[teleid][IsLocalTele],
		    Teles[teleid][PrecioEntrada],
		    Teles[teleid][LugarText]
		);
		fwrite(handle, teleInfo);
		fclose(handle);
		
		if (update)
		{
		    new pickupid = Teles[teleid][PickupID];
		    DestroyDynamicPickup(pickupid);
		    PickupIndex[pickupid][Tipo] = PICKUP_TYPE_NINGUNO;
			PickupIndex[pickupid][Tipoid] = 0;
		    
		    Teles[teleid][PickupID] = CreateTeleDynamicPickup(1239, teleid, Teles[teleid][PosX], Teles[teleid][PosY], Teles[teleid][PosZ], Teles[teleid][World], Teles[teleid][Interior]);
		    
		    DestroyDynamic3DTextLabel(Teles[teleid][TextLabel]);
			SetText3DTele(teleid, Teles[teleid][LugarText]);
		}
    }
	return 1;
}

public LoadTeles()
{
    for (new i=0; i!=MAX_TELES_COUNT; i++)
	{
	    new teleDIR[20];
        format(teleDIR, sizeof(teleDIR), DIR_TELES, i);
        new File:handle = fopen(teleDIR, io_read);

        if(handle)
        {
            new teleInfo[300]; fread(handle, teleInfo); fclose(handle);
			new teleInfoSlot[17][128];
            for(new slotid = 0; slotid != 17; slotid++)
            {
                new slotPos = strfind(teleInfo, "|");
                strmid(teleInfoSlot[slotid], teleInfo, 0, slotPos);
                strdel(teleInfo, 0, slotPos+1);
            }
            Teles[i][PosX] = floatstr(teleInfoSlot[0]);
		    Teles[i][PosY] = floatstr(teleInfoSlot[1]);
		    Teles[i][PosZ] = floatstr(teleInfoSlot[2]);
		    Teles[i][PosZZ] = floatstr(teleInfoSlot[3]);
		    Teles[i][PickupIDGo] = strval(teleInfoSlot[4]);
		    Teles[i][World] = strval(teleInfoSlot[5]);
		    Teles[i][Interior] = strval(teleInfoSlot[6]);
		    Teles[i][Lock] = strval(teleInfoSlot[7]);
		    Teles[i][Dueno] = strval(teleInfoSlot[8]);
		    Teles[i][DuenoType] = strval(teleInfoSlot[9]);
		    Teles[i][IsBankTele] = strval(teleInfoSlot[10]);
		    Teles[i][IsHotelTele] = strval(teleInfoSlot[11]);
		    Teles[i][IsNegocioTele] = strval(teleInfoSlot[12]);
		    Teles[i][IsCasaTele] = strval(teleInfoSlot[13]);
		    Teles[i][IsLocalTele] = strval(teleInfoSlot[14]);
		    Teles[i][PrecioEntrada] = strval(teleInfoSlot[15]);
		    format(Teles[i][LugarText], 128, teleInfoSlot[16]);
		    
		    Teles[i][PickupID] = CreateTeleDynamicPickup(1239, i, Teles[i][PosX], Teles[i][PosY], Teles[i][PosZ], Teles[i][World], Teles[i][Interior]);
			SetText3DTele(i, Teles[i][LugarText]);
			
            MAX_TELES++;
        }
	}
	return 1;
}

public GetNextTeleID()
{
	for (new i=0; i!=MAX_TELES_COUNT; i++)
	{
	    if (Teles[i][PickupID] == 0) return i;
	}
	return -1;
}

public CrearTele(Float:x, Float:y, Float:z, Float:zz, worldid, interiorid)
{
	new teleid = GetNextTeleID();
	if (teleid != -1)
	{
	    Teles[teleid][PosX] = x;
	    Teles[teleid][PosY] = y;
	    Teles[teleid][PosZ] = z;
	    Teles[teleid][PosZZ] = zz;
	    Teles[teleid][PickupIDGo] = teleid + 1;
	    Teles[teleid][World] = worldid;
	    Teles[teleid][Interior] = interiorid;
	    format(Teles[teleid][LugarText], 128, "Desconocido");

	    Teles[teleid][PickupID] = CreateTeleDynamicPickup(1239, teleid, x, y, z, worldid, interiorid);
		SetText3DTele(teleid, Teles[teleid][LugarText]);
		SaveTele(teleid, false);
		
		teleid++;
		Teles[teleid][PosX] = x;
	    Teles[teleid][PosY] = y+3;
	    Teles[teleid][PosZ] = z;
	    Teles[teleid][PosZZ] = zz;
	    Teles[teleid][PickupIDGo] = teleid - 1;
	    Teles[teleid][World] = worldid;
	    Teles[teleid][Interior] = interiorid;
	    format(Teles[teleid][LugarText], 128, "Desconocido");
	    
	    Teles[teleid][PickupID] = CreateTeleDynamicPickup(1239, teleid, x, y+3, z, worldid, interiorid);
		SetText3DTele(teleid, Teles[teleid][LugarText]);
		SaveTele(teleid, false);
	    
		MAX_TELES += 2;
	    return teleid-1;
	}
	return -1;
}

public BorrarTele(teleid)
{
	new TelePath[20];
	format(TelePath, 20, DIR_TELES, teleid); fremove(TelePath);
	format(TelePath, 20, DIR_TELES, Teles[teleid][PickupIDGo]); fremove(TelePath);
	
    new pickupid = Teles[ Teles[teleid][PickupIDGo] ][PickupID];
    DestroyDynamicPickup(pickupid);
    PickupIndex[pickupid][Tipo] = PICKUP_TYPE_NINGUNO;
	PickupIndex[pickupid][Tipoid] = 0;
	
	DestroyDynamic3DTextLabel(Teles[ Teles[teleid][PickupIDGo] ][TextLabel]);
	
	pickupid = Teles[teleid][PickupID];
    DestroyDynamicPickup(pickupid);
    PickupIndex[pickupid][Tipo] = PICKUP_TYPE_NINGUNO;
	PickupIndex[pickupid][Tipoid] = 0;
	
	DestroyDynamic3DTextLabel(Teles[teleid][TextLabel]);

	Teles[ Teles[teleid][PickupIDGo] ][PosX] = 0;
	Teles[ Teles[teleid][PickupIDGo] ][PosY] = 0;
	Teles[ Teles[teleid][PickupIDGo] ][PosZ] = 0;
	Teles[ Teles[teleid][PickupIDGo] ][PosZZ] = 0;
	Teles[ Teles[teleid][PickupIDGo] ][PickupID] = 0;
	Teles[ Teles[teleid][PickupIDGo] ][PickupIDGo] = 0;
	Teles[ Teles[teleid][PickupIDGo] ][TextLabel] = INVALID_3DTEXT_ID;
	Teles[ Teles[teleid][PickupIDGo] ][World] = 0;
	Teles[ Teles[teleid][PickupIDGo] ][Interior] = 0;
	Teles[ Teles[teleid][PickupIDGo] ][Lock] = 0;
	Teles[ Teles[teleid][PickupIDGo] ][Dueno] = 0;
	Teles[ Teles[teleid][PickupIDGo] ][DuenoType] = 0;
	Teles[ Teles[teleid][PickupIDGo] ][IsBankTele] = 0;
	Teles[ Teles[teleid][PickupIDGo] ][IsHotelTele] = 0;
	Teles[ Teles[teleid][PickupIDGo] ][IsNegocioTele] = 0;
	Teles[ Teles[teleid][PickupIDGo] ][IsCasaTele] = 0;
	Teles[ Teles[teleid][PickupIDGo] ][IsLocalTele] = 0;
	Teles[ Teles[teleid][PickupIDGo] ][PrecioEntrada] = 0;
	format(Teles[ Teles[teleid][PickupIDGo] ][LugarText], 2, "");
	
 	Teles[teleid][PosX] = 0;
	Teles[teleid][PosY] = 0;
	Teles[teleid][PosZ] = 0;
	Teles[teleid][PosZZ] = 0;
	Teles[teleid][PickupID] = 0;
	Teles[teleid][PickupIDGo] = 0;
	Teles[teleid][TextLabel] = INVALID_3DTEXT_ID;
	Teles[teleid][World] = 0;
	Teles[teleid][Interior] = 0;
	Teles[teleid][Lock] = 0;
	Teles[teleid][Dueno] = 0;
	Teles[teleid][DuenoType] = 0;
	Teles[teleid][IsBankTele] = 0;
	Teles[teleid][IsHotelTele] = 0;
	Teles[teleid][IsNegocioTele] = 0;
	Teles[teleid][IsCasaTele] = 0;
	Teles[teleid][IsLocalTele] = 0;
	Teles[teleid][PrecioEntrada] = 0;
	format(Teles[teleid][LugarText], 2, "");
	
	MAX_TELES -= 2;
	return 1;
}

public CreateTeleDynamicPickup(modelid, teleid, Float:x, Float:y, Float:z, worldid, interiorid)
{
    new pickupid = CreateDynamicPickup(modelid, 1, x, y, z, worldid, interiorid);
	PickupIndex[pickupid][Tipo] = PICKUP_TYPE_TELE;
	PickupIndex[pickupid][Tipoid] = teleid;
    return pickupid;
}

public SetText3DTele(teleid, const text[])
{
	new TextLabelText[128];

	format(TextLabelText, sizeof(TextLabelText), "Lugar: {"COLOR_CREMA"}%s", ConvertToRGBColor(text));

	Teles[teleid][TextLabel] = CreateDynamic3DTextLabel(TextLabelText, 0x00A5FFFF,
		Teles[teleid][PosX], Teles[teleid][PosY], Teles[teleid][PosZ],
		10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, true, Teles[teleid][World], Teles[teleid][Interior]);
}

public PlayerHaveTeleKeys(playerid, teleid, tipo, tipoid)
{
	if (tipo == 0)
	{
	    if (tipoid == CIVIL || PlayersData[playerid][Faccion] == tipoid)
		return true;
	}
	else if (tipo == 1)
	{
	    if (IsMyBizz(playerid, tipoid, false))
	    return true;
	}
	else if (tipo == 2)
	{
	    if ( PlayersData[playerid][House] == tipoid ||
			 PlayersData[playerid][Alquiler] == tipoid ||
			 IsPlayerInHouseFriend(playerid, tipoid) != -1 )
	    return true;
	}
	else if (tipo == 3)
	{
	    if (PlayerHaveLocalKeys(playerid, tipoid)) return true;
	}
	return false;
}
