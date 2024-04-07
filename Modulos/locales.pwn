#define MAX_LOCAL_COUNT						10
#define MAX_LOCAL_TYPE_COUNT				3
#define LOCAL_PICKUP_MODEL					19197
#define MAX_LOCAL_KEYS                  	5

forward GetNextLocalID();
forward IsLocalForSale(localID);
forward IsMyLocal(playerid, localID);
forward SaveLocal(localID, update);
forward LoadLocales();
forward IsPlayerInLocalKeys(playerid, localID);
forward AddPlayerInLocalKeys(playerid, localID);
forward RemoveLocalKey(localID, keyid);
forward ShowLocalKeys(playerid, localid);
forward PlayerHaveLocalKeys(playerid, localid);
forward AddArticleLRefrigerador(playerid, localid, bolsaid);
forward RemoveArticleLRefrigerador(playerid, localid, refrigeradorid);
forward ClearLocalData(localid);

enum LocalDataEnum
{
	Float:PosX,
	Float:PosY,
	Float:PosZ,
	Float:PosZZ,
	Pickup,
	Text3D:TextLabel,
	Text3D:TextLabelIn,
	Owner[MAX_PLAYER_NAME],
	NombreLocal[128],
	LlavesAmigos[125],
	Nivel,
	Precio,
	Tipo,
	Seguro,
	PrecioEntrada,
	Deposito,
	TimbreTime,
	LArmarioSeguro,
	LArmarioArma[7],
	LArmarioAmmo[7],
	LArmarioArmas[60],
	Float:LArmarioChaleco,
	LArmarioDrogas,
	LArmarioGanzuas,
	LArmarioMateriales,
	LArmarioBombas,
	LRefrigeradorSeguro,
	RefrigeradorData[60],
	LGavetaSeguro,
    LGavetaObjects[MAX_GUANTERA_GAVETA_SLOTS],
    LGavetaData[60]
};

enum LocalTipoData
{
    Float:PosX,
	Float:PosY,
	Float:PosZ,
	Float:PosZZ,
	Interior,
	Pickup
};

/*
if (LocalData[localid][LRefrigeradorSeguro]) return SendInfoMessage(playerid, 0, "", "El refrigerador se encuentra cerrado!");
if (LocalData[localid][LArmarioSeguro]) return SendInfoMessage(playerid, 0, "", "El armario se encuentra cerrado!");
if (LocalData[localid][LGavetaSeguro]) return SendInfoMessage(playerid, 0, "", "La gaveta se encuentra cerrada!");
if (PlayersDataOnline[playerid][InPickup] >= LocalData[0][Pickup] && PlayersDataOnline[playerid][InPickup] <= LocalData[MAX_LOCAL_ID][Pickup])
{
}
else return SendInfoMessage(playerid, 0, "", "No te encuentras en ningun local.");

				            //LocalData[localid][]
				            
else if (PlayersData[playerid][InLocal] != -1)
				        {
				            new localid = PlayersData[playerid][InLocal];
				        }
*/

new DIR_LOCALES[8] = "locales";
new LocalData[MAX_LOCAL_COUNT][LocalDataEnum];
new LocalKeys[MAX_LOCAL_COUNT][MAX_LOCAL_KEYS][MAX_PLAYER_NAME];
new LRefrigerador[MAX_LOCAL_COUNT][RefrigeradorEnum];
new MAX_LOCAL;
new MAX_LOCAL_ID = -1;
new LocalTipo[MAX_LOCAL_TYPE_COUNT][LocalTipoData];
new LocalTipoString[MAX_LOCAL_TYPE_COUNT][8] = {"Pequeño", "Mediano", "Grande"};



public GetNextLocalID()
{
    new nextLocalID = -1;
	for (new i=0; i != MAX_LOCAL_COUNT; i++)
	{
	    if (LocalData[i][Tipo] == 0)
	    {
	        nextLocalID = i;
	        break;
	    }
	}
	return nextLocalID;
}

