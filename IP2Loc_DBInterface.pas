 ////////////////////////////////////////////////
// Unit      : IP2Loc_DBInterface.pas           //
// Version   : 1.0 beta                         //
// Date      : April 2014                       //
// Translator: Benbaha Abdelkrim AKA DeadC0der  //
// Email     : DeadC0der7@gmail.com             //
// License   : Included :)                      //
 ////////////////////////////////////////////////

unit IP2Loc_DBInterface;

interface

uses Windows,SysUtils;

type
 TIP2Location_mem_type =(IP2LOCATION_FILE_IO,IP2LOCATION_CACHE_MEMORY,IP2LOCATION_SHARED_MEMORY);

 function  IP2Location_read128(handle:integer;position:DWORD):PAnsiChar;
 function  IP2Location_read32(handle:integer;position:DWORD):DWORD;
 function  IP2Location_read8(handle:integer;position:DWORD):Byte;
 function  IP2Location_readStr(handle:integer;position:DWORD):PChar;
 function  IP2Location_readFloat(handle:integer;position:DWORD):Single;
 function  IP2Location_DB_set_file_io():DWORD;
 function  IP2Location_DB_set_memory_cache(filehandle:integer):integer;
 function  IP2Location_DB_set_shared_memory(filehandle:integer):integer;
 function  IP2Location_DB_close(filehandle:integer):integer;
 procedure IP2Location_DB_del_shm();

implementation

uses iMath;

const
IP2LOCATION_SHM ='/IP2location_Shm';
{$IFDEF POSIX}
MAP_ADDR =4194500608;
{$ENDIF}

var
 DB_access_type:TIP2Location_mem_type=IP2LOCATION_FILE_IO;
 cache_shm_ptr :pointer; 
 shm_fd   	   :integer;

function IP2Location_DB_Load_to_mem(filehandle:integer;memory:pointer;size:int64):integer;
begin
 result:=0;
 if filehandle = -1 then begin result:=-1 ; exit; end;
 FileSeek(filehandle,0,0);
 if  FileRead(filehandle,memory^,size)=0 then result:=-1;
end;

//Description: set the DB access method as memory cache and read the file into cache
function IP2Location_DB_set_memory_cache(filehandle:integer):integer;
var _size:integer;
begin
 DB_access_type:=IP2LOCATION_FILE_IO;
 result:=-1;
 _size:=GetFileSize(filehandle,nil);
  if (filehandle<>-1) and (_size<>-1) then
   begin
    cache_shm_ptr:=AllocMem(_size);
     if assigned(cache_shm_ptr) and (IP2Location_DB_Load_to_mem(filehandle,cache_shm_ptr,_size)<>-1) then
      begin
       result:=0;
	     DB_access_type:=IP2LOCATION_CACHE_MEMORY;
	    end;

   end;
end;

//Description: set the DB access method as shared memory
function IP2Location_DB_set_shared_memory(filehandle:integer):integer;
var 
_size:integer;
DB_Loaded:boolean;
begin
 DB_access_type:=IP2LOCATION_FILE_IO;
 result:=-1;
 _size:=GetFileSize(filehandle,nil);
  if (filehandle <>-1) and (_size<>-1) then
   begin
  	shm_fd:=CreateFileMapping(
                 INVALID_HANDLE_VALUE,
                 nil,
                 PAGE_READWRITE,
                 0,
                 _size+1,
                 PChar(IP2LOCATION_SHM));
	  DB_loaded := (GetLastError = ERROR_ALREADY_EXISTS);
	   if shm_fd <>0 then
	    cache_shm_ptr := MapViewOfFile(
			shm_fd,
			FILE_MAP_WRITE,
			0, 
			0,
			0)else exit;
	   if not(DB_Loaded) and (IP2Location_DB_Load_to_mem(filehandle,cache_shm_ptr,_size)<>-1) then
	    begin
	     DB_access_type := IP2LOCATION_SHARED_MEMORY;
	     result:=0;
	    end
	   else
	   begin
	    UnmapViewOfFile(cache_shm_ptr);
	    CloseHandle(shm_fd);
	 	 end;
   end;
end;

//Close the corresponding memory, based on the opened option. 
function IP2Location_DB_close(filehandle:integer):integer;
begin
 if filehandle<>0 then CloseHandle(filehandle);
 if assigned(cache_shm_ptr) then
  case DB_access_type of
   IP2LOCATION_CACHE_MEMORY : FreeMem(cache_shm_ptr);
   IP2LOCATION_SHARED_MEMORY: begin UnmapViewOfFile(cache_shm_ptr);CloseHandle(shm_fd);end;
  end;
 DB_access_type := IP2LOCATION_FILE_IO;
 result:=0;
 end;
 
 function IP2Location_read8(handle:integer;position:DWORD):byte;
 begin
  result:=0;
  	if (DB_access_type = IP2LOCATION_FILE_IO) and (handle <> 0) then
	   begin
	    FileSeek(handle,position-1,0);
      FileRead(handle,result,1);
	   end
	  else
	  result:=PByteArray(cache_shm_ptr)^[position-1];
 end; 
	 
