#define MAX_MAPEOS_COUNT 1000
#define MAX_PUERTAS_COUNT 100
#define MAX_PEAJES_COUNT 10
#define MAX_PARQUEOS_COUNT 10
#define MAX_MATERIALINDEX 16
#define DIR_MAPEOS "Mapeos/%i.map"
#define DIR_PUERTAS "Puertas/%i.door"
#define DIR_PEAJES "Peajes/%i.toll"
#define DIR_PARQUEOS "Parqueos/%i.ini"
#define MAPEO_TYPE_OBJETO 0
#define MAPEO_TYPE_PUERTA 1
#define MAPEO_TYPE_PEAJE 2
#define MAPEO_TYPE_PARQUEO 3
#define EDITING_TYPE_MAPEO 1

/*
PlayersDataOnline[playerid][EditingType]
PlayersDataOnline[playerid][EditingMapeo]
PlayersDataOnline[playerid][EditingObjectID]
PlayersDataOnline[playerid][EditingIndex]
PlayersDataOnline[playerid][EditingOption]
PlayersDataOnline[playerid][EditingMovement]

new mapeoid = PlayersDataOnline[playerid][EditingMapeo];
new objectid = PlayersDataOnline[playerid][EditingObjectID];
new objectid = Mapeo[mapeoid][ID_Objeto];
new indexid = PlayersDataOnline[playerid][EditingIndex];
new option = PlayersDataOnline[playerid][EditingOption];
*/

forward LoadPeaje(peajeid, mapeoid);
forward LoadPuertaMapeo(id, mapeoid);
forward LoadMapeos();
forward ShowMapeoTypeDialog(playerid);
forward LoadParqueo(parqueoid, mapeoid);
forward SaveParqueo(parqueoid);
forward ShowMapeoPropiedades(playerid, mapeoid);
forward ShowMapeoPropiedadChange(playerid, mapeoid, option);

forward BorrarPuerta(puertaid);
forward BorrarPeaje(peajeid);
forward BorrarParqueo(parqueoid);

forward CrearPuerta(mapeoid);
forward CrearPeaje(mapeoid);
forward CrearParqueo(mapeoid);

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

enum PeajesParqueoEnum
{
	ID_Mapeo,
	Creado,
	Float:PosXFalse,
	Float:PosYFalse,
	Float:PosZFalse,
	Float:PosRotXFalse,
	Float:PosRotYFalse,
	Float:PosRotZFalse,
	Float:PosCommandX,
	Float:PosCommandY,
	Float:PosCommandZ,
	Float:Velocidad,
	Abierto
};

new Peajes[MAX_PEAJES_COUNT][PeajesParqueoEnum];
new MAX_PEAJES;
new PRECIO_PEAJE = 10;
/*
enum ParqueosEnum
{
    ID_Mapeo,
	Creado,
	Float:PosXFalse,
	Float:PosYFalse,
	Float:PosZFalse,
	Float:PosRotXFalse,
	Float:PosRotYFalse,
	Float:PosRotZFalse,
	Float:Velocidad,
	Abierto
};
*/
new Parqueo[MAX_PARQUEOS_COUNT][PeajesParqueoEnum];
new MAX_PARQUEOS;

public LoadMapeos()
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
		    
		    if (Mapeo[i][Tipo] == MAPEO_TYPE_PUERTA)
		    {
		        if (MAX_PUERTAS < MAX_PUERTAS_COUNT)
		        {
		            LoadPuertaMapeo(Mapeo[i][Tipoid], i);
		        }
		    }
		    else if (Mapeo[i][Tipo] == MAPEO_TYPE_PEAJE)
		    {
		        if (MAX_PEAJES < MAX_PEAJES_COUNT)
		        {
		            LoadPeaje(Mapeo[i][Tipoid], i);
		        }
		    }
		    else if (Mapeo[i][Tipo] == MAPEO_TYPE_PARQUEO)
		    {
		        if (MAX_PARQUEOS < MAX_PARQUEOS_COUNT)
		        {
		            LoadParqueo(Mapeo[i][Tipoid], i);
		        }
		    }
		}
	}
}

public LoadPeaje(peajeid, mapeoid)
{
	new
		datos[120],
		peajeDir[30];
	format(peajeDir, 30, DIR_PEAJES, peajeid);
	new File:peajeFile = fopen(peajeDir, io_read);

	if(peajeFile)
	{
	    fread(peajeFile, datos); fclose(peajeFile);

	    new datoPeaje[11][30], splitpos;
	    for(new x=0; x!=11; x++)
	    {
	        splitpos = strfind(datos, "|", true);
	        strmid(datoPeaje[x], datos, 0, splitpos);
	        strdel(datos, 0, splitpos+1);
	    }
	    Peajes[peajeid][ID_Mapeo] = strval(datoPeaje[0]);
	    Peajes[peajeid][Creado] = true;
	    Peajes[peajeid][PosXFalse] = floatstr(datoPeaje[1]);
	    Peajes[peajeid][PosYFalse] = floatstr(datoPeaje[2]);
	    Peajes[peajeid][PosZFalse] = floatstr(datoPeaje[3]);
	    Peajes[peajeid][PosRotXFalse] = floatstr(datoPeaje[4]);
	    Peajes[peajeid][PosRotYFalse] = floatstr(datoPeaje[5]);
	    Peajes[peajeid][PosRotZFalse] = floatstr(datoPeaje[6]);
	    Peajes[peajeid][PosCommandX] = floatstr(datoPeaje[7]);
	    Peajes[peajeid][PosCommandY] = floatstr(datoPeaje[8]);
	    Peajes[peajeid][PosCommandZ] = floatstr(datoPeaje[9]);
	    Peajes[peajeid][Velocidad] = floatstr(datoPeaje[10]);
			
	    MAX_PEAJES++;
	}
	else
	{
	    Mapeo[mapeoid][Tipo] = MAPEO_TYPE_OBJETO;
	}
}

public LoadParqueo(parqueoid, mapeoid)
{
    new
		datos[120],
		parqueoDir[30];
	format(parqueoDir, 30, DIR_PARQUEOS, parqueoid);
	new File:parqueoFile = fopen(parqueoDir, io_read);
	if (parqueoFile)
	{
	    fread(parqueoFile, datos); fclose(parqueoFile);

	    new datoParqueo[8][30], splitpos;
	    for(new x=0; x!=8; x++)
	    {
	        splitpos = strfind(datos, "|", true);
	        strmid(datoParqueo[x], datos, 0, splitpos);
	        strdel(datos, 0, splitpos+1);
	    }
     	Parqueo[parqueoid][ID_Mapeo] = strval(datoParqueo[0]);
     	Parqueo[parqueoid][Creado] = true;
     	Parqueo[parqueoid][PosXFalse] = floatstr(datoParqueo[1]);
     	Parqueo[parqueoid][PosYFalse] = floatstr(datoParqueo[2]);
     	Parqueo[parqueoid][PosZFalse] = floatstr(datoParqueo[3]);
     	Parqueo[parqueoid][PosRotXFalse] = floatstr(datoParqueo[4]);
     	Parqueo[parqueoid][PosRotYFalse] = floatstr(datoParqueo[5]);
     	Parqueo[parqueoid][PosRotZFalse] = floatstr(datoParqueo[6]);
     	Parqueo[parqueoid][Velocidad] = floatstr(datoParqueo[7]);
     	Parqueo[parqueoid][Abierto] = false;
	    
	    MAX_PARQUEOS++;
	}
	else
	{
	    Mapeo[mapeoid][Tipo] = MAPEO_TYPE_OBJETO;
	}
	return 1;
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

public LoadPuertaMapeo(id, mapeoid)
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
	    Mapeo[mapeoid][Tipo] = MAPEO_TYPE_OBJETO;
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
		    
		    if (Mapeo[i][Tipo] == MAPEO_TYPE_PUERTA)
		    {
		        SavePuerta(Mapeo[i][Tipoid]);
		    }
		    else if(Mapeo[i][Tipo] == MAPEO_TYPE_PEAJE)
		    {
		        SavePeaje(Mapeo[i][Tipoid]);
		    }
		    else if(Mapeo[i][Tipo] == MAPEO_TYPE_PARQUEO)
		    {
		        SaveParqueo(Mapeo[i][Tipoid]);
		    }
	    }
	}
}

stock SaveMapeo(mapeoid)
{
    new
		path[30],
		objectData[500];
    if (Mapeo[mapeoid][Modelo] != 0)
    {
        format(path,sizeof(path), DIR_MAPEOS, mapeoid);
		//////////
	    format(objectData, sizeof(objectData),
			"%i|%f|%f|%f|%f|%f|%f|%i|%i|%s|%i|%i|\n",
			Mapeo[mapeoid][Modelo],
			Mapeo[mapeoid][PosX],
			Mapeo[mapeoid][PosY],
			Mapeo[mapeoid][PosZ],
			Mapeo[mapeoid][PosRX],
			Mapeo[mapeoid][PosRY],
			Mapeo[mapeoid][PosRZ],
			Mapeo[mapeoid][Mundo],
			Mapeo[mapeoid][Interior],
			Mapeo[mapeoid][CreatedBy],
			Mapeo[mapeoid][Tipo],
			Mapeo[mapeoid][Tipoid]);

		new File:handle = fopen(path);
	    fwrite(handle, objectData);

	    for(new indexid=0; indexid != MAX_MATERIALINDEX; indexid++)
	    {
	        format(objectData, sizeof(objectData),
		        "%i|%i|%s|%s|%i|\
				%s|%i|%s|%i|%i|%i|%i|%i|\n",
				Mapeo[mapeoid][materialtype][indexid],
				Mapeo[mapeoid][texturemodel][indexid],
				MapeoTxdName[mapeoid][indexid],
				MapeoTextureName[mapeoid][indexid],
				Mapeo[mapeoid][materialcolor][indexid],
				//////////
				MapeoText[mapeoid][indexid],
				Mapeo[mapeoid][materialsize][indexid],
				MapeoFont[mapeoid][indexid],
				Mapeo[mapeoid][fontsize][indexid],
				Mapeo[mapeoid][bold][indexid],
				Mapeo[mapeoid][fontcolor][indexid],
				Mapeo[mapeoid][backgroundcolor][indexid],
				Mapeo[mapeoid][textalignment][indexid]);

			fwrite(handle, objectData);
	    }
	    fclose(handle);

	    if (Mapeo[mapeoid][Tipo] == MAPEO_TYPE_PUERTA)
	    {
	        SavePuerta(Mapeo[mapeoid][Tipoid]);
	    }
	    else if(Mapeo[mapeoid][Tipo] == MAPEO_TYPE_PEAJE)
	    {
	        SavePeaje(Mapeo[mapeoid][Tipoid]);
	    }
	    else if(Mapeo[mapeoid][Tipo] == MAPEO_TYPE_PARQUEO)
	    {
	        SaveParqueo(Mapeo[mapeoid][Tipoid]);
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

stock SavePeaje(peajeid)
{
	new
		datos[120],
		peajeDir[30];
	format(peajeDir, 30, DIR_PEAJES, peajeid);
	new File:peajeFile = fopen(peajeDir, io_write);
	format(datos, sizeof(datos), "%i|%f|%f|%f|%f|%f|%f|%f|%f|%f|%f|",
	    Peajes[peajeid][ID_Mapeo],
	    Peajes[peajeid][PosXFalse],
	    Peajes[peajeid][PosYFalse],
	    Peajes[peajeid][PosZFalse],
	    Peajes[peajeid][PosRotXFalse],
	    Peajes[peajeid][PosRotYFalse],
	    Peajes[peajeid][PosRotZFalse],
	    Peajes[peajeid][PosCommandX],
	    Peajes[peajeid][PosCommandY],
	    Peajes[peajeid][PosCommandZ],
	    Peajes[peajeid][Velocidad]);
	    
	fwrite(peajeFile, datos);
	fclose(peajeFile);
}

stock ShowObjectMenu(playerid, tipoObjeto)
{
    new objectid = PlayersDataOnline[playerid][EditingObjectID];
	if (tipoObjeto == EDITING_TYPE_MAPEO)
	{
	    new mapeoid = PlayersDataOnline[playerid][EditingMapeo];
	    if (Mapeo[mapeoid][ID_Objeto] == objectid && objectid != 0)
	    {
	        new string[1024], caption[100];

	        if (Mapeo[mapeoid][Tipo] == MAPEO_TYPE_OBJETO)//Objeto
	        {
	            format(caption, sizeof(caption), "{"COLOR_AZUL"}Objeto modelo %i (ID: %i[%i])", Mapeo[mapeoid][Modelo], Mapeo[mapeoid][ID_Objeto], mapeoid);
	            format(string, sizeof(string), "Editar\n");
			 	format(string, sizeof(string), "%sIndexs\n", string);
			 	format(string, sizeof(string), "%sDuplicar\n", string);
			 	format(string, sizeof(string), "%sPropiedades\n", string);
			 	format(string, sizeof(string), "%sCreado por: {"COLOR_AZUL"}%s\n", string, Mapeo[mapeoid][CreatedBy]);
			 	format(string, sizeof(string), "%sTipo: {"COLOR_AZUL"}%s\n \n", string, MapeoType[Mapeo[mapeoid][Tipo]]);
			 	format(string, sizeof(string), "%s{FF0000}Borrar", string);
	        }
			else if (Mapeo[mapeoid][Tipo] == MAPEO_TYPE_PUERTA)//Puerta
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
			else if (Mapeo[mapeoid][Tipo] == MAPEO_TYPE_PEAJE)//Peaje
	        {
	            new peajeid = Mapeo[mapeoid][Tipoid];
	            format(caption, sizeof(caption), "{"COLOR_AZUL"}Peaje [%i] modelo %i (ID: %i[%i])", peajeid, Mapeo[mapeoid][Modelo], Mapeo[mapeoid][ID_Objeto], mapeoid);
	            format(string, sizeof(string), "Editar\n");
			 	format(string, sizeof(string), "%sIndexs\n", string);
			 	format(string, sizeof(string), "%sDuplicar\n", string);
			 	format(string, sizeof(string), "%sCreada por: {"COLOR_AZUL"}%s\n", string, Mapeo[mapeoid][CreatedBy]);
			 	format(string, sizeof(string), "%sTipo: {"COLOR_AZUL"}%s\n \n", string, MapeoType[Mapeo[mapeoid][Tipo]]);
			 	format(string, sizeof(string), "%sEditar Recorrido\n", string);
			 	format(string, sizeof(string), "%sVelocidad: {"COLOR_AZUL"}%.2f\n", string, Peajes[peajeid][Velocidad]);
			 	format(string, sizeof(string), "%sPosicion del comando\n \n", string);
			 	format(string, sizeof(string), "%s{FF0000}Borrar", string);
	        }
			else if (Mapeo[mapeoid][Tipo] == MAPEO_TYPE_PARQUEO)
	        {
	            new parqueoid = Mapeo[mapeoid][Tipoid];
	            format(caption, sizeof(caption), "{"COLOR_AZUL"}Parqueo [%i] modelo %i (ID: %i[%i])", parqueoid, Mapeo[mapeoid][Modelo], Mapeo[mapeoid][ID_Objeto], mapeoid);
	            format(string, sizeof(string), "Editar\n");
			 	format(string, sizeof(string), "%sIndexs\n", string);
			 	format(string, sizeof(string), "%sDuplicar\n", string);
			 	format(string, sizeof(string), "%sCreada por: {"COLOR_AZUL"}%s\n", string, Mapeo[mapeoid][CreatedBy]);
			 	format(string, sizeof(string), "%sTipo: {"COLOR_AZUL"}%s\n \n", string, MapeoType[Mapeo[mapeoid][Tipo]]);
			 	format(string, sizeof(string), "%sEditar Recorrido\n", string);
			 	format(string, sizeof(string), "%sVelocidad: {"COLOR_AZUL"}%.2f\n \n", string, Parqueo[parqueoid][Velocidad]);
			 	format(string, sizeof(string), "%s{FF0000}Borrar", string);
	        }
		    ShowPlayerDialogEx(playerid, 156, DIALOG_STYLE_LIST, caption, string, "Seleccionar", "Cancelar");
	    }
	}
}

stock ShowObjectIndexes(playerid)
{
	new objectid = PlayersDataOnline[playerid][EditingObjectID];
	new string[1024], caption[100];

	if (PlayersDataOnline[playerid][EditingType] == EDITING_TYPE_MAPEO)
	{
	    new mapeoid = PlayersDataOnline[playerid][EditingMapeo];

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
	if (PlayersDataOnline[playerid][EditingType] == EDITING_TYPE_MAPEO)
	{
	    new mapeoid = PlayersDataOnline[playerid][EditingMapeo];

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
    format(caption, sizeof(caption), "{"COLOR_AZUL"}%s %i -> Velocidad", MapeoType[Mapeo[mapeoid][Tipo]], Mapeo[mapeoid][Tipoid]);
    
    ShowPlayerDialogEx(playerid, 160, DIALOG_STYLE_INPUT, caption, "Ingrese la velocidad a la que se movera el objeto:\n", "Aceptar", "Cancelar");
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
	if (mapeoid == -1) return -1;
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
	SaveMapeo(mapeoid);
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
    if (MAX_MAPEOS == MAX_MAPEOS_COUNT)
	{
	    new string[144];
	    format(string, sizeof(string), "Se alcanzo el maximo de mapeos (%i)", MAX_MAPEOS_COUNT);
	    return SendInfoMessage(playerid, 0, "", string);
	}
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
		PlayersDataOnline[playerid][EditingMapeo] = mapeoid_new;
		PlayersDataOnline[playerid][EditingObjectID] = Mapeo[mapeoid_new][ID_Objeto];
        EditDynamicObject(playerid, Mapeo[mapeoid_new][ID_Objeto]);
        new string[144];
        format(string, sizeof(string), "Creaste un mapeo modelo %i, Objetoid %i con el ID %i (Duplicar %i)", Mapeo[mapeoid_new][Modelo], Mapeo[mapeoid_new][ID_Objeto], mapeoid_new, mapeoid);
		SendAdviseMessage(playerid, string);
    }
    return 1;
}

stock DuplicarMapeoEx(playerid, mapeoid)
{
    if (MAX_MAPEOS == MAX_MAPEOS_COUNT)
	{
	    new string[144];
	    format(string, sizeof(string), "Se alcanzo el maximo de mapeos (%i)", MAX_MAPEOS_COUNT);
	    return SendInfoMessage(playerid, 0, "", string);
	}
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
		PlayersDataOnline[playerid][EditingMapeo] = mapeoid_new;
		PlayersDataOnline[playerid][EditingObjectID] = Mapeo[mapeoid_new][ID_Objeto];
        EditDynamicObject(playerid, Mapeo[mapeoid_new][ID_Objeto]);
        new string[144];
        format(string, sizeof(string), "Creaste un mapeo modelo %i, Objetoid %i con el ID %i (Duplicar %i)", Mapeo[mapeoid_new][Modelo], Mapeo[mapeoid_new][ID_Objeto], mapeoid_new, mapeoid);
		SendAdviseMessage(playerid, string);
    }
    return 1;
}

public ShowMapeoTypeDialog(playerid)
{
	new mapeoid = PlayersDataOnline[playerid][EditingMapeo];
	new caption[60], info[80];
	
	format(caption, sizeof(caption), "{"COLOR_AZUL"}Objeto modelo %i (ID: %i[%i]) -> Tipo", Mapeo[mapeoid][Modelo], Mapeo[mapeoid][ID_Objeto], mapeoid);
	for(new i=0; i!=4; i++)
	{
	    if (Mapeo[mapeoid][Tipo] == i)
	    format(info, sizeof(info), "%s{"COLOR_AZUL"}%s\n", info, MapeoType[i]);
	    else
	    format(info, sizeof(info), "%s%s\n", info, MapeoType[i]);
	}
	ShowPlayerDialogEx(playerid, 164, DIALOG_STYLE_LIST, caption, info, "Cambiar", "Volver");
}

public ShowMapeoPropiedades(playerid, mapeoid)
{
	new caption[60], info[500];
	
	format(caption, sizeof(caption), "{"COLOR_AZUL"}Objeto modelo %i (ID: %i[%i]) -> Propiedades", Mapeo[mapeoid][Modelo], Mapeo[mapeoid][ID_Objeto], mapeoid);
	format(info, sizeof(info), "Modelo:\t%i\n", Mapeo[mapeoid][Modelo]);
	format(info, sizeof(info), "%sMundo:\t%i\n", info, Mapeo[mapeoid][Mundo]);
	format(info, sizeof(info), "%sInterior:\t%i\n", info, Mapeo[mapeoid][Interior]);
	format(info, sizeof(info), "%sX:\t%f\n", info, Mapeo[mapeoid][PosX]);
	format(info, sizeof(info), "%sY:\t%f\n", info, Mapeo[mapeoid][PosY]);
	format(info, sizeof(info), "%sZ:\t%f\n", info, Mapeo[mapeoid][PosZ]);
	format(info, sizeof(info), "%sRX:\t%f\n", info, Mapeo[mapeoid][PosRX]);
	format(info, sizeof(info), "%sRY:\t%f\n", info, Mapeo[mapeoid][PosRY]);
	format(info, sizeof(info), "%sRZ:\t%f\n", info, Mapeo[mapeoid][PosRZ]);
	
    ShowPlayerDialogEx(playerid, 165, DIALOG_STYLE_TABLIST, caption, info, "Aceptar", "Volver");
	return 1;
}

public ShowMapeoPropiedadChange(playerid, mapeoid, option)
{
	new caption[60], info[144];
	
	if (option == 0)
	{
	    format(caption, sizeof(caption), "{"COLOR_AZUL"}Objeto %i[%i] -> Propiedades -> Modelo", Mapeo[mapeoid][ID_Objeto], mapeoid);
		format(info, sizeof(info), "Ingrese un nuevo Model_ID para el objeto:");
	}
	else if (option == 1)
	{
	    format(caption, sizeof(caption), "{"COLOR_AZUL"}Objeto %i[%i] -> Propiedades -> Mundo", Mapeo[mapeoid][ID_Objeto], mapeoid);
		format(info, sizeof(info), "Ingrese un nuevo mundo para el objeto:");
	}
	else if (option == 2)
	{
	    format(caption, sizeof(caption), "{"COLOR_AZUL"}Objeto %i[%i] -> Propiedades -> Interior", Mapeo[mapeoid][ID_Objeto], mapeoid);
		format(info, sizeof(info), "Ingrese un nuevo interior para el objeto:");
	}
	else if (option == 3)
	{
	    format(caption, sizeof(caption), "{"COLOR_AZUL"}Objeto %i[%i] -> Propiedades -> PosX", Mapeo[mapeoid][ID_Objeto], mapeoid);
		format(info, sizeof(info), "Ingrese una nueva coordenada X para el objeto:");
	}
	else if (option == 4)
	{
	    format(caption, sizeof(caption), "{"COLOR_AZUL"}Objeto %i[%i] -> Propiedades -> PosY", Mapeo[mapeoid][ID_Objeto], mapeoid);
		format(info, sizeof(info), "Ingrese una nueva coordenada Y para el objeto:");
	}
	else if (option == 5)
	{
	    format(caption, sizeof(caption), "{"COLOR_AZUL"}Objeto %i[%i] -> Propiedades -> PosZ", Mapeo[mapeoid][ID_Objeto], mapeoid);
		format(info, sizeof(info), "Ingrese una nueva coordenada Z para el objeto:");
	}
	else if (option == 6)
	{
	    format(caption, sizeof(caption), "{"COLOR_AZUL"}Objeto %i[%i] -> Propiedades -> RotX", Mapeo[mapeoid][ID_Objeto], mapeoid);
		format(info, sizeof(info), "Ingrese una nueva rotacion X para el objeto:");
	}
	else if (option == 7)
	{
	    format(caption, sizeof(caption), "{"COLOR_AZUL"}Objeto %i[%i] -> Propiedades -> RotY", Mapeo[mapeoid][ID_Objeto], mapeoid);
		format(info, sizeof(info), "Ingrese una nueva rotacion Y para el objeto:");
	}
	else if (option == 8)
	{
	    format(caption, sizeof(caption), "{"COLOR_AZUL"}Objeto %i[%i] -> Propiedades -> RotZ", Mapeo[mapeoid][ID_Objeto], mapeoid);
		format(info, sizeof(info), "Ingrese una nueva rotacion Z para el objeto:");
	}
	ShowPlayerDialogEx(playerid, 166, DIALOG_STYLE_INPUT, caption, info, "Aceptar", "Cancelar");
	return 1;
}

stock CambiarMapeoTipo(playerid, mapeoid, tipo)
{
	if (Mapeo[mapeoid][Tipo] == MAPEO_TYPE_PUERTA)
	{
	    BorrarPuerta(Mapeo[mapeoid][Tipoid]);
	}
	else if (Mapeo[mapeoid][Tipo] == MAPEO_TYPE_PEAJE)
	{
	    BorrarPeaje(Mapeo[mapeoid][Tipoid]);
	}
	else if (Mapeo[mapeoid][Tipo] == MAPEO_TYPE_PARQUEO)
	{
	    BorrarParqueo(Mapeo[mapeoid][Tipoid]);
	}
	if (Mapeo[mapeoid][Tipo] == tipo) return SendInfoMessage(playerid, 0, "", "Ese objeto ya es del mismo tipo");

    if (tipo == MAPEO_TYPE_OBJETO)
    {
        Mapeo[mapeoid][Tipo] = MAPEO_TYPE_OBJETO;
    }
	else if (tipo == MAPEO_TYPE_PUERTA)
	{
	    if(MAX_PUERTAS == MAX_PUERTAS_COUNT) return SendInfoMessage(playerid, 0, "", "Se Alcanzo el maximo de puertas");

		new puertaid = CrearPuerta(mapeoid);
		if (puertaid != -1)
		{
		    Mapeo[mapeoid][Tipo] = MAPEO_TYPE_PUERTA;
		    Mapeo[mapeoid][Tipoid] = puertaid;
		}
	}
	else if (tipo == MAPEO_TYPE_PEAJE)
	{
	    if (MAX_PEAJES == MAX_PEAJES_COUNT) return SendInfoMessage(playerid, 0, "", "Se Alcanzo el maximo de peajes");
	    
	    new peajeid = CrearPeaje(mapeoid);
	    if (peajeid != -1)
	    {
		    Mapeo[mapeoid][Tipo] = MAPEO_TYPE_PEAJE;
		    Mapeo[mapeoid][Tipoid] = peajeid;
	    }
	}
	else if (tipo == MAPEO_TYPE_PARQUEO)
	{
	    if (MAX_PARQUEOS == MAX_PARQUEOS_COUNT) return SendInfoMessage(playerid, 0, "", "Se Alcanzo el maximo de parqueos");
	    
	    new parqueoid = CrearParqueo(mapeoid);
	    if (parqueoid != -1)
	    {
		    Mapeo[mapeoid][Tipo] = MAPEO_TYPE_PARQUEO;
		    Mapeo[mapeoid][Tipoid] = parqueoid;
	    }
	}
	return 1;
}

public BorrarPuerta(puertaid)
{
	new path[30];
	format(path, 30, DIR_PUERTAS, puertaid); fremove(path);
	Puerta[puertaid][ID_Mapeo] = -1;
    Puerta[puertaid][Creada] = false;
    Puerta[puertaid][PosX] = 0;
    Puerta[puertaid][Velocidad] = 0;
    Puerta[puertaid][Abierta] = false;
    Puerta[puertaid][LlaveTipo] = 0;
    Puerta[puertaid][LlaveOwnerID] = 0;
	return 1;
}

public BorrarPeaje(peajeid)
{
	new path[30];
    format(path, 30, DIR_PEAJES, peajeid); fremove(path);
	Peajes[peajeid][Creado] = false;
	Peajes[peajeid][PosXFalse] = 0.0;
	Peajes[peajeid][PosCommandX] = 0.0;
	return 1;
}

public BorrarParqueo(parqueoid)
{
	new path[30];
    format(path, 30, DIR_PARQUEOS, parqueoid); fremove(path);
	Parqueo[parqueoid][Creado] = false;
	Parqueo[parqueoid][PosXFalse] = 0.0;
	return 1;
}

public CrearPuerta(mapeoid)
{
    new puertaid = GetNextPuertaID();
    if (puertaid != -1)
    {
        Puerta[puertaid][ID_Mapeo] = mapeoid;
	    Puerta[puertaid][Creada] = true;
	    Puerta[puertaid][Velocidad] = 1.0;
	    Puerta[puertaid][Abierta] = false;
	    SavePuerta(puertaid);
	    return puertaid;
    }
    return -1;
}

public CrearPeaje(mapeoid)
{
    new peajeid = GetNextPeajeID();
	if (peajeid != -1)
    {
        Peajes[peajeid][ID_Mapeo] = mapeoid;
		Peajes[peajeid][Creado] = true;
		Peajes[peajeid][PosXFalse] = 0.0;
		Peajes[peajeid][PosCommandX] = 0.0;
		Peajes[peajeid][Velocidad] = 0.2;
		SavePeaje(peajeid);
		return peajeid;
    }
	return -1;
}

public CrearParqueo(mapeoid)
{
    new parqueoid = GetNextParqueoID();
	if (parqueoid != -1)
    {
        Parqueo[parqueoid][ID_Mapeo] = mapeoid;
        Parqueo[parqueoid][Creado] = true;
        Parqueo[parqueoid][PosXFalse] = 0.0;
        Parqueo[parqueoid][Velocidad] = 0.2;
        Parqueo[parqueoid][Abierto] = false;
        SaveParqueo(parqueoid);
		return parqueoid;
    }
	return -1;
}
	    
stock GetNextPuertaID()
{
	for(new i=0; i!=MAX_PUERTAS_COUNT; i++)
	{
	    if (!Puerta[i][Creada]) return i;
	}
	return -1;
}

stock GetNextPeajeID()
{
	for(new i=0; i!=MAX_PEAJES_COUNT; i++)
	{
	    if (!Peajes[i][Creado]) return i;
	}
	return -1;
}

stock GetNextParqueoID()
{
    for(new i=0; i!=MAX_PARQUEOS_COUNT; i++)
	{
	    if (!Parqueo[i][Creado]) return i;
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
    
	if (tipo == MAPEO_TYPE_PUERTA)
	{
	    format(path, 30, DIR_PUERTAS, tipoid); fremove(path);
	    Puerta[tipoid][Creada] = 0;
	    Puerta[tipoid][PosX] = 0;
	    Puerta[tipoid][Velocidad] = 0;
	    Puerta[tipoid][Abierta] = false;
	    Puerta[tipoid][LlaveTipo] = 0;
	    Puerta[tipoid][LlaveOwnerID] = 0;
	}
	else if(tipo == MAPEO_TYPE_PEAJE)
	{
	    format(path, 30, DIR_PEAJES, tipoid); fremove(path);
		Peajes[tipoid][Creado] = false;
		Peajes[tipoid][PosXFalse] = 0.0;
		Peajes[tipoid][PosCommandX] = 0.0;
	}
	
	if (playerid != -1)
	{
		new string[144];
		format(string, sizeof(string), "Borraste el mapeo ID %i, Objetoid %i", mapeoid, objectid);
		SendAdviseMessage(playerid, string);
		PlayersDataOnline[playerid][EditingType] = false;
		PlayersDataOnline[playerid][EditingObjectID] = 0;
	}
}

stock BorrarObjetoIndex(playerid, tipo, indexid)
{
    new objectid = PlayersDataOnline[playerid][EditingObjectID];
    
	if (tipo == EDITING_TYPE_MAPEO)//Mapeo
	{
		new mapeoid = PlayersDataOnline[playerid][EditingMapeo];
		
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

forward CerrarPeaje(peajeid);
public CerrarPeaje(peajeid)
{
	new mapeoid = Peajes[peajeid][ID_Mapeo];
	MoveDynamicObject(Mapeo[mapeoid][ID_Objeto], Mapeo[mapeoid][PosX], Mapeo[mapeoid][PosY], Mapeo[mapeoid][PosZ], Peajes[peajeid][Velocidad], Mapeo[mapeoid][PosRX], Mapeo[mapeoid][PosRY], Mapeo[mapeoid][PosRZ]);
	Peajes[peajeid][Abierto] = false;
	return 1;
}

forward CerrarParqueo(parqueoid);
public CerrarParqueo(parqueoid)
{
	new mapeoid = Parqueo[parqueoid][ID_Mapeo];
	MoveDynamicObject(Mapeo[mapeoid][ID_Objeto], Mapeo[mapeoid][PosX], Mapeo[mapeoid][PosY], Mapeo[mapeoid][PosZ], Parqueo[parqueoid][Velocidad], Mapeo[mapeoid][PosRX], Mapeo[mapeoid][PosRY], Mapeo[mapeoid][PosRZ]);
	Parqueo[parqueoid][Abierto] = false;
	return 1;
}

public SaveParqueo(parqueoid)
{
    new
		datos[120],
		parqueoDir[30];
	format(parqueoDir, 30, DIR_PARQUEOS, parqueoid);
	new File:parqueoFile = fopen(parqueoDir, io_write);
	format(datos, sizeof(datos), "%i|%f|%f|%f|%f|%f|%f|%f|",
	    Parqueo[parqueoid][ID_Mapeo],
	    Parqueo[parqueoid][PosXFalse],
	    Parqueo[parqueoid][PosYFalse],
	    Parqueo[parqueoid][PosZFalse],
	    Parqueo[parqueoid][PosRotXFalse],
	    Parqueo[parqueoid][PosRotYFalse],
	    Parqueo[parqueoid][PosRotZFalse],
	    Parqueo[parqueoid][Velocidad]);

	fwrite(parqueoFile, datos);
	fclose(parqueoFile);
	return 1;
}