public IsLocalForSale(localID)
{
	if (strlen(LocalData[localID][Owner]) > 2) return 0;
	else return 1;
}

public SaveLocal(localID, update)
{
	new query[2000], Cache:cacheid;

	mysql_format(dataBase, query, sizeof(query), "SELECT ID FROM %s WHERE ID=%i;", DIR_LOCALES, localID);
	cacheid = mysql_query(dataBase, query);

	new localExiste = cache_num_rows();
	cache_delete(cacheid);

	if (!localExiste)
	{
	    format(query, sizeof(query), "INSERT INTO %s (ID) VALUES ('%i');", DIR_LOCALES, localID);
		mysql_query(dataBase, query, false);
	}

	//, LocalData[localID][]
	for(new i=0; i != MAX_LOCAL_KEYS; i++)
    {
        format(LocalData[localID][LlavesAmigos], 125, "%s%s,", LocalData[localID][LlavesAmigos], LocalKeys[localID][i]);
    }
	for (new i=0; i != 7; i++)
	{
		format(LocalData[localID][LArmarioArmas], 60, "%s%i|%i,", LocalData[localID][LArmarioArmas], LocalData[localID][LArmarioArma][i], LocalData[localID][LArmarioAmmo][i]);
	}
	for (new i=0; i != MAX_REFRIGERADOR_SLOTS_COUNT; i++)
	{
		format(LocalData[localID][RefrigeradorData], 60, "%s%i|%i,", LocalData[localID][RefrigeradorData], LRefrigerador[localID][Articulo][i], LRefrigerador[localID][Cantidad][i]);
	}
	for (new i=0; i != MAX_GUANTERA_GAVETA_SLOTS; i++)
	{
		format(LocalData[localID][LGavetaData], 60, "%s%i,", LocalData[localID][LGavetaData], LocalData[localID][LGavetaObjects][i]);
	}

	format(query, sizeof(query), "UPDATE %s SET ", DIR_LOCALES);
    strcat(query, "`PosX`='%f',`PosY`='%f',`PosZ`='%f',`PosZZ`='%f',");
    strcat(query, "`Owner`='%e',`Nombre`='%e',`Nivel`='%i',`Precio`='%i',");
    strcat(query, "`Tipo`='%i',`Seguro`='%i',`PrecioEntrada`='%i',`LlavesAmigos`='%e',");
    strcat(query, "`ArmarioSeguro`='%i',`ArmarioArmas`='%s',`ArmarioChaleco`='%f',`ArmarioDrogas`='%i',");
    strcat(query, "`ArmarioGanzuas`='%i',`ArmarioMateriales`='%i',`ArmarioBombas`='%i',`RefriSeguro`='%i',");
    strcat(query, "`Refrigerador`='%s',`GavetaSeguro`='%i',`GavetaObjetos`='%s',`Deposito`='%i'");
    strcat(query, " WHERE ID=%i;");
    mysql_format(dataBase, query, sizeof(query), query,
		LocalData[localID][PosX],LocalData[localID][PosY], LocalData[localID][PosZ], LocalData[localID][PosZZ],
		LocalData[localID][Owner], LocalData[localID][NombreLocal], LocalData[localID][Nivel], LocalData[localID][Precio],
		LocalData[localID][Tipo], LocalData[localID][Seguro], LocalData[localID][PrecioEntrada], LocalData[localID][LlavesAmigos],
		LocalData[localID][LArmarioSeguro], LocalData[localID][LArmarioArmas], LocalData[localID][LArmarioChaleco], LocalData[localID][LArmarioDrogas],
		LocalData[localID][LArmarioGanzuas], LocalData[localID][LArmarioMateriales], LocalData[localID][LArmarioBombas], LocalData[localID][LRefrigeradorSeguro],
		LocalData[localID][RefrigeradorData], LocalData[localID][LGavetaSeguro], LocalData[localID][LGavetaData], LocalData[localID][Deposito],
		localID);
	mysql_query(dataBase, query, false);

	if (LocalData[localID][Tipo] == 0)
	{
	    format(query, 200, "UPDATE %s SET `Local`='-1' WHERE `Local`=%i;", DIR_USERS, localID);    mysql_query(dataBase, query, false);
	    if (localID == MAX_LOCAL_ID)
	    {
	    	format(query, 200, "DELETE FROM %s WHERE ID=%i;", DIR_LOCALES, localID);	mysql_query(dataBase, query, false);
	        MAX_LOCAL_ID = 0;
		    for (new i=0; i != MAX_LOCAL_COUNT; i++)
		    {
		        if (LocalData[i][Tipo] != 0)
		        MAX_LOCAL_ID = i;
		    }
	    }
	}

	if (update)
	{
	    new pickupid = LocalData[localID][Pickup];
	    DestroyPickupEx(pickupid);
	    PickupIndex[pickupid][Tipo] = PICKUP_TYPE_NINGUNO;

		pickupid = CreatePickupEx(LOCAL_PICKUP_MODEL, 1, LocalData[localID][PosX], LocalData[localID][PosY], LocalData[localID][PosZ], WORLD_NORMAL, 0);
	    PickupIndex[pickupid][Tipo] = PICKUP_TYPE_LOCAL;
	    PickupIndex[pickupid][Tipoid] = localID;
	    LocalData[localID][Pickup] = pickupid;
	    
	    

	    new LocalText[1024];
	    if (IsLocalForSale(localID))
	    {
	        format(LocalText,sizeof(LocalText), "%s{"COLOR_AZUL"}Lugar: {"COLOR_CREMA"}Local PL-%i\n", LocalText, localID+1);
	        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Tipo: {"COLOR_CREMA"}%s\n", LocalText, LocalTipoString[LocalData[localID][Tipo]-1]);
	        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Estado: {"COLOR_CREMA"}¡En Venta!\n", LocalText);
	        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Precio: {"COLOR_CREMA"}$%i\n", LocalText, LocalData[localID][Precio]);
	        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Nivel: {"COLOR_CREMA"}%i\n", LocalText, LocalData[localID][Nivel]);
	        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Use {"COLOR_ROJO"}/Comprar Local", LocalText);
	    }
	    else
	    {
	        if (strlen(LocalData[localID][NombreLocal]) > 2)
	        format(LocalText,sizeof(LocalText), "%s\n\n", LocalData[localID][NombreLocal]);
	        format(LocalText,sizeof(LocalText), "%s{"COLOR_AZUL"}Lugar: {"COLOR_CREMA"}Local PL-%i\n", LocalText, localID+1);
	        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Tipo: {"COLOR_CREMA"}%s\n", LocalText, LocalTipoString[LocalData[localID][Tipo]-1]);
	        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Propietario: {"COLOR_CREMA"}%s\n", LocalText, LocalData[localID][Owner]);
	        if (LocalData[localID][PrecioEntrada] != 0)
	        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Entrada: {"COLOR_CREMA"}$%i", LocalText, LocalData[localID][PrecioEntrada]);
	        else
	        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Entrada: {"COLOR_CREMA"}Gratis", LocalText);
	    }
	    new type = LocalData[localID][Tipo]-1;
	    if (IsValidDynamic3DTextLabel(LocalData[localID][TextLabel])) DestroyDynamic3DTextLabel(LocalData[localID][TextLabel]);
	    if (IsValidDynamic3DTextLabel(LocalData[localID][TextLabelIn])) DestroyDynamic3DTextLabel(LocalData[localID][TextLabelIn]);
	    LocalData[localID][TextLabel] = CreateDynamic3DTextLabel(LocalText, 0xFFFFFFFF, LocalData[localID][PosX], LocalData[localID][PosY], LocalData[localID][PosZ], 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, true, WORLD_NORMAL, 0, -1, 20.0);
	    LocalData[localID][TextLabelIn] = CreateDynamic3DTextLabel(LocalText, 0xFFFFFFFF, LocalTipo[type][PosX], LocalTipo[type][PosY], LocalTipo[type][PosZ], 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, true, localID+1, LocalTipo[type][Interior], -1, 20.0);
	}
}

public LoadLocales()
{
    //////////////////
	LocalTipo[0][PosX] = 1539.1654;
	LocalTipo[0][PosY] = 1305.9552;
	LocalTipo[0][PosZ] = 10.8750;
	LocalTipo[0][PosZZ] = 0.0;
	LocalTipo[0][Interior] = 10;
	LocalTipo[0][Pickup] = CreatePickupEx(LOCAL_PICKUP_MODEL, 1, LocalTipo[0][PosX], LocalTipo[0][PosY], LocalTipo[0][PosZ], -1, 10);
	PickupIndex[LocalTipo[0][Pickup]][Tipo] = PICKUP_TYPE_LOCAL_TYPE;
	PickupIndex[LocalTipo[0][Pickup]][Tipoid] = 0;
	//////////////////
	LocalTipo[1][PosX] = 1564.9307;
	LocalTipo[1][PosY] = 1301.6255;
	LocalTipo[1][PosZ] = 10.8470;
	LocalTipo[1][PosZZ] = 270.0;
	LocalTipo[1][Interior] = 11;
	LocalTipo[1][Pickup] = CreatePickupEx(LOCAL_PICKUP_MODEL, 1, LocalTipo[1][PosX], LocalTipo[1][PosY], LocalTipo[1][PosZ], -1, 11);
	PickupIndex[LocalTipo[1][Pickup]][Tipo] = PICKUP_TYPE_LOCAL_TYPE;
	PickupIndex[LocalTipo[1][Pickup]][Tipoid] = 1;
	//////////////////
	LocalTipo[2][PosX] = 1535.2672;
	LocalTipo[2][PosY] = 1303.5206;
	LocalTipo[2][PosZ] = 10.8770;
	LocalTipo[2][PosZZ] = 270.0;
	LocalTipo[2][Interior] = 12;
	LocalTipo[2][Pickup] = CreatePickupEx(LOCAL_PICKUP_MODEL, 1, LocalTipo[2][PosX], LocalTipo[2][PosY], LocalTipo[2][PosZ], -1, 12);
	PickupIndex[LocalTipo[2][Pickup]][Tipo] = PICKUP_TYPE_LOCAL_TYPE;
	PickupIndex[LocalTipo[2][Pickup]][Tipoid] = 2;
	//////////////////

	for (new i=0; i != MAX_LOCAL_COUNT; i++)
	{
	    new query[500], Cache:cacheid;
		mysql_format(dataBase, query, sizeof(query), "SELECT * FROM %s WHERE ID=%i;", DIR_LOCALES, i);
		cacheid = mysql_query(dataBase, query);

		new localExiste = cache_num_rows();
		if (localExiste)
		{
		    //LocalData[i][]
		    new SplitPos[2];
		    cache_get_value_name_float(0, "PosX", LocalData[i][PosX]);
		    cache_get_value_name_float(0, "PosY", LocalData[i][PosY]);
		    cache_get_value_name_float(0, "PosZ", LocalData[i][PosZ]);
		    cache_get_value_name_float(0, "PosZZ", LocalData[i][PosZZ]);
		    cache_get_value_name(0, "Owner", LocalData[i][Owner], MAX_PLAYER_NAME);
		    cache_get_value_name(0, "Nombre", LocalData[i][NombreLocal], 128);
			cache_get_value_name_int(0, "Nivel", LocalData[i][Nivel]);
			cache_get_value_name_int(0, "Precio", LocalData[i][Precio]);
			cache_get_value_name_int(0, "Tipo", LocalData[i][Tipo]);
			cache_get_value_name_int(0, "Seguro", LocalData[i][Seguro]);
			cache_get_value_name_int(0, "PrecioEntrada", LocalData[i][PrecioEntrada]);
			cache_get_value_name(0, "LlavesAmigos", LocalData[i][LlavesAmigos], 125);
			cache_get_value_name_int(0, "ArmarioSeguro", LocalData[i][LArmarioSeguro]);
			cache_get_value_name(0, "ArmarioArmas", LocalData[i][LArmarioArmas], 60);
			cache_get_value_name_float(0, "ArmarioChaleco", LocalData[i][LArmarioChaleco]);
			cache_get_value_name_int(0, "ArmarioDrogas", LocalData[i][LArmarioDrogas]);
			cache_get_value_name_int(0, "ArmarioGanzuas", LocalData[i][LArmarioGanzuas]);
			cache_get_value_name_int(0, "ArmarioMateriales", LocalData[i][LArmarioMateriales]);
			cache_get_value_name_int(0, "ArmarioBombas", LocalData[i][LArmarioBombas]);
			cache_get_value_name_int(0, "RefriSeguro", LocalData[i][LRefrigeradorSeguro]);
			cache_get_value_name(0, "Refrigerador", LocalData[i][RefrigeradorData], 60);
			cache_get_value_name_int(0, "GavetaSeguro", LocalData[i][LGavetaSeguro]);
			cache_get_value_name(0, "GavetaObjetos", LocalData[i][LGavetaData], 60);
			cache_get_value_name_int(0, "Deposito", LocalData[i][Deposito]);
			//LlavesAmigos - LlavesAmigos
			for(new keyid=0; keyid != MAX_LOCAL_KEYS; keyid++)
			{
			    SplitPos[0] = strfind(LocalData[i][LlavesAmigos], ",");
			    strmid(LocalKeys[i][keyid], LocalData[i][LlavesAmigos], 0, SplitPos[0], MAX_PLAYER_NAME);
			    strdel(LocalData[i][LlavesAmigos], 0, SplitPos[0]+1);
			}
			//ArmarioArmas - LArmarioArmas
			for (new x=0; x != 7; x++)
			{
			    new Arma[3], Balas[6];
			    SplitPos[0] = strfind(LocalData[i][LArmarioArmas], "|");
			    SplitPos[1] = strfind(LocalData[i][LArmarioArmas], ",");
			    strmid(Arma, LocalData[i][LArmarioArmas], 0, SplitPos[0], 3);
			    strmid(Balas, LocalData[i][LArmarioArmas], SplitPos[0]+1, SplitPos[1], 6);
			    strdel(LocalData[i][LArmarioArmas], 0, SplitPos[1]+1);
			    
				LocalData[i][LArmarioArma][x] = strval(Arma);
				LocalData[i][LArmarioAmmo][x] = strval(Balas);
			}
			//Refrigerador - RefrigeradorData
			for (new x=0; x != MAX_REFRIGERADOR_SLOTS_COUNT; x++)
			{
			    new RefrigeradorDataPart[2][10];
			    SplitPos[0] = strfind(LocalData[i][RefrigeradorData], "|");
			    SplitPos[1] = strfind(LocalData[i][RefrigeradorData], ",");
			    strmid(RefrigeradorDataPart[0], LocalData[i][RefrigeradorData], 0, SplitPos[0], 10);
			    strmid(RefrigeradorDataPart[1], LocalData[i][RefrigeradorData], SplitPos[0]+1, SplitPos[1], 10);
			    strdel(LocalData[i][RefrigeradorData], 0, SplitPos[1]+1);

				LRefrigerador[i][Articulo][x] = strval(RefrigeradorDataPart[0]);
				LRefrigerador[i][Cantidad][x] = strval(RefrigeradorDataPart[1]);
			}
			//GavetaObjetos - LGavetaData
			for (new g=0; g != MAX_GUANTERA_GAVETA_SLOTS; g++)
			{
			    new GavetaDataPart[8];
			    SplitPos[0] = strfind(LocalData[i][LGavetaData], ",");
			    strmid(GavetaDataPart, LocalData[i][LGavetaData], 0, SplitPos[0], 8);
			    strdel(LocalData[i][LGavetaData], 0, SplitPos[0]+1);
			    
				LocalData[i][LGavetaObjects][g] = strval(GavetaDataPart);
			}

			if (LocalData[i][Tipo] != 0)
			{
			    new pickupid = CreatePickupEx(LOCAL_PICKUP_MODEL, 1, LocalData[i][PosX], LocalData[i][PosY], LocalData[i][PosZ], WORLD_NORMAL, 0);
			    PickupIndex[pickupid][Tipo] = PICKUP_TYPE_LOCAL;
			    PickupIndex[pickupid][Tipoid] = i;
			    LocalData[i][Pickup] = pickupid;

			    new LocalText[1024];
			    if (IsLocalForSale(i))
			    {
			        format(LocalText,sizeof(LocalText), "{"COLOR_AZUL"}Lugar: {"COLOR_CREMA"}Local PL-%i\n", i+1);
			        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Tipo: {"COLOR_CREMA"}%s\n", LocalText, LocalTipoString[LocalData[i][Tipo]-1]);
			        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Estado: {"COLOR_CREMA"}¡En Venta!\n", LocalText);
			        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Precio: {"COLOR_CREMA"}$%i\n", LocalText, LocalData[i][Precio]);
			        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Nivel: {"COLOR_CREMA"}%i\n", LocalText, LocalData[i][Nivel]);
			        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Use {"COLOR_ROJO"}/Comprar Local", LocalText);
			    }
			    else
			    {
			        if (strlen(LocalData[i][NombreLocal]) > 2)
			        format(LocalText,sizeof(LocalText), "%s\n\n", LocalData[i][NombreLocal]);
			        format(LocalText,sizeof(LocalText), "%s{"COLOR_AZUL"}Lugar: {"COLOR_CREMA"}Local PL-%i\n", LocalText, i+1);
			        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Tipo: {"COLOR_CREMA"}%s\n", LocalText, LocalTipoString[LocalData[i][Tipo]-1]);
			        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Propietario: {"COLOR_CREMA"}%s\n", LocalText, LocalData[i][Owner]);
			        if (LocalData[i][PrecioEntrada] != 0)
			        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Entrada: {"COLOR_CREMA"}$%i", LocalText, LocalData[i][PrecioEntrada]);
			        else
			        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Entrada: {"COLOR_CREMA"}Gratis", LocalText);
			    }
			    new type = LocalData[i][Tipo]-1;
			    LocalData[i][TextLabel] = CreateDynamic3DTextLabel(LocalText, 0xFFFFFFFF, LocalData[i][PosX], LocalData[i][PosY], LocalData[i][PosZ], 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, true, WORLD_NORMAL, 0, -1, 20.0);
			    LocalData[i][TextLabelIn] = CreateDynamic3DTextLabel(LocalText, 0xFFFFFFFF, LocalTipo[type][PosX], LocalTipo[type][PosY], LocalTipo[type][PosZ], 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, true, i+1, LocalTipo[type][Interior], -1, 20.0);
			    MAX_LOCAL++;
			    MAX_LOCAL_ID = i;
			}
		}
		cache_delete(cacheid);
	}
	return 1;
}

