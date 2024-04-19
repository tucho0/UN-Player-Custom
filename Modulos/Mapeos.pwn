#define MAX_MAPEOS_COUNT 1000
#define MAX_MATERIALINDEX 16
#define DIR_MAPEOS "Mapeos/%i.map"
#define DIR_PUERTAS "Puertas/%i.door"

#define MAX_PUERTAS_COUNT 100

/*
SetPVarInt(playerid, "editingmapeo", mapeoid);
SetPVarInt(playerid, "editingobject", objectid);
SetPVarInt(playerid, "editingindex", mapeoid);
SetPVarInt(playerid, "editingoption", mapeoid);
SetPVarInt(playerid, "editingmovement", 1);

GetPVarInt(playerid, "editingmapeo");
GetPVarInt(playerid, "editingobject");
GetPVarInt(playerid, "editingindex");
GetPVarInt(playerid, "editingoption");
GetPVarInt(playerid, "editingmovement");

new mapeoid = GetPVarInt(playerid, "editingmapeo");
new objectid = GetPVarInt(playerid, "editingobject");
new objectid = Mapeo[mapeoid][ID_Objeto];
new indexid = GetPVarInt(playerid, "editingindex");
new option = GetPVarInt(playerid, "editingoption");
*/

enum ObjetosEnum
{
	Modelo,
	Float:PosX,
	Float:PosY,
	Float:PosZ,
	Float:PosRX,
	Float:PosRY,
	Float:PosRZ,
	Mundo,
	Interior,
	//////////
	CreatedBy[MAX_PLAYER_NAME],
	Tipo,//0: Objeto | 1: Puerta | 2: Peaje | 3: Parqueo
	Tipoid,
	//////////
	materialtype[MAX_MATERIALINDEX],//0: Default | 1: Material | 2: MaterialText
	//////////
	texturemodel[MAX_MATERIALINDEX],
	materialcolor[MAX_MATERIALINDEX],//ARGB - 0 Disables
	//////////
	materialsize[MAX_MATERIALINDEX],
	fontsize[MAX_MATERIALINDEX],//0-255
	bold[MAX_MATERIALINDEX],
	fontcolor[MAX_MATERIALINDEX],//ARGB
	backgroundcolor[MAX_MATERIALINDEX],//ARGB
	textalignment[MAX_MATERIALINDEX],//0: Left | 1: Center | 2: Right
	//////////
	ID_Objeto
};

new Mapeo[MAX_MAPEOS_COUNT][ObjetosEnum];
new MAX_MAPEOS;

new MapeoTxdName[MAX_MAPEOS_COUNT][MAX_MATERIALINDEX][30];
new MapeoTextureName[MAX_MAPEOS_COUNT][MAX_MATERIALINDEX][30];
//////////
new MapeoText[MAX_MAPEOS_COUNT][MAX_MATERIALINDEX][128];
new MapeoFont[MAX_MAPEOS_COUNT][MAX_MATERIALINDEX][40];

new IndexType[3][20] = {"{"COLOR_ROJO"}Sin Uso","{"COLOR_VERDE"}Textura","{"COLOR_AZUL"}Texto"};
new Alineacion[3][10] = {"Izquierda","Centro","Derecha"};
new MapeoType[4][10] = {"Objeto","Puerta","Peaje","Parqueo"};

enum PuertaEnum
{
    ID_Mapeo,
    Creada,
	Float:PosX,
	Float:PosY,
	Float:PosZ,
	Float:PosRX,
	Float:PosRY,
	Float:PosRZ,
	Float:Velocidad,
	Abierta,
	LlaveTipo,//0: Faccion | 1: Casa | 2: Local
	LlaveOwnerID
};

new Puerta[MAX_PUERTAS_COUNT][PuertaEnum];
new MAX_PUERTAS;