function IP2Location_read32(handle:integer;position:cardinal):cardinal;
var byte1,byte2,byte3,byte4:Byte;
begin
 if (DB_access_type = IP2LOCATION_FILE_IO) and (handle <> 0) then
	 begin
	  FileSeek(handle,position-1,0);
      FileRead(handle,byte1,1);
	  FileRead(handle,byte2,1);
	  FileRead(handle,byte3,1);
	  FileRead(handle,byte4,1);
	 end
 else
   begin
	  byte1:=PByteArray(cache_shm_ptr)^[position-1];
	  byte2:=PByteArray(cache_shm_ptr)^[position];
	  byte3:=PByteArray(cache_shm_ptr)^[position+1];
	  byte4:=PByteArray(cache_shm_ptr)^[position+2];
	 end;
	result:= (byte4 shl 24) or (byte3 shl 16) or (byte2 shl 8) or byte1;  
  end;

function IP2Location_readStr(handle:integer;position:cardinal):PChar;
var _size:byte;P_In:PAnsiChar;
begin
 result:='';
 if (DB_access_type = IP2LOCATION_FILE_IO) and (handle <> 0) then 
  begin
   FileSeek(handle,position,0);
   FileRead(handle,_size,1);
   Result:=AllocMem(_size+1);
   FileRead(handle,result^,_size);
  end
  else
  begin
   _size:=PByteArray(cache_shm_ptr)^[position];
   Result:=AllocMem(_size+1);
   CopyMemory(result,@PByteArray(cache_shm_ptr)^[position+1],_size);
  end;
 {$IFDEF UNICODE}
  P_IN  :=PAnsiChar(Result);
  Result:=AllocMem(StrLen(P_IN)*2+2);
  MultiByteToWideChar(CP_UTF8,0,P_IN,StrLen(P_IN),Result,StrLen(P_IN));
 {$ENDIF}
end; 

function IP2Location_readFloat(handle:integer;position:cardinal):single;
begin
 result:=0.0;
  if (DB_access_type = IP2LOCATION_FILE_IO) and (handle <> 0) then
   begin
    FileSeek(handle,position-1,0);
    FileRead(handle,result,4);
   end
  else
  CopyMemory(@result,@PByteArray(cache_shm_ptr)^[position-1],4);
end; 

 
procedure IP2Location_DB_del_shm();
begin
{$IFDEF POSIX}
{$ENDIF}
end;

function IP2Location_mp2string (mp:mp_int):PAnsiChar;
begin
result:=AllocMem(128);
mp_int_to_string(mp,10,result,128);
end;

function IP2Location_read128(handle:integer;position:DWORD):PAnsiChar;
 var
  b1_31,b32_63,b64_95,b96_127:DWORD;
  _result, multiplier, mp96_127, mp64_95, mp32_63, mp1_31:mp_int;
  begin
     b96_127  := IP2Location_read32(handle, position);
	 b64_95   := IP2Location_read32(handle, position + 4); 
	 b32_63   := IP2Location_read32(handle, position + 8);
	 b1_31    := IP2Location_read32(handle, position + 12);
	 
	_result   :=mp_int_alloc;
	multiplier:=mp_int_alloc;
	mp96_127  :=mp_int_alloc;
	mp64_95   :=mp_int_alloc;
	mp32_63   :=mp_int_alloc;
	mp1_31    :=mp_int_alloc;
	
	mp_int_init(_result);
	mp_int_init(multiplier);
	mp_int_init(mp96_127);
	mp_int_init(mp64_95);
	mp_int_init(mp32_63);
	mp_int_init(mp1_31);
	
 	mp_int_init_value(multiplier, 65536);
	mp_int_mul(multiplier, multiplier, multiplier);
	
	mp_int_init_value(mp96_127, b96_127);
	mp_int_init_value(mp64_95, b64_95);
	mp_int_init_value(mp32_63, b32_63);
	mp_int_init_value(mp1_31, b1_31);
	
    mp_int_mul(mp1_31, multiplier, mp1_31);
	mp_int_mul(mp1_31, multiplier, mp1_31);
	mp_int_mul(mp1_31, multiplier, mp1_31);
	
    mp_int_mul(mp32_63,multiplier,mp32_63);
	mp_int_mul(mp32_63,multiplier,mp32_63);
	
 	mp_int_mul(mp64_95, multiplier, mp64_95);
	
	mp_int_add(mp1_31, mp32_63, _result);
	mp_int_add(_result, mp64_95, _result);
	mp_int_add(_result, mp96_127, _result);

   result:=IP2Location_mp2string(_result);
   
   
 
end;



function IP2Location_DB_set_file_io():DWORD;
begin

end;

end.