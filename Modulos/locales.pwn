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
	Nivel,
	Precio,
	Tipo,
	Seguro,
	PrecioEntrada,
	TimbreTime,
	LArmarioSeguro,
	LArmarioArma[7],
	LArmarioAmmo[7],
	Float:LArmarioChaleco,
	LArmarioDrogas,
	LArmarioGanzuas,
	LArmarioMateriales,
	LArmarioBombas,
	LRefrigeradorSeguro,
	LGavetaSeguro,
    LGavetaObjects[MAX_GUANTERA_GAVETA_SLOTS]
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
new MAX_LOCAL_ID;
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
	new query[1000], Cache:cacheid;

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
	new LlavesAmigos[125];
	for(new i=0; i != MAX_LOCAL_KEYS; i++)
    {
        new string[30];
        format(string,30,"%s,", LocalKeys[localID][i]);
        strcat(LlavesAmigos, string);
    }

	format(query, sizeof(query), "UPDATE %s SET ", DIR_LOCALES);
    strcat(query, "`PosX`='%f',`PosY`='%f',`PosZ`='%f',`PosZZ`='%f',");
    strcat(query, "`Owner`='%e',`Nivel`='%i',`Precio`='%i',`Tipo`='%i',");
    strcat(query, "`Seguro`='%i',`PrecioEntrada`='%i',`LlavesAmigos`='%e'");
    strcat(query, " WHERE ID=%i;");
    mysql_format(dataBase, query, sizeof(query), query,
		LocalData[localID][PosX],LocalData[localID][PosY], LocalData[localID][PosZ], LocalData[localID][PosZZ],
		LocalData[localID][Owner], LocalData[localID][Nivel], LocalData[localID][Precio], LocalData[localID][Tipo],
		LocalData[localID][Seguro], LocalData[localID][PrecioEntrada],
		LlavesAmigos,
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
	    //if (IsValidDynamicPickup(LocalData[localID][Pickup])) DestroyDynamicPickup(LocalData[localID][Pickup]);
	    //LocalData[localID][Pickup] = CreateDynamicPickup(LOCAL_PICKUP_MODEL, 1, LocalData[localID][PosX], LocalData[localID][PosY], LocalData[localID][PosZ], WORLD_NORMAL, 0, -1, MAX_PICKUP_DISTANCE);
	    DestroyPickup(LocalData[localID][Pickup]);
	    LocalData[localID][Pickup] = CreatePickup(LOCAL_PICKUP_MODEL, 1, LocalData[localID][PosX], LocalData[localID][PosY], LocalData[localID][PosZ], WORLD_NORMAL);

	    new LocalText[1024];
	    if (IsLocalForSale(localID))
	    {
	        format(LocalText,sizeof(LocalText), "Lugar: {"COLOR_CREMA"}Local PL-%i\n", localID+1);
	        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Tipo: {"COLOR_CREMA"}%s\n", LocalText, LocalTipoString[LocalData[localID][Tipo]-1]);
	        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Estado: {"COLOR_CREMA"}¡En Venta!\n", LocalText);
	        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Precio: {"COLOR_CREMA"}$%i\n", LocalText, LocalData[localID][Precio]);
	        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Nivel: {"COLOR_CREMA"}%i\n", LocalText, LocalData[localID][Nivel]);
	        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Use {"COLOR_ROJO"}/Comprar Local", LocalText);
	    }
	    else
	    {
	        format(LocalText,sizeof(LocalText), "Lugar: {"COLOR_CREMA"}Local PL-%i\n", localID+1);
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
	    LocalData[localID][TextLabel] = CreateDynamic3DTextLabel(LocalText, 0x00A5FFFF, LocalData[localID][PosX], LocalData[localID][PosY], LocalData[localID][PosZ], 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, true, WORLD_NORMAL, 0, -1, 20.0);
	    LocalData[localID][TextLabelIn] = CreateDynamic3DTextLabel(LocalText, 0x00A5FFFF, LocalTipo[type][PosX], LocalTipo[type][PosY], LocalTipo[type][PosZ], 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, true, localID+1, LocalTipo[type][Interior], -1, 20.0);
	}
}