public IsPlayerInLocalKeys(playerid, localID)
{
	for (new i=0; i != MAX_LOCAL_KEYS; i++)
	{
	    if (strfind(LocalKeys[localID][i], PlayersDataOnline[playerid][NameOnline]) == 0 && strlen(LocalKeys[localID][i]) == strlen(PlayersDataOnline[playerid][NameOnline]))
		{
		    return true;
		}
	}
	return false;
}

public AddPlayerInLocalKeys(playerid, localID)
{
	new FreeLocalKey = false;
	for (new i=0; i != MAX_LOCAL_KEYS; i++)
	{
	    if (strlen(LocalKeys[localID][i]) <= 5)
		{
		    format(LocalKeys[localID][i], MAX_PLAYER_NAME, "%s", PlayersDataOnline[playerid][NameOnline]);
		    FreeLocalKey = true;
		    break;
		}
	}
	return FreeLocalKey;
}

public RemoveLocalKey(localID, keyid)
{
	if (strlen(LocalKeys[localID][keyid]) > 5)
	{
	    format(LocalKeys[localID][keyid], MAX_PLAYER_NAME, "Nadie");
	    return true;
	}
	return false;
}

public ShowLocalKeys(playerid, localid)
{
	new keysInfo[200];//~165
	for (new i=0; i != MAX_LOCAL_KEYS; i++)
	{
	    if (strlen(LocalKeys[localid][i]) > 5)
	    format(keysInfo, sizeof(keysInfo), "%s{"COLOR_VERDE"}Llave %i: {"COLOR_AZUL"}%s\n", keysInfo, i, LocalKeys[localid][i]);
	    else
	    format(keysInfo, sizeof(keysInfo), "%s{"COLOR_VERDE"}Llave %i: {"COLOR_ROJO"}Nadie\n", keysInfo, i);
	}
	ShowPlayerDialogEx(playerid, 154, DIALOG_STYLE_LIST, "{"COLOR_AZUL"}Local - Copias de llave", keysInfo, "Quitar", "Cerrar");
}