stock LoadMapeos()
{
	new
		path[30],
		objectData[500];
    for(new i=0; i != MAX_MAPEOS_COUNT; i++)
	{
	    format(path,sizeof(path), DIR_MAPEOS, i);

		new File:handle = fopen(path, io_read);

		if ( handle )
		{
		    new objectDataSlot[13][128];
		    new splitpos;

		    fread(handle, objectData);

		    for(new x=0; x <= 11; x++)//0-11 Modelo-tipoid
		    {
		        splitpos = strfind(objectData, "|");
		        strmid(objectDataSlot[x], objectData, 0, splitpos);
		        strdel(objectData, 0, splitpos+1);
		    }

		    Mapeo[i][Modelo] = strval(objectDataSlot[0]);
		    Mapeo[i][PosX] = floatstr(objectDataSlot[1]);
		    Mapeo[i][PosY] = floatstr(objectDataSlot[2]);
		    Mapeo[i][PosZ] = floatstr(objectDataSlot[3]);
		    Mapeo[i][PosRX] = floatstr(objectDataSlot[4]);
		    Mapeo[i][PosRY] = floatstr(objectDataSlot[5]);
		    Mapeo[i][PosRZ] = floatstr(objectDataSlot[6]);
		    Mapeo[i][Mundo] = strval(objectDataSlot[7]);
		    Mapeo[i][Interior] = strval(objectDataSlot[8]);
		    format(Mapeo[i][CreatedBy], MAX_PLAYER_NAME, objectDataSlot[9]);
		    Mapeo[i][Tipo] = strval(objectDataSlot[10]);
		    Mapeo[i][Tipoid] = strval(objectDataSlot[11]);

		    new objectid = CreateDynamicObject(Mapeo[i][Modelo], Mapeo[i][PosX], Mapeo[i][PosY], Mapeo[i][PosZ], Mapeo[i][PosRX], Mapeo[i][PosRY], Mapeo[i][PosRZ], Mapeo[i][Mundo], Mapeo[i][Interior]);
			Mapeo[i][ID_Objeto] = objectid;
			MAX_MAPEOS++;

			for(new indexid=0; indexid != MAX_MATERIALINDEX; indexid++)
			{
			    fread(handle, objectData);

			    for(new x=0; x <= 12; x++)//0-12 MaterialType-TextAlignment
			    {
			        splitpos = strfind(objectData, "|");
			        strmid(objectDataSlot[x], objectData, 0, splitpos);
			        strdel(objectData, 0, splitpos+1);
			    }

			    Mapeo[i][materialtype][indexid] = strval(objectDataSlot[0]);
				Mapeo[i][texturemodel][indexid] = strval(objectDataSlot[1]);
				format(MapeoTxdName[i][indexid], 80, objectDataSlot[2]);
				format(MapeoTextureName[i][indexid], 80, objectDataSlot[3]);
				Mapeo[i][materialcolor][indexid] = strval(objectDataSlot[4]);
				//////////
				format(MapeoText[i][indexid], 128, objectDataSlot[5]);
				Mapeo[i][materialsize][indexid] = strval(objectDataSlot[6]);
				format(MapeoFont[i][indexid], 80, objectDataSlot[7]);
				Mapeo[i][fontsize][indexid] = strval(objectDataSlot[8]);
				Mapeo[i][bold][indexid] = strval(objectDataSlot[9]);
				Mapeo[i][fontcolor][indexid] = strval(objectDataSlot[10]);
				Mapeo[i][backgroundcolor][indexid] = strval(objectDataSlot[11]);
				Mapeo[i][textalignment][indexid] = strval(objectDataSlot[12]);

				if (Mapeo[i][materialtype][indexid] == 1)
				{
				    SetDynamicObjectMaterial(objectid, indexid, Mapeo[i][texturemodel][indexid], MapeoTxdName[i][indexid], MapeoTextureName[i][indexid], Mapeo[i][materialcolor][indexid]);
				}
				if (Mapeo[i][materialtype][indexid] == 2)
				{
				    SetDynamicObjectMaterialText(objectid, indexid,
						ConvertToRGBColor(MapeoText[i][indexid]),
						Mapeo[i][materialsize][indexid],
						MapeoFont[i][indexid],
						Mapeo[i][fontsize][indexid],
						Mapeo[i][bold][indexid],
						Mapeo[i][fontcolor][indexid],
					    Mapeo[i][backgroundcolor][indexid],
						Mapeo[i][textalignment][indexid]);
				}
			}

		    fclose(handle);
		    
		    if (Mapeo[i][Tipo] == 1)
		    {
		        if (MAX_PUERTAS < MAX_PUERTAS_COUNT)
		        {
		            LoadPuertaMapeo(Mapeo[i][Tipoid], i);
		        }
		    }
		}
	}
}

stock LoadMapeosEx()
{
    for(new i=0; i != MAX_DOORS; i++)
	{
	    Mapeo[i][Modelo] = Doors[i][objectmodel];
	    Mapeo[i][PosX] = Doors[i][PosXTrue];
	    Mapeo[i][PosY] = Doors[i][PosYTrue];
	    Mapeo[i][PosZ] = Doors[i][PosZTrue];
	    Mapeo[i][PosRX] = Doors[i][PosRotXTrue];
	    Mapeo[i][PosRY] = Doors[i][PosRotYTrue];
	    Mapeo[i][PosRZ] = Doors[i][PosRotZTrue];
	    Mapeo[i][Mundo] = 0;
	    Mapeo[i][Interior] = 0;
	    format(Mapeo[i][CreatedBy], MAX_PLAYER_NAME, "Server");
	    Mapeo[i][Tipo] = 1;
	    Mapeo[i][Tipoid] = i;

	    new objectid = CreateDynamicObject(Mapeo[i][Modelo], Mapeo[i][PosX], Mapeo[i][PosY], Mapeo[i][PosZ], Mapeo[i][PosRX], Mapeo[i][PosRY], Mapeo[i][PosRZ], Mapeo[i][Mundo], Mapeo[i][Interior]);
		Mapeo[i][ID_Objeto] = objectid;
		MAX_MAPEOS++;

		Puerta[i][ID_Mapeo] = i;
		Puerta[i][Creada] = true;
		Puerta[i][PosX] = Doors[i][PosXFalse];
		Puerta[i][PosY] = Doors[i][PosYFalse];
		Puerta[i][PosZ] = Doors[i][PosZFalse];
		Puerta[i][PosRX] = Doors[i][PosRotXFalse];
		Puerta[i][PosRY] = Doors[i][PosRotYFalse];
		Puerta[i][PosRZ] = Doors[i][PosRotZFalse];
		Puerta[i][Velocidad] = Doors[i][speedmove];
		Puerta[i][Abierta] = false;
		Puerta[i][LlaveTipo] = 0;
		Puerta[i][LlaveOwnerID] = Doors[i][Dueno];
		MAX_PUERTAS++;
	}
}

stock LoadPuertaMapeo(id, mapeoid)
{
    new
		puertadir[30],
		datos[120];
	format(puertadir,sizeof(puertadir), DIR_PUERTAS, id);
	new File:puertafile = fopen(puertadir, io_read);
	if (puertafile)
	{
	    fread(puertafile, datos); fclose(puertafile);

		new datoSlot[11][80], splitpos;
		
		for(new slot=0; slot <= 10; slot++)
		{
		    splitpos = strfind(datos, "|", true);
		    strmid(datoSlot[slot], datos, 0, splitpos);
		    strdel(datos, 0, splitpos+1);
		}
		Puerta[id][ID_Mapeo] = strval(datoSlot[0]);
		Puerta[id][Creada] = true;
		Puerta[id][PosX] = floatstr(datoSlot[1]);
		Puerta[id][PosY] = floatstr(datoSlot[2]);
		Puerta[id][PosZ] = floatstr(datoSlot[3]);
		Puerta[id][PosRX] = floatstr(datoSlot[4]);
		Puerta[id][PosRY] = floatstr(datoSlot[5]);
		Puerta[id][PosRZ] = floatstr(datoSlot[6]);
		Puerta[id][Velocidad] = floatstr(datoSlot[7]);
		Puerta[id][Abierta] = strval(datoSlot[8]);
		Puerta[id][LlaveTipo] = strval(datoSlot[9]);
		Puerta[id][LlaveOwnerID] = strval(datoSlot[10]);
		MAX_PUERTAS++;
		
		if (Puerta[id][Abierta])
		{
		    SetDynamicObjectPos(Mapeo[Puerta[id][ID_Mapeo]][ID_Objeto], Puerta[id][PosX], Puerta[id][PosY], Puerta[id][PosZ]);
		    SetDynamicObjectRot(Mapeo[Puerta[id][ID_Mapeo]][ID_Objeto], Puerta[id][PosRX], Puerta[id][PosRY], Puerta[id][PosRZ]);
		}
	}
	else
	{
	    Mapeo[mapeoid][Tipo] = 0;
	}
}

stock SaveMapeos()
{
    new
		path[30],
		objectData[500];
	for(new i=0; i != MAX_MAPEOS_COUNT; i++)
	{
	    if (Mapeo[i][Modelo] != 0)
	    {
	        format(path,sizeof(path), DIR_MAPEOS, i);
			//////////
		    format(objectData, sizeof(objectData),
				"%i|%f|%f|%f|%f|%f|%f|%i|%i|%s|%i|%i|\n",
				Mapeo[i][Modelo],
				Mapeo[i][PosX],
				Mapeo[i][PosY],
				Mapeo[i][PosZ],
				Mapeo[i][PosRX],
				Mapeo[i][PosRY],
				Mapeo[i][PosRZ],
				Mapeo[i][Mundo],
				Mapeo[i][Interior],
				Mapeo[i][CreatedBy],
				Mapeo[i][Tipo],
				Mapeo[i][Tipoid]);

			new File:handle = fopen(path);
		    fwrite(handle, objectData);

		    for(new indexid=0; indexid != MAX_MATERIALINDEX; indexid++)
		    {
		        format(objectData, sizeof(objectData),
			        "%i|%i|%s|%s|%i|\
					%s|%i|%s|%i|%i|%i|%i|%i|\n",
					Mapeo[i][materialtype][indexid],
					Mapeo[i][texturemodel][indexid],
					MapeoTxdName[i][indexid],
					MapeoTextureName[i][indexid],
					Mapeo[i][materialcolor][indexid],
					//////////
					MapeoText[i][indexid],
					Mapeo[i][materialsize][indexid],
					MapeoFont[i][indexid],
					Mapeo[i][fontsize][indexid],
					Mapeo[i][bold][indexid],
					Mapeo[i][fontcolor][indexid],
					Mapeo[i][backgroundcolor][indexid],
					Mapeo[i][textalignment][indexid]);

				fwrite(handle, objectData);
		    }
		    fclose(handle);
		    
		    if (Mapeo[i][Tipo] == 1)
		    {
		        SavePuerta(Mapeo[i][Tipoid]);
		    }
	    }
	}
}

stock SavePuerta(id)
{
	new
		puertadir[30],
		datos[120];
	format(puertadir,sizeof(puertadir), DIR_PUERTAS, id);
	new File:puertafile = fopen(puertadir, io_write);
	format(datos, sizeof(datos), "%i|%f|%f|%f|%f|%f|%f|%f|%i|%i|%i|",
		Puerta[id][ID_Mapeo],
		Puerta[id][PosX],
		Puerta[id][PosY],
		Puerta[id][PosZ],
		Puerta[id][PosRX],
		Puerta[id][PosRY],
		Puerta[id][PosRZ],
		Puerta[id][Velocidad],
		Puerta[id][Abierta],
		Puerta[id][LlaveTipo],
		Puerta[id][LlaveOwnerID]);
	fwrite(puertafile, datos);
	fclose(puertafile);
}

stock ShowObjectMenu(playerid, tipoObjeto)
{
    new objectid = GetPVarInt(playerid, "editingobject");
	if (tipoObjeto == 1)
	{
	    new mapeoid = GetPVarInt(playerid, "editingmapeo");
	    if (Mapeo[mapeoid][ID_Objeto] == objectid && objectid != 0)
	    {
	        new string[1024], caption[100];

	        if (Mapeo[mapeoid][Tipo] == 0)//Objeto
	        {
	            format(caption, sizeof(caption), "{"COLOR_AZUL"}Objeto modelo %i (ID: %i[%i])", Mapeo[mapeoid][Modelo], Mapeo[mapeoid][ID_Objeto], mapeoid);
	            format(string, sizeof(string), "Editar\n");
			 	format(string, sizeof(string), "%sIndexs\n", string);
			 	format(string, sizeof(string), "%sDuplicar\n", string);
			 	format(string, sizeof(string), "%sCreado por: {"COLOR_AZUL"}%s\n", string, Mapeo[mapeoid][CreatedBy]);
			 	format(string, sizeof(string), "%sTipo: {"COLOR_AZUL"}%s\n \n", string, MapeoType[Mapeo[mapeoid][Tipo]]);
			 	format(string, sizeof(string), "%s{FF0000}Borrar", string);
	        }
			else if (Mapeo[mapeoid][Tipo] == 1)//Puerta
	        {
	            new puertaid = Mapeo[mapeoid][Tipoid];
	            format(caption, sizeof(caption), "{"COLOR_AZUL"}Puerta [%i] modelo %i (ID: %i[%i])", puertaid, Mapeo[mapeoid][Modelo], Mapeo[mapeoid][ID_Objeto], mapeoid);
	            format(string, sizeof(string), "Editar\n");
			 	format(string, sizeof(string), "%sIndexs\n", string);
			 	format(string, sizeof(string), "%sDuplicar\n", string);
			 	format(string, sizeof(string), "%sCreada por: {"COLOR_AZUL"}%s\n", string, Mapeo[mapeoid][CreatedBy]);
			 	format(string, sizeof(string), "%sTipo: {"COLOR_AZUL"}%s\n \n", string, MapeoType[Mapeo[mapeoid][Tipo]]);
			 	format(string, sizeof(string), "%sLlave Tipo: {"COLOR_AZUL"}%s\n", string, LlaveTipoName[Puerta[puertaid][LlaveTipo]]);
			 	if (Puerta[puertaid][LlaveTipo] == 0)
				format(string, sizeof(string), "%sLlave Faccion: {"COLOR_AZUL"}%s\n \n", string, FaccionData[Puerta[puertaid][LlaveOwnerID]][NameFaccion]);
			 	else format(string, sizeof(string), "%sLlave ID: {"COLOR_AZUL"}%i\n \n", string, Puerta[puertaid][LlaveOwnerID]);
			 	format(string, sizeof(string), "%sEditar Recorrido\n", string);
			 	format(string, sizeof(string), "%sVelocidad: {"COLOR_AZUL"}%.2f\n \n", string, Puerta[puertaid][Velocidad]);
			 	format(string, sizeof(string), "%s{FF0000}Borrar", string);
	        }
		    ShowPlayerDialogEx(playerid, 156, DIALOG_STYLE_LIST, caption, string, "Seleccionar", "Cancelar");
	    }
	}
}

stock ShowObjectIndexes(playerid)
{
	new objectid = GetPVarInt(playerid, "editingobject");
	new string[1024], caption[100];

	if (GetPVarInt(playerid, "editingmapeo") != -1)
	{
	    new mapeoid = GetPVarInt(playerid, "editingmapeo");

	    format(caption, sizeof(caption), "{0075FF}Indexs del objeto modelo %i (ID: %i[%i])", Mapeo[mapeoid][Modelo], objectid, mapeoid);

	    for( new index=0; index!=MAX_MATERIALINDEX; index++)
	    {
	        format(string, sizeof(string), "%sIndex %i: %s\n", string, index, IndexType[Mapeo[mapeoid][materialtype][index]]);
		}
	}
	ShowPlayerDialogEx(playerid, 157, DIALOG_STYLE_LIST, caption, string, "Seleccionar", "Volver");
}

stock ShowObjectIndex(playerid, indexid)
{
	new string[1024], caption[100];
	if (GetPVarInt(playerid, "editingmapeo") != -1)
	{
	    new mapeoid = GetPVarInt(playerid, "editingmapeo");

	    format(caption, sizeof(caption), "{"COLOR_AZUL"}Index %i del objeto modelo %i (ID: %i[%i])", indexid, Mapeo[mapeoid][Modelo], Mapeo[mapeoid][ID_Objeto], mapeoid);
	    format(string, sizeof(string), "{"COLOR_AZUL"}TEXTURAS\n");
	    format(string, sizeof(string), "%sModelo: {"COLOR_AZUL"}(%i)\n", string, Mapeo[mapeoid][texturemodel][indexid]);//1
	    format(string, sizeof(string), "%sTXD: {"COLOR_AZUL"}(%s)\n", string, MapeoTxdName[mapeoid][indexid]);
	    format(string, sizeof(string), "%sTextura: {"COLOR_AZUL"}(%s)\n", string, MapeoTextureName[mapeoid][indexid]);
	    format(string, sizeof(string), "%sColor: {"COLOR_AZUL"}(%i)\n \n", string, Mapeo[mapeoid][materialcolor][indexid]);//4
	    format(string, sizeof(string), "%s{"COLOR_AZUL"}TEXTO\n", string);
	    format(string, sizeof(string), "%sAsignar Texto\n", string);//7
	    format(string, sizeof(string), "%sTamaño de lienzo {"COLOR_AZUL"}(%i)\n", string, Mapeo[mapeoid][materialsize][indexid]);
	    format(string, sizeof(string), "%sCambiar Fuente {"COLOR_AZUL"}(%s)\n", string, MapeoFont[mapeoid][indexid]);
	    format(string, sizeof(string), "%sTamaño de Texto {"COLOR_AZUL"}(%i)\n", string, Mapeo[mapeoid][fontsize][indexid]);
	    format(string, sizeof(string), "%sUsar Negrita {"COLOR_AZUL"}(%i)\n", string, Mapeo[mapeoid][bold][indexid]);
	    format(string, sizeof(string), "%sColor de Texto {"COLOR_AZUL"}(%i)\n", string, Mapeo[mapeoid][fontcolor][indexid]);
	    format(string, sizeof(string), "%sColor del Fondo {"COLOR_AZUL"}(%x)\n", string, Mapeo[mapeoid][backgroundcolor][indexid]);
	    format(string, sizeof(string), "%sCambiar Alineacion {"COLOR_AZUL"}(%s)\n \n", string, Alineacion[Mapeo[mapeoid][textalignment][indexid]]);//14
	    format(string, sizeof(string), "%s{FF0000}Borrar Index", string);//16
	}
    ShowPlayerDialogEx(playerid, 158, DIALOG_STYLE_LIST, caption, string, "Seleccionar", "Volver");
}

stock ShowEditObjectMaerial(playerid, indexid, option)
{
	new string[1024], caption[100];
    //Material
    if (option == 1)//Modelo
    {
        format(caption, sizeof(caption), "{"COLOR_AZUL"}Index %i -> Modelo", indexid);
        format(string, sizeof(string), "Ingrese el ID de modeo de la textura:\n");
    }
    else if (option == 2)//TXD
    {
        format(caption, sizeof(caption), "{"COLOR_AZUL"}Index %i -> TXD", indexid);
        format(string, sizeof(string), "Ingrese el TXD de la textura:\n");
    }
    else if (option == 3)//Textura
    {
        format(caption, sizeof(caption), "{"COLOR_AZUL"}Index %i -> Textura", indexid);
        format(string, sizeof(string), "Ingrese la Textura:\n");
    }
    else if (option == 4)//Color
    {
        format(caption, sizeof(caption), "{"COLOR_AZUL"}Index %i -> Color de la textura", indexid);
        format(string, sizeof(string), "Ingrese el color en formato ARGB:\n");
    }
    //MaterialText
    else if (option == 7)//Asignar Texto
    {
        format(caption, sizeof(caption), "{"COLOR_AZUL"}Index %i -> Texto", indexid);
        format(string, sizeof(string), "Ingrese el texto:\n");
    }
    else if (option == 8)//Tamaño Lienzo
    {
        format(caption, sizeof(caption), "{"COLOR_AZUL"}Index %i -> Tamaño del Lienzo", indexid);
        format(string, sizeof(string), "Ingrese :\n");
    }
    else if (option == 9)//Fuente
    {
        format(caption, sizeof(caption), "{"COLOR_AZUL"}Index %i -> Fuente", indexid);
        format(string, sizeof(string), "Ingrese una fuente. Ejemplo: \"Arial\"\n");
    }
    else if (option == 10)//Tamaño de Texto
    {
        format(caption, sizeof(caption), "{"COLOR_AZUL"}Index %i -> Tamaño de Texto", indexid);
        format(string, sizeof(string), "Ingrese un tamaño del texto 0-255:\n");
    }
    else if (option == 12)//Color Texto
    {
        format(caption, sizeof(caption), "{"COLOR_AZUL"}Index %i -> Color del Texto", indexid);
        format(string, sizeof(string), "Ingrese el color en formato ARGB:\n");
    }
    else if (option == 13)//Color Fondo
    {
        format(caption, sizeof(caption), "{"COLOR_AZUL"}Index %i -> Color del Fondo", indexid);
        format(string, sizeof(string), "Ingrese el color en formato ARGB:\n");
    }
    ShowPlayerDialogEx(playerid, 159, DIALOG_STYLE_INPUT, caption, string, "Aceptar", "Cancelar");
}

stock ShowVelocidadObjetoMenu(playerid, mapeoid)
{
	new caption[64];
    format(caption, sizeof(caption), "{"COLOR_AZUL"}Puerta %i -> Velocidad", Mapeo[mapeoid][Tipoid]);
    ShowPlayerDialogEx(playerid, 160, DIALOG_STYLE_INPUT, caption, "Ingrese la velocidad a la que se movera la puerta:\n", "Aceptar", "Cancelar");
}