public LoadLocales()
{
    //	CreateDynamicPickup(LOCAL_PICKUP_MODEL, 1, LocalTipo[0][PosX], LocalTipo[0][PosY], LocalTipo[0][PosZ], -1, 10, -1, MAX_PICKUP_DISTANCE);
    //////////////////
	LocalTipo[0][PosX] = 1539.1654;
	LocalTipo[0][PosY] = 1305.9552;
	LocalTipo[0][PosZ] = 10.8750;
	LocalTipo[0][PosZZ] = 0.0;
	LocalTipo[0][Interior] = 10;
	LocalTipo[0][Pickup] = CreatePickup(LOCAL_PICKUP_MODEL, 1, LocalTipo[0][PosX], LocalTipo[0][PosY], LocalTipo[0][PosZ], -1);
	//////////////////
	LocalTipo[1][PosX] = 1564.9307;
	LocalTipo[1][PosY] = 1301.6255;
	LocalTipo[1][PosZ] = 10.8470;
	LocalTipo[1][PosZZ] = 270.0;
	LocalTipo[1][Interior] = 11;
	LocalTipo[1][Pickup] = CreatePickup(LOCAL_PICKUP_MODEL, 1, LocalTipo[1][PosX], LocalTipo[1][PosY], LocalTipo[1][PosZ], -1);
	//////////////////
	LocalTipo[2][PosX] = 1535.2672;
	LocalTipo[2][PosY] = 1303.5206;
	LocalTipo[2][PosZ] = 10.8770;
	LocalTipo[2][PosZZ] = 270.0;
	LocalTipo[2][Interior] = 12;
	LocalTipo[2][Pickup] = CreatePickup(LOCAL_PICKUP_MODEL, 1, LocalTipo[2][PosX], LocalTipo[2][PosY], LocalTipo[2][PosZ], -1);
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
		    cache_get_value_name_float(0, "PosX", LocalData[i][PosX]);
		    cache_get_value_name_float(0, "PosY", LocalData[i][PosY]);
		    cache_get_value_name_float(0, "PosZ", LocalData[i][PosZ]);
		    cache_get_value_name_float(0, "PosZZ", LocalData[i][PosZZ]);
		    cache_get_value_name(0, "Owner", LocalData[i][Owner], MAX_PLAYER_NAME);
			cache_get_value_name_int(0, "Nivel", LocalData[i][Nivel]);
			cache_get_value_name_int(0, "Precio", LocalData[i][Precio]);
			cache_get_value_name_int(0, "Tipo", LocalData[i][Tipo]);
			cache_get_value_name_int(0, "Seguro", LocalData[i][Seguro]);
			cache_get_value_name_int(0, "PrecioEntrada", LocalData[i][PrecioEntrada]);
			new LlavesAmigos[125];cache_get_value_name(0, "LlavesAmigos", LlavesAmigos, 125);
			for(new keyid=0; keyid != MAX_LOCAL_KEYS; keyid++)
			{
			    new SplitPos = strfind(LlavesAmigos, ",");
			    strmid(LocalKeys[i][keyid], LlavesAmigos, 0, SplitPos, MAX_PLAYER_NAME);
			    strdel(LlavesAmigos, 0, SplitPos+1);
			}

			if (LocalData[i][Tipo] != 0)
			{
			    //LocalData[i][Pickup] = CreateDynamicPickup(LOCAL_PICKUP_MODEL, 1, LocalData[i][PosX], LocalData[i][PosY], LocalData[i][PosZ], WORLD_NORMAL, 0, -1, MAX_PICKUP_DISTANCE);
			    LocalData[i][Pickup] = CreatePickup(LOCAL_PICKUP_MODEL, 1, LocalData[i][PosX], LocalData[i][PosY], LocalData[i][PosZ], WORLD_NORMAL);

			    new LocalText[1024];
			    if (IsLocalForSale(i))
			    {
			        format(LocalText,sizeof(LocalText), "Lugar: {"COLOR_CREMA"}Local PL-%i\n", i+1);
			        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Tipo: {"COLOR_CREMA"}%s\n", LocalText, LocalTipoString[LocalData[i][Tipo]-1]);
			        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Estado: {"COLOR_CREMA"}¡En Venta!\n", LocalText);
			        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Precio: {"COLOR_CREMA"}$%i\n", LocalText, LocalData[i][Precio]);
			        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Nivel: {"COLOR_CREMA"}%i\n", LocalText, LocalData[i][Nivel]);
			        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Use {"COLOR_ROJO"}/Comprar Local", LocalText);
			    }
			    else
			    {
			        format(LocalText,sizeof(LocalText), "Lugar: {"COLOR_CREMA"}Local PL-%i\n", i+1);
			        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Tipo: {"COLOR_CREMA"}%s\n", LocalText, LocalTipoString[LocalData[i][Tipo]-1]);
			        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Propietario: {"COLOR_CREMA"}%s\n", LocalText, LocalData[i][Owner]);
			        if (LocalData[i][PrecioEntrada] != 0)
			        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Entrada: {"COLOR_CREMA"}$%i", LocalText, LocalData[i][PrecioEntrada]);
			        else
			        format(LocalText,sizeof(LocalText), "%s{"COLOR_VERDE"}Entrada: {"COLOR_CREMA"}Gratis", LocalText);
			    }
			    new type = LocalData[i][Tipo]-1;
			    LocalData[i][TextLabel] = CreateDynamic3DTextLabel(LocalText, 0x00A5FFFF, LocalData[i][PosX], LocalData[i][PosY], LocalData[i][PosZ], 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, true, WORLD_NORMAL, 0, -1, 20.0);
			    LocalData[i][TextLabelIn] = CreateDynamic3DTextLabel(LocalText, 0x00A5FFFF, LocalTipo[type][PosX], LocalTipo[type][PosY], LocalTipo[type][PosZ], 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, true, i+1, LocalTipo[type][Interior], -1, 20.0);
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
