public PlayerHaveLocalKeys(playerid, localid)
{
	if (PlayersData[playerid][Local] == localid) return true;
	else if (IsPlayerInLocalKeys(playerid, localid)) return true;
	else return false;
}

public AddArticleLRefrigerador(playerid, localid, bolsaid)
{
    if ( PlayersData[playerid][HaveBolsa] )
	{
		if ( bolsaid > 0 && bolsaid  < 5 )
		{
		    bolsaid--;
			if ( PlayersData[playerid][Bolsa][bolsaid] )
			{
				for(new i = 0; i<MAX_REFRIGERADOR_SLOTS_COUNT; i++)
				{
				    if (!LRefrigerador[localid][Articulo][i])
				    {
						new MsgGiveArticle[MAX_TEXT_CHAT];
						new MsgGiveArticleME[MAX_TEXT_CHAT];
				        format(MsgGiveArticle, sizeof(MsgGiveArticle), "deja %s en el refrigerador", Articulos[PlayersData[playerid][Bolsa][bolsaid]][NameA]);
				        format(MsgGiveArticleME, sizeof(MsgGiveArticleME), "has dejado %i %s del refrigerador.", PlayersData[playerid][BolsaC][bolsaid], Articulos[PlayersData[playerid][Bolsa][bolsaid]][NameA]);
				        Acciones(playerid, 8, MsgGiveArticle);
				        SendInfoMessage(playerid, 2, "0", MsgGiveArticleME);

				        LRefrigerador[localid][Articulo][i] = PlayersData[playerid][Bolsa][bolsaid];
				        LRefrigerador[localid][Cantidad][i] += PlayersData[playerid][BolsaC][bolsaid];
				        RemoveArticuloBolsa(playerid, bolsaid);
						return true;
					}
				}
				return -1;
			}
			else
			{
				SendInfoMessage(playerid, 0, "1249", "No tienes nada en esa parte de la bolsa!");
			}
		}
		else
		{
			SendInfoMessage(playerid, 0, "1253", "El número de Slot de bolsa debe estar comprendido entre 1 y 4");
		}
	}
	else
	{
		SendInfoMessage(playerid, 0, "1248", "Usted no tiene bolsa!");
	}
	return false;
}