stock ShowPuertaOwnerMenu(playerid, mapeoid)
{
	new
		puertaid = Mapeo[mapeoid][Tipoid],
		caption[64],
		info[140];
    format(caption, sizeof(caption), "{"COLOR_AZUL"}Puerta %i -> %s ID", puertaid, LlaveTipoName[Puerta[puertaid][LlaveTipo]]);
    format(info, sizeof(info), "{"COLOR_CREMA"}Ingrese el ID de %s", LlaveTipoName[Puerta[puertaid][LlaveTipo]]);
	ShowPlayerDialogEx(playerid, 161, DIALOG_STYLE_INPUT, caption, info, "Aceptar", "Cancelar");
}

stock CrearMapeo(playerid, modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, worldid, interiorid)
{
	new mapeoid = GetNextMapeoID();
    new objectid = CreateDynamicObject(modelid, x, y, z, rx, ry, rz, worldid, interiorid);
	//////////
	Mapeo[mapeoid][Modelo] = modelid;
	Mapeo[mapeoid][PosX] = x;
	Mapeo[mapeoid][PosY] = y;
	Mapeo[mapeoid][PosZ] = z;
	Mapeo[mapeoid][PosRX] = rx;
	Mapeo[mapeoid][PosRY] = ry;
	Mapeo[mapeoid][PosRZ] = rz;
	Mapeo[mapeoid][Mundo] = worldid;
	Mapeo[mapeoid][Interior] = interiorid;
	format(Mapeo[mapeoid][CreatedBy], MAX_PLAYER_NAME, PlayersDataOnline[playerid][NameOnline]);
	//////////
	Mapeo[mapeoid][ID_Objeto] = objectid;
	MAX_MAPEOS++;
	return mapeoid;
}

stock GetNextMapeoID()
{
	for (new i=0; i != MAX_MAPEOS_COUNT; i++)
	{
	    if (Mapeo[i][Modelo] == 0) return i;
	}
	return -1;
}

stock DuplicarMapeo(playerid, mapeoid)
{
	new mapeoid_new = CrearMapeo(playerid, Mapeo[mapeoid][Modelo],
		Mapeo[mapeoid][PosX], Mapeo[mapeoid][PosY], Mapeo[mapeoid][PosZ],
		Mapeo[mapeoid][PosRX], Mapeo[mapeoid][PosRY], Mapeo[mapeoid][PosRZ],
		Mapeo[mapeoid][Mundo], Mapeo[mapeoid][Interior]);

	for (new indexid=0; indexid != MAX_MATERIALINDEX; indexid++)
	{
	    Mapeo[mapeoid_new][materialtype][indexid] = Mapeo[mapeoid][materialtype][indexid];
	    
	    Mapeo[mapeoid_new][texturemodel][indexid] = Mapeo[mapeoid][texturemodel][indexid];
	    format(MapeoTxdName[mapeoid_new][indexid], 30, MapeoTxdName[mapeoid][indexid]);
	    format(MapeoTextureName[mapeoid_new][indexid], 30, MapeoTextureName[mapeoid][indexid]);
	    Mapeo[mapeoid_new][materialcolor][indexid] = Mapeo[mapeoid][materialcolor][indexid];
	    
	    format(MapeoText[mapeoid_new][indexid], 128, MapeoText[mapeoid][indexid]);
	    Mapeo[mapeoid_new][materialsize][indexid] = Mapeo[mapeoid][materialsize][indexid];
	    format(MapeoFont[mapeoid_new][indexid], 40, MapeoFont[mapeoid][indexid]);
	    Mapeo[mapeoid_new][fontsize][indexid] = Mapeo[mapeoid][fontsize][indexid];
	    Mapeo[mapeoid_new][bold][indexid] = Mapeo[mapeoid][bold][indexid];
	    Mapeo[mapeoid_new][fontcolor][indexid] = Mapeo[mapeoid][fontcolor][indexid];
	    Mapeo[mapeoid_new][backgroundcolor][indexid] = Mapeo[mapeoid][backgroundcolor][indexid];
	    Mapeo[mapeoid_new][textalignment][indexid] = Mapeo[mapeoid][textalignment][indexid];
	
	    if (Mapeo[mapeoid][materialtype][indexid] == 1)
	    {
	        SetDynamicObjectMaterial(Mapeo[mapeoid_new][ID_Objeto], indexid, Mapeo[mapeoid][texturemodel][indexid], MapeoTxdName[mapeoid][indexid], MapeoTextureName[mapeoid][indexid], Mapeo[mapeoid][materialcolor][indexid]);
	    }
	    if (Mapeo[mapeoid][materialtype][indexid] == 2)
	    {
	        SetDynamicObjectMaterialText(Mapeo[mapeoid_new][ID_Objeto], indexid,
				ConvertToRGBColor(MapeoText[mapeoid][indexid]),
				Mapeo[mapeoid][materialsize][indexid],
				MapeoFont[mapeoid][indexid],
				Mapeo[mapeoid][fontsize][indexid],
				Mapeo[mapeoid][bold][indexid],
				Mapeo[mapeoid][fontcolor][indexid],
				Mapeo[mapeoid][backgroundcolor][indexid],
				Mapeo[mapeoid][textalignment][indexid]);
	    }
	}

    if (playerid != -1)
    {
        CancelEdit(playerid);
		SetPVarInt(playerid, "editingmapeo", mapeoid_new);
        SetPVarInt(playerid, "editingobject", Mapeo[mapeoid_new][ID_Objeto]);
        EditDynamicObject(playerid, Mapeo[mapeoid_new][ID_Objeto]);
        new string[144];
        format(string, sizeof(string), "Creaste un objeto modelo %i, con el ID %i[%i]", Mapeo[mapeoid_new][Modelo], Mapeo[mapeoid_new][ID_Objeto], mapeoid_new);
		SendAdviseMessage(playerid, string);
    }
}

stock DuplicarMapeoEx(playerid, mapeoid)
{
    new Float:Pos[6];
	Pos[0] = GetPVarFloat(playerid, "editingobjectX");
	Pos[1] = GetPVarFloat(playerid, "editingobjectY");
	Pos[2] = GetPVarFloat(playerid, "editingobjectZ");
	Pos[3] = GetPVarFloat(playerid, "editingobjectRX");
 	Pos[4] = GetPVarFloat(playerid, "editingobjectRY");
	Pos[5] = GetPVarFloat(playerid, "editingobjectRZ");

	Mapeo[mapeoid][PosX] = Pos[0];
	Mapeo[mapeoid][PosY] = Pos[1];
	Mapeo[mapeoid][PosZ] = Pos[2];
	Mapeo[mapeoid][PosRX] = Pos[3];
	Mapeo[mapeoid][PosRY] = Pos[4];
	Mapeo[mapeoid][PosRZ] = Pos[5];
	SetDynamicObjectPos(Mapeo[mapeoid][ID_Objeto], Pos[0], Pos[1], Pos[2]);
	SetDynamicObjectRot(Mapeo[mapeoid][ID_Objeto], Pos[3], Pos[4], Pos[5]);

	new mapeoid_new = CrearMapeo(playerid, Mapeo[mapeoid][Modelo],
		Mapeo[mapeoid][PosX], Mapeo[mapeoid][PosY], Mapeo[mapeoid][PosZ],
		Mapeo[mapeoid][PosRX], Mapeo[mapeoid][PosRY], Mapeo[mapeoid][PosRZ],
		Mapeo[mapeoid][Mundo], Mapeo[mapeoid][Interior]);
		
    for (new indexid=0; indexid != MAX_MATERIALINDEX; indexid++)
	{
	    Mapeo[mapeoid_new][materialtype][indexid] = Mapeo[mapeoid][materialtype][indexid];

	    Mapeo[mapeoid_new][texturemodel][indexid] = Mapeo[mapeoid][texturemodel][indexid];
	    format(MapeoTxdName[mapeoid_new][indexid], 30, MapeoTxdName[mapeoid][indexid]);
	    format(MapeoTextureName[mapeoid_new][indexid], 30, MapeoTextureName[mapeoid][indexid]);
	    Mapeo[mapeoid_new][materialcolor][indexid] = Mapeo[mapeoid][materialcolor][indexid];

	    format(MapeoText[mapeoid_new][indexid], 128, MapeoText[mapeoid][indexid]);
	    Mapeo[mapeoid_new][materialsize][indexid] = Mapeo[mapeoid][materialsize][indexid];
	    format(MapeoFont[mapeoid_new][indexid], 40, MapeoFont[mapeoid][indexid]);
	    Mapeo[mapeoid_new][fontsize][indexid] = Mapeo[mapeoid][fontsize][indexid];
	    Mapeo[mapeoid_new][bold][indexid] = Mapeo[mapeoid][bold][indexid];
	    Mapeo[mapeoid_new][fontcolor][indexid] = Mapeo[mapeoid][fontcolor][indexid];
	    Mapeo[mapeoid_new][backgroundcolor][indexid] = Mapeo[mapeoid][backgroundcolor][indexid];
	    Mapeo[mapeoid_new][textalignment][indexid] = Mapeo[mapeoid][textalignment][indexid];

	    if (Mapeo[mapeoid][materialtype][indexid] == 1)
	    {
	        SetDynamicObjectMaterial(Mapeo[mapeoid_new][ID_Objeto], indexid, Mapeo[mapeoid][texturemodel][indexid], MapeoTxdName[mapeoid][indexid], MapeoTextureName[mapeoid][indexid], Mapeo[mapeoid][materialcolor][indexid]);
	    }
	    if (Mapeo[mapeoid][materialtype][indexid] == 2)
	    {
	        SetDynamicObjectMaterialText(Mapeo[mapeoid_new][ID_Objeto], indexid,
				ConvertToRGBColor(MapeoText[mapeoid][indexid]),
				Mapeo[mapeoid][materialsize][indexid],
				MapeoFont[mapeoid][indexid],
				Mapeo[mapeoid][fontsize][indexid],
				Mapeo[mapeoid][bold][indexid],
				Mapeo[mapeoid][fontcolor][indexid],
				Mapeo[mapeoid][backgroundcolor][indexid],
				Mapeo[mapeoid][textalignment][indexid]);
	    }
	}

	if (playerid != -1)
    {
        CancelEdit(playerid);
		SetPVarInt(playerid, "editingmapeo", mapeoid_new);
        SetPVarInt(playerid, "editingobject", Mapeo[mapeoid_new][ID_Objeto]);
        EditDynamicObject(playerid, Mapeo[mapeoid_new][ID_Objeto]);
        new string[144];
        format(string, sizeof(string), "Creaste un objeto modelo %i, con el ID %i[%i]", Mapeo[mapeoid_new][Modelo], Mapeo[mapeoid_new][ID_Objeto], mapeoid_new);
		SendAdviseMessage(playerid, string);
    }
}

stock CambiarMapeoTipo(playerid, mapeoid)
{
	new tipoid = Mapeo[mapeoid][Tipoid];

	if (Mapeo[mapeoid][Tipo] == 1)//Puerta
	{
		new path[30];
	    format(path, 30, DIR_PUERTAS, tipoid); fremove(path);
		Puerta[tipoid][ID_Mapeo] = -1;
	    Puerta[tipoid][Creada] = false;
	    Puerta[tipoid][PosX] = 0;
	    Puerta[tipoid][Velocidad] = 0;
	    Puerta[tipoid][Abierta] = false;
	    Puerta[tipoid][LlaveTipo] = 0;
	    Puerta[tipoid][LlaveOwnerID] = 0;
	}

	Mapeo[mapeoid][Tipo] = (Mapeo[mapeoid][Tipo] == 1) ? (0) : (Mapeo[mapeoid][Tipo] + 1);

	if (Mapeo[mapeoid][Tipo] == 1)//Puerta
	{
	    tipoid = GetNextPuertaID();
	    if(tipoid == -1)
	    {
	        SendInfoMessage(playerid, 0, "", "Se Alcanzo el maximo de puertas");
	        Mapeo[mapeoid][Tipo] = 0;
	        return 1;
	    }
	    Puerta[tipoid][ID_Mapeo] = mapeoid;
	    Puerta[tipoid][Creada] = true;
	    Puerta[tipoid][Velocidad] = 1.0;
	    Puerta[tipoid][Abierta] = false;
	    SavePuerta(tipoid);

	    Mapeo[mapeoid][Tipoid] = tipoid;
	}
	return 1;
}

stock GetNextPuertaID()
{
	for(new i=0; i!=MAX_PUERTAS_COUNT; i++)
	{
	    if (!Puerta[i][Creada]) return i;
	}
	return -1;
}

stock BorrarMapeo(playerid, mapeoid)
{
	new
		objectid = Mapeo[mapeoid][ID_Objeto],
		tipo = Mapeo[mapeoid][Tipo],
		tipoid = Mapeo[mapeoid][Tipoid];
	
	for(new i=0; i!=MAX_MATERIALINDEX; i++)
    {
        BorrarObjetoIndex(playerid, 1, i);
    }
    DestroyDynamicObject(objectid);
    
    Mapeo[mapeoid][Modelo] = 0;
    format(Mapeo[mapeoid][CreatedBy], MAX_PLAYER_NAME, "");
    Mapeo[mapeoid][Tipo] = 0;
    Mapeo[mapeoid][Tipoid] = 0;
    Mapeo[mapeoid][ID_Objeto] = 0;
    MAX_MAPEOS--;

	new path[30];
    format(path, 30, DIR_MAPEOS, mapeoid);
    fremove(path);
    
	if (tipo == 1)
	{
	    format(path, 30, DIR_PUERTAS, tipoid); fremove(path);
	    Puerta[tipoid][ID_Mapeo] = -1;
	    Puerta[tipoid][Creada] = 0;
	    Puerta[tipoid][PosX] = 0;
	    Puerta[tipoid][Velocidad] = 0;
	    Puerta[tipoid][Abierta] = false;
	    Puerta[tipoid][LlaveTipo] = 0;
	    Puerta[tipoid][LlaveOwnerID] = 0;
	}
	
	if (playerid != -1)
	{
		new string[144];
		format(string, sizeof(string), "Has borrado un objeto ID %i[%i]", objectid, mapeoid);
		SendAdviseMessage(playerid, string);
		SetPVarInt(playerid, "editingmapeo", -1);
		SetPVarInt(playerid, "editingobject", false);
	}
}

stock BorrarObjetoIndex(playerid, tipo, indexid)
{
    new objectid = GetPVarInt(playerid, "editingobject");
    
	if (tipo == 1)//Mapeo
	{
		new mapeoid = GetPVarInt(playerid, "editingmapeo");
		
		Mapeo[mapeoid][materialtype][indexid] = 0;
		
	    Mapeo[mapeoid][texturemodel][indexid] = 0;
	    format(MapeoTxdName[mapeoid][indexid], 30, "");
	    format(MapeoTextureName[mapeoid][indexid], 30, "");
	    Mapeo[mapeoid][materialcolor][indexid] = 0;
	    format(MapeoText[mapeoid][indexid], 128, "");
	    Mapeo[mapeoid][materialsize][indexid] = 0;
	    format(MapeoFont[mapeoid][indexid], 40, "");
	    Mapeo[mapeoid][fontsize][indexid] = 0;
	    Mapeo[mapeoid][bold][indexid] = 0;
	    Mapeo[mapeoid][fontcolor][indexid] = 0;
	    Mapeo[mapeoid][backgroundcolor][indexid] = 0;
	    Mapeo[mapeoid][textalignment][indexid] = 0;
	}
	RemoveDynamicObjectMaterial(objectid, indexid);
	RemoveDynamicObjectMaterialText(objectid, indexid);
}