public RemoveArticleLRefrigerador(playerid, localid, refrigeradorid)
{
	if ( PlayersData[playerid][HaveBolsa] )
	{
		if ( refrigeradorid > 0 && refrigeradorid  < 11 )
		{
		    refrigeradorid--;
		    if ( LRefrigerador[localid][Articulo][refrigeradorid] )
		    {
			    switch (AddArticuloBolsa(playerid, LRefrigerador[localid][Articulo][refrigeradorid], LRefrigerador[localid][Cantidad][refrigeradorid]))
			    {
			        case 0:
			        {
						SendInfoMessage(playerid, 0, "1246", "La bolsa se encuentra llena!");
					}
					case 1:
					{
						new MsgGiveArticle[MAX_TEXT_CHAT];
						new MsgGiveArticleME[MAX_TEXT_CHAT];
				        format(MsgGiveArticle, sizeof(MsgGiveArticle), "coge %s del refrigerador", Articulos[LRefrigerador[localid][Articulo][refrigeradorid]][NameA]);
				        format(MsgGiveArticleME, sizeof(MsgGiveArticleME), "has cogido %i %s del refrigerador.", LRefrigerador[localid][Cantidad][refrigeradorid], Articulos[LRefrigerador[localid][Articulo][refrigeradorid]][NameA]);
				        Acciones(playerid, 8, MsgGiveArticle);
				        SendInfoMessage(playerid, 2, "0", MsgGiveArticleME);

					    LRefrigerador[localid][Articulo][refrigeradorid] = false;
						LRefrigerador[localid][Cantidad][refrigeradorid] = 0;
					}
					case 2:
					{
		   				SendInfoMessage(playerid, 0, "1245", "No te caben más de esos artículos en la bolsa!");
					}
				}
			}
			else
			{
				SendInfoMessage(playerid, 0, "1254", "No hay nada en esa parte del refrigerador!");
			}
		}
		else
		{
			SendInfoMessage(playerid, 0, "1258", "El número de Slot del refrigerador debe estar comprendido entre 1 y 10");
		}
	}
	else
	{
		SendInfoMessage(playerid, 0, "1247", "Usted no tiene bolsa!");
	}
}

public ClearLocalData(localid)
{
    LocalData[localid][PosX] = 0;
    LocalData[localid][PosY] = 0;
    LocalData[localid][PosZ] = 0;
    LocalData[localid][PosZZ] = 0;
    format(LocalData[localid][Owner], MAX_PLAYER_NAME,"No");
    format(LocalData[localid][NombreLocal], 128, "");
    LocalData[localid][Nivel] = 0;
    LocalData[localid][Precio] = 0;
    LocalData[localid][Tipo] = 0;
    LocalData[localid][Seguro] = true;
    LocalData[localid][PrecioEntrada] = 0;
    LocalData[localid][Deposito] = 0;
    LocalData[localid][Pickup] = 0;
    LocalData[localid][TextLabel] = Text3D:INVALID_3DTEXT_ID;
	LocalData[localid][TextLabelIn] = Text3D:INVALID_3DTEXT_ID;
	LocalData[localid][LArmarioSeguro] = true;
	for(new i=0; i!=7; i++){
	LocalData[localid][LArmarioArma][i] = 0;
	LocalData[localid][LArmarioAmmo][i] = 0;}
	LocalData[localid][LArmarioChaleco] = 0;
	LocalData[localid][LArmarioDrogas] = 0;
	LocalData[localid][LArmarioGanzuas] = 0;
	LocalData[localid][LArmarioMateriales] = 0;
	LocalData[localid][LArmarioBombas] = 0;
	LocalData[localid][LRefrigeradorSeguro] = true;
	for(new r=0; r!=MAX_REFRIGERADOR_SLOTS_COUNT; r++){
	LRefrigerador[localid][Articulo][r] = 0;
	LRefrigerador[localid][Cantidad][r] = 0;}
	LocalData[localid][LGavetaSeguro] = true;
	for(new g=0; g!=MAX_GUANTERA_GAVETA_SLOTS; g++)
	LocalData[localid][LGavetaObjects][g] = 0;
}

















