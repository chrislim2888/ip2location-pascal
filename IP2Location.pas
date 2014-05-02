 ////////////////////////////////////////////////
// Unit      : IP2Location.pas                  //
// Version   : 1.0 beta                         //
// Date      : April 2014                       //
// Translator: Benbaha Abdelkrim AKA DeadC0der  //
// Email     : DeadC0der7@gmail.com             //
// License   : Included :)                      //
 ////////////////////////////////////////////////

unit IP2Location;

interface

uses Windows,SysUtils,IP2Loc_DBInterface;

const
 API_VERSION	   		= 4.00;
 MAX_IPV4_RANGE  		= 4294967295;
 MAX_IPV6_RANGE  		= '340282366920938463463374607431768211455';
 IPV4            		= 0;
 IPV6            		= 1;
 _COUNTRYSHORT			= $00001;
 _COUNTRYLONG			= $00002;
 _REGION 				= $00004;
 _CITY 					= $00008;
 _ISP            		= $00010;
 _LATITUDE 				= $00020;
 _LONGITUDE				= $00040;
 _DOMAIN 				= $00080;
 _ZIPCODE				= $00100;
 _TIMEZONE 				= $00200;
 _NETSPEED        		= $00400;
 _IDDCODE         		= $00800;
 _AREACODE        		= $01000;
 _WEATHERSTATIONCODE	= $02000;
 _WEATHERSTATIONNAME	= $04000;
 _MCC             		= $08000;
 _MNC             		= $10000;
 _MOBILEBRAND     		= $20000;
 _ELEVATION       		= $40000;
 _USAGETYPE       		= $80000;
 _ALL                	= _COUNTRYSHORT 		or
						 _COUNTRYLONG  			or
						 _REGION       			or
						 _CITY		 			or
						 _ISP			 		or
						 _LATITUDE     			or
						 _LONGITUDE	 			or
						 _DOMAIN		 		or
						 _ZIPCODE		 		or
						 _TIMEZONE	 			or
						 _NETSPEED	 			or
						 _IDDCODE		 		or
						 _AREACODE		    	or
						 _WEATHERSTATIONCODE	or
						 _WEATHERSTATIONNAME	or
						 _MCC					or
						 _MNC					or
						 _MOBILEBRAND			or
						 _ELEVATION 			or
						 _USAGETYPE;
 DEFAULT	    		= $0001;
 NO_EMPTY_STRING 		= $0002;
 NO_LEADING     		= $0004;
 NO_TRAILING    		= $0008;
 INVALID_IPV6_ADDRESS	= 'INVALID IPV6 ADDRESS';
 INVALID_IPV4_ADDRESS	= 'INVALID IPV4 ADDRESS';
 NOT_SUPPORTED		 	= 'This parameter is unavailable for selected data file. Please upgrade the data file.';

type
 PIP2Location = ^TIP2LOCATION;
 _IP2Location  = record
	filehandle:integer;
	databasetype:byte;
	databasecolumn:byte;
	databaseday:byte;
	databasemonth:byte;
	databaseyear:byte;
	databasecount:DWORD;
	databaseaddr:DWORD;
	ipversion:DWORD;
  end;
  TIP2Location = _IP2Location;

  PIP2LocationRecord = ^TIP2LocationRecord;
  _IP2LocationRecord  = record
    country_short:PChar;
	country_long:PChar;
	region:PChar;
	city:PChar;
	isp:PChar;
	latitude:Single;
	longitude:Single;
	domain:PChar;
	zipcode:PChar;
	timezone:PChar;
	netspeed:PChar;
	iddcode:PChar;
	areacode:PChar;
	weatherstationcode:PChar;
	weatherstationname:PChar;
	mcc:PChar;
	mnc:PChar;
	mobilebrand:PChar;
	elevation:Single;
	usagetype:PChar;
   end;
   TIP2LocationRecord = _IP2LocationRecord;

   
function  IP2Location_open(db:PChar):TIP2Location;
function  IP2Location_open_mem(loc:TIP2Location;mtype:TIP2Location_mem_type):integer;
function  IP2Location_close(loc:TIP2Location):DWORD;
function  IP2Location_get_country_short(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
function  IP2Location_get_country_long(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
function  IP2Location_get_country_region(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
function  IP2Location_get_country_city(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
function  IP2Location_get_country_isp(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
function  IP2Location_get_country_latitude(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
function  IP2Location_get_country_longitude(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
function  IP2Location_get_country_domain(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
function  IP2Location_get_country_zipcode(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
function  IP2Location_get_country_timezone(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
function  IP2Location_get_country_netspeed(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
function  IP2Location_get_country_iddcode(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
function  IP2Location_get_country_areacode(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
function  IP2Location_get_country_weatherstationcode(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
function  IP2Location_get_country_weatherstationname(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
function  IP2Location_get_country_mcc(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
function  IP2Location_get_country_mnc(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
function  IP2Location_get_country_mobilebrand(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
function  IP2Location_get_country_elevation(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
function  IP2Location_get_country_usagetype(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
function  IP2Location_get_country_all(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
procedure IP2Location_free_record(_record:TIP2LocationRecord);

implementation

uses WinSock,Classes,iMath;

const
 COUNTRY_POSITION         	:array [0..24] of byte   =(0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2);
 REGION_POSITION          	:array [0..24] of byte   =(0,0,0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3);
 CITY_POSITION            	:array [0..24] of byte   =(0,0,0,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4);
 ISP_POSITION             	:array [0..24] of byte   =(0,0,3,0,5,0,7,5,7,0,8,0,9,0,9,0,9,0,9,7,9,0,9,7,9);
 LATITUDE_POSITION        	:array [0..24] of byte 	 =(0,0,0,0,0,5,5,0,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5);
 LONGITUDE_POSITION       	:array [0..24] of byte 	 =(0,0,0,0,0,6,6,0,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6);
 DOMAIN_POSITION          	:array [0..24] of byte   =(0,0,0,0,0,0,0,6,8,0,9,0,10,0,10,0,10,0,10,8,10,0,10,8,10);
 ZIPCODE_POSITION         	:array [0..24] of byte   =(0,0,0,0,0,0,0,0,0,7,7,7,7,0,7,7,7,0,7,0,7,7,7,0,7);
 TIMEZONE_POSITION        	:array [0..24] of byte   =(0,0,0,0,0,0,0,0,0,0,0,8,8,7,8,8,8,7,8,0,8,8,8,0,8);
 NETSPEED_POSITION        	:array [0..24] of byte   =(0,0,0,0,0,0,0,0,0,0,0,0,0,8,11,0,11,8,11,0,11,0,11,0,11);
 IDDCODE_POSITION         	:array [0..24] of byte   =(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,12,0,12,0,12,9,12,0,12);
 AREACODE_POSITION        	:array [0..24] of byte   =(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,10,13,0,13,0,13,10,13,0,3);
 WEATHERSTATIONCODE_POSITION:array [0..24] of byte   =(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,14,0,14,0,14,0,14);
 WEATHERSTATIONNAME_POSITION:array [0..24] of byte   =(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,10,15,0,15,0,15,0,15);
 MCC_POSITION				:array [0..24] of byte   =(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,16,0,16,9,16);
 MNC_POSITION				:array [0..24] of byte   =(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,10,17,0,17,10,17);
 MOBILEBRAND_POSITION		:array [0..24] of byte   =(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,11,18,0,18,11,18);
 ELEVATION_POSITION			:array [0..24] of byte   =(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,11,19,0,19);
 USAGETYPE_POSITION			:array [0..24] of byte   =(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,12,20);

 var
 openMemFlag:Boolean = False;

// Descrption:initializes the record with the appropriate value from the database.
function IP2Location_initialize(var loc:TIP2Location):integer;
begin
    loc.databasetype   := IP2Location_read8(loc.filehandle,1);
	loc.databasecolumn := IP2Location_read8(loc.filehandle,2);
	loc.databaseyear   := IP2Location_read8(loc.filehandle,3);
	loc.databasemonth  := IP2Location_read8(loc.filehandle,4);
	loc.databaseday    := IP2Location_read8(loc.filehandle,5);
	loc.databasecount  := IP2Location_read32(loc.filehandle,6);
	loc.databaseaddr   := IP2Location_read32(loc.filehandle,10);
	loc.ipversion      := IP2Location_read32(loc.filehandle,14);
    result:=0;
end;

// Description: Delete IP2Location shared memory if it is present.
procedure IP2Location_delete_shm;
begin
IP2Location_DB_del_shm();
end; 

function IP2Location_new_record():TIP2LocationRecord;
begin
//
end;

function StringListCount(toCount:TStringList):DWORD;
begin
 result:=0;
  if assigned(toCount) then
   result:=toCount.count;
end;

procedure FreeStringList(toFree:TStringList);
begin
 if assigned(toFree) then
  FreeAndNil(toFree);
end;

function IP2Location_split(delimiters,targetString:String;flags:DWORD;limit:integer):TStringList;
var i:integer;
    cs:TSysCharSet;
begin
Result:=TStringList.create;
cs:=[];
 for i:=1 to Length(delimiters) do
  cs:=cs+[delimiters[i]];
 ExtractStrings(cs,[],Pchar(targetString),result);
end;

function IP2Location_replace(substr,replace,targetString:PChar):PChar;
begin
result:=PChar(StringReplace(targetString,substr,replace,[rfReplaceAll]));
end;

function IP2Location_substr_count(substr,targetString:PChar):DWORD;
var caret:pchar;
begin
result:=0;
caret:=StrPos(targetString,substr);
 while Assigned(caret) do
  begin
	inc(result);
    caret:=caret+StrLen(substr);
	caret:=StrPos(caret,substr);
  end;
end;

function IP2Location_ip2no(ip:PChar):DWORD;
 function bswap(value:Cardinal):Cardinal;
  asm
   mov eax,value
   BSWAP EAX;
  end;
{$IFNDEF UNICODE}
begin
 result:=bswap(inet_addr(ip));
end;
{$ELSE}
 var P_Out:PAnsiChar;
begin
  P_Out:=AllocMem(StrLen(ip)+1);
  WideCharToMultiByte(CP_UTF8,0,ip,StrLen(ip),P_Out,StrLen(ip),nil,nil);
  result:=bswap(inet_addr(P_Out));
  end;
{$ENDIF}

function IP2Location_ipv6_to_no(ip:PChar):mp_int;
var n,i,padCount:cardinal;
    expanded:array[0..7] of char;
    expanded_:PChar;
	_array:TStringList;
	ipsub:mp_int;
	P_Out:PAnsiChar;
begin
ipsub:=mp_int_alloc;
result:=mp_int_alloc;
mp_int_init(ipsub);
mp_int_init(result);
n:=IP2Location_substr_count(':',ip);
FillChar(expanded,length(expanded),0);
 if n < 7 then
 begin
 expanded[0]:= ':';
 expanded[1]:= ':';
 padCount:=2;
  while n<7  do
	begin
   expanded[padCount]:=':';
	 inc(padCount);
	 inc(n);
	end;
  expanded_:=IP2Location_replace(':',':0',expanded);
  ip:= IP2Location_replace('::',expanded_,ip);
 end;
 _array:=IP2Location_split(':',ip,DEFAULT,-1);
 mp_int_init_value(result, 0);
 for i:=0 to StringListCount(_array)-1 do
   if _array[i]<>'' then
   begin
   {$IFNDEF UNICODE}
   	mp_int_read_string(ipsub,16,Pchar(_array[i]));
   {$ELSE}
    P_Out:=AllocMem(Length(_array[i])+1);
    WideCharToMultiByte(CP_UTF8,0,Pchar(_array[i]),Length(_array[i]),P_Out,Length(_array[i]),nil,nil);
    mp_int_read_string(ipsub,16,P_Out);
   {$ENDIF}
   	mp_int_mul_pow2(ipsub,(7-i)*16,ipsub);
  	mp_int_add(result,ipsub,result);
   end;

 mp_int_clear(ipsub);
 FreeStringList(_array);
end; 

function IP2Location_ip_is_ipv4(ipaddr:PChar):boolean;
var p:integer;
    iparray:TStringList;
begin
 result:=false;
  for p:=0 to StrLen(ipaddr)-1 do
   if not((ipaddr[p] >= '0') and (ipaddr[p] <= '9') or
    			(ipaddr[p] = '.')) then exit
 else if ((p=0) or (p=StrLen(ipaddr)-1)) and
			(ipaddr[p]='.') then exit
 else if Assigned(StrPos(ipaddr,'::')) then exit;
  
  iparray:=IP2Location_split('.', ipaddr,0,0);
  if assigned(iparray) and (StringListCount(iparray)=4) then
   begin
    result:=true;
    	for p:=0 to StringListCount(iparray)-1 do
         result:= result and ((strtoint(iparray[p])>=0) and (strtoint(iparray[p])<=255));
	FreeStringList(iparray);
   end;
end;

function IP2Location_ip_is_ipv6(ipaddr:PChar):Boolean;
var n,i,j:cardinal;
    ipv6array:TStringList;
begin
result:=False;
n:=IP2Location_substr_count(':', ipaddr);
if (n>0) and (n<8) then 
 begin
 ipv6array:=IP2Location_split(':', ipaddr, DEFAULT, -1);
  for i:=0 to StringListCount(ipv6array)-1 do
    if (i=n+1) and IP2Location_ip_is_ipv4(pchar(ipv6array[i])) then Continue
    else
     if Length(ipv6array[i])<=4 then
	  begin
	  result:=true;
	   for j:=1 to Length(ipv6array[i]) do
	    result:=result and (((ipv6array[i][j]>='a') and (ipv6array[i][j]<='f')) or
							((ipv6array[i][j]>='A') and (ipv6array[i][j]<='F')) or  
							((ipv6array[i][j]>='0') and (ipv6array[i][j]<='9')));
	  end
	  else
	  result:=False;
	  result:= result and not((n<7) and (IP2Location_substr_count('::', ipaddr)<>1));
	  FreeStringList(ipv6array);
 end;

end;

function IP2Location_get_record(loc:TIP2Location;ip:PChar;mode:DWORD):TIP2LocationRecord;
var
dbtype:byte;
handle:integer;
ipno,baseaddr,dbcount,dbcolumn,low,
high,mid,ipfrom,ipto:cardinal;
begin
 dbtype:= loc.databasetype;
 ipno:= IP2Location_ip2no(ip);
 handle:= loc.filehandle;
 baseaddr:= loc.databaseaddr;
 dbcount:= loc.databasecount;
 dbcolumn:= loc.databasecolumn;
 low:= 0;
 high:= dbcount;
 mid:= 0;
 ipfrom:= 0;
 ipto:= 0;
 result :=IP2Location_new_record();
	if (ipno = MAX_IPV4_RANGE)  then
		ipno := ipno - 1;
	 with result do
	  begin
	  if not(IP2Location_ip_is_ipv4(ip))  then
	  begin
	    country_short:= INVALID_IPV4_ADDRESS;
		country_long:= INVALID_IPV4_ADDRESS;
		region:= INVALID_IPV4_ADDRESS;
		city:= INVALID_IPV4_ADDRESS;
		isp:= INVALID_IPV4_ADDRESS;
		latitude:= 0;
		longitude:= 0;
		domain:= INVALID_IPV4_ADDRESS;
		zipcode:= INVALID_IPV4_ADDRESS;
		timezone:= INVALID_IPV4_ADDRESS;
		netspeed:= INVALID_IPV4_ADDRESS;
		iddcode:= INVALID_IPV4_ADDRESS;
		areacode:= INVALID_IPV4_ADDRESS;
		weatherstationcode:= INVALID_IPV4_ADDRESS;
		weatherstationname:= INVALID_IPV4_ADDRESS;
		mcc:= INVALID_IPV4_ADDRESS;
		mnc:= INVALID_IPV4_ADDRESS;
		mobilebrand:= INVALID_IPV4_ADDRESS;
		elevation:= 0;
		usagetype:= INVALID_IPV4_ADDRESS;
		exit;
	   end;
	while low <=high do
    begin
		mid := (low + high) div 2;
		ipfrom := IP2Location_read32(handle, baseaddr + mid * dbcolumn * 4);
		ipto   := IP2Location_read32(handle, baseaddr + (mid + 1) * dbcolumn * 4);
		 if (ipno >= ipfrom) and (ipno < ipto) then
		 begin

       if ((mode and _COUNTRYSHORT)>0) and (COUNTRY_POSITION[dbtype] <> 0) then
        country_short := IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + (mid * dbcolumn * 4) + 4 * (COUNTRY_POSITION[dbtype]-1)))
			 else
				country_short :=NOT_SUPPORTED;
		  if ((mode and _COUNTRYLONG)>0) and (COUNTRY_POSITION[dbtype] <> 0) then
				country_long := IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + (mid * dbcolumn * 4) + 4 * (COUNTRY_POSITION[dbtype]-1))+3)
			 else
				country_long :=NOT_SUPPORTED;

			if ((mode and _REGION)>0) and (REGION_POSITION[dbtype] <> 0) then
				region:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + (mid * dbcolumn * 4) + 4 * (REGION_POSITION[dbtype]-1)))
			 else
				region :=NOT_SUPPORTED;


			if ((mode and _CITY)>0) and (CITY_POSITION[dbtype] <> 0) then
				city:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + (mid * dbcolumn * 4) + 4 * (CITY_POSITION[dbtype]-1)))
			 else
				city :=NOT_SUPPORTED;
			

			if ((mode and _ISP)>0) and (ISP_POSITION[dbtype] <> 0) then
				isp:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + (mid * dbcolumn * 4) + 4 * (ISP_POSITION[dbtype]-1)))
			 else
				isp :=NOT_SUPPORTED;
			

			if ((mode and _LATITUDE)>0) and (LATITUDE_POSITION[dbtype] <> 0) then
				latitude:=IP2Location_readFloat(handle, baseaddr + (mid * dbcolumn * 4) + 4 * (LATITUDE_POSITION[dbtype]-1))
			 else 
				latitude:=0.0;
			

			if ((mode and _LONGITUDE)>0) and (LONGITUDE_POSITION[dbtype] <> 0) then
				longitude:=IP2Location_readFloat(handle, baseaddr + (mid * dbcolumn * 4) + 4 * (LONGITUDE_POSITION[dbtype]-1))
			 else
				longitude:=0.0;
			

			if ((mode and _DOMAIN)>0) and (DOMAIN_POSITION[dbtype] <> 0) then
				domain:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + (mid * dbcolumn * 4) + 4 * (DOMAIN_POSITION[dbtype]-1)))
			 else 
				domain :=NOT_SUPPORTED;


			if ((mode and _ZIPCODE)>0) and (ZIPCODE_POSITION[dbtype] <> 0) then
				zipcode:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + (mid * dbcolumn * 4) + 4 * (ZIPCODE_POSITION[dbtype]-1)))
			 else
				zipcode :=NOT_SUPPORTED;


			if ((mode and _TIMEZONE)>0) and (TIMEZONE_POSITION[dbtype] <> 0) then
				timezone:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + (mid * dbcolumn * 4) + 4 * (TIMEZONE_POSITION[dbtype]-1)))
			 else
				timezone :=NOT_SUPPORTED;

			
			if ((mode and _NETSPEED)>0) and (NETSPEED_POSITION[dbtype] <> 0) then
				netspeed:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + (mid * dbcolumn * 4) + 4 * (NETSPEED_POSITION[dbtype]-1)))
			 else
				netspeed :=NOT_SUPPORTED;

			if ((mode and _IDDCODE)>0) and (IDDCODE_POSITION[dbtype] <> 0) then
				iddcode:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + (mid * dbcolumn * 4) + 4 * (IDDCODE_POSITION[dbtype]-1)))
			 else
				iddcode :=NOT_SUPPORTED;

	
			if ((mode and _AREACODE)>0) and (AREACODE_POSITION[dbtype] <> 0) then
				areacode:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + (mid * dbcolumn * 4) + 4 * (AREACODE_POSITION[dbtype]-1)))
			 else
				areacode :=NOT_SUPPORTED;


			if ((mode and _WEATHERSTATIONCODE)>0) and (WEATHERSTATIONCODE_POSITION[dbtype] <> 0) then
				weatherstationcode:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + (mid * dbcolumn * 4) + 4 * (WEATHERSTATIONCODE_POSITION[dbtype]-1)))
			 else
				weatherstationcode :=NOT_SUPPORTED;


			if ((mode and _WEATHERSTATIONNAME)>0) and (WEATHERSTATIONNAME_POSITION[dbtype] <> 0) then
				weatherstationname:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + (mid * dbcolumn * 4) + 4 * (WEATHERSTATIONNAME_POSITION[dbtype]-1)))
			 else 
				weatherstationname :=NOT_SUPPORTED;
			

			if ((mode and _MCC)>0) and (MCC_POSITION[dbtype] <> 0) then
				mcc:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + (mid * dbcolumn * 4) + 4 * (MCC_POSITION[dbtype]-1)))
			 else 
				mcc :=NOT_SUPPORTED;
			

			if ((mode and _MNC)>0) and (MNC_POSITION[dbtype] <> 0) then
				mnc:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + (mid * dbcolumn * 4) + 4 * (MNC_POSITION[dbtype]-1)))
			 else 
				mnc :=NOT_SUPPORTED;
			

			if ((mode and _MOBILEBRAND)>0) and (MOBILEBRAND_POSITION[dbtype] <> 0) then
				mobilebrand:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + (mid * dbcolumn * 4) + 4 * (MOBILEBRAND_POSITION[dbtype]-1)))
			 else
				mobilebrand :=NOT_SUPPORTED;
			
			
			if ((mode and _ELEVATION)>0) and (ELEVATION_POSITION[dbtype] <> 0) then
				elevation:=strtofloat(IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + (mid * dbcolumn * 4) + 4 * (ELEVATION_POSITION[dbtype]-1))))
			else 
				elevation:=0.0;
			

			if ((mode and _USAGETYPE)>0) and (USAGETYPE_POSITION[dbtype] <> 0) then
				usagetype:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + (mid * dbcolumn * 4) + 4 * (USAGETYPE_POSITION[dbtype]-1)))
			 else 
				usagetype :=NOT_SUPPORTED;
			exit;
		 end
		 else
           begin
			if ipno < ipfrom  then
				high := mid - 1
			 else
				low := mid + 1;
			end;
    end;
	end;
end;

function IP2Location_get_ipv6_record(loc:TIP2Location;ip:PChar;mode:DWORD):TIP2LocationRecord;
var
dbtype:byte;
handle:integer;
baseaddr,dbcount,dbcolumn,low,
high,mid:cardinal;
ipno,ipfrom,ipto:mp_int;
begin
 dbtype:= loc.databasetype;
 handle:= loc.filehandle;
 baseaddr:= loc.databaseaddr;
 dbcount:= loc.databasecount;
 dbcolumn:= loc.databasecolumn;
 low:= 0;
 high:= dbcount;
 mid:= 0;
 result :=IP2Location_new_record();
 with result do
	  begin
	  if not(IP2Location_ip_is_ipv6(ip))  then
	  begin
	  country_short:= INVALID_IPV6_ADDRESS;
		country_long:= INVALID_IPV6_ADDRESS;
		region:= INVALID_IPV6_ADDRESS;
		city:= INVALID_IPV6_ADDRESS;
		isp:= INVALID_IPV6_ADDRESS;
		latitude:= 0;
		longitude:= 0;
		domain:= INVALID_IPV6_ADDRESS;
		zipcode:= INVALID_IPV6_ADDRESS;
		timezone:= INVALID_IPV6_ADDRESS;
		netspeed:= INVALID_IPV6_ADDRESS;
		iddcode:= INVALID_IPV6_ADDRESS;
		areacode:= INVALID_IPV6_ADDRESS;
		weatherstationcode:= INVALID_IPV6_ADDRESS;
		weatherstationname:= INVALID_IPV6_ADDRESS;
		mcc:= INVALID_IPV6_ADDRESS;
		mnc:= INVALID_IPV6_ADDRESS;
		mobilebrand:= INVALID_IPV6_ADDRESS;
		elevation:= 0;
		usagetype:= INVALID_IPV6_ADDRESS;
		exit;
	   end;
     ipfrom:=mp_int_alloc;
     ipto:=mp_int_alloc;
	   mp_int_init(ipfrom);
	   mp_int_init(ipto);
     ipno:= IP2Location_ipv6_to_no(ip);
	  while (low <=high) do
	   begin
	   mid := (low + high) div 2;
	   mp_int_read_string(ipfrom, 10, IP2Location_read128(handle, baseaddr + mid * (dbcolumn * 4 + 12)));
	   mp_int_read_string(ipto, 10, IP2Location_read128(handle, baseaddr + (mid + 1) * (dbcolumn * 4 + 12)));
       if (mp_int_compare(ipno,ipfrom)>=0) and (mp_int_compare(ipno,ipto)<0) then
       begin
       if ((mode and _COUNTRYSHORT)>0) and (COUNTRY_POSITION[dbtype]<>0) then
			country_short:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + mid * (dbcolumn * 4 + 12) + 12 + 4 * (COUNTRY_POSITION[dbtype]-1)))
			 else
			country_short:=NOT_SUPPORTED;
			if ((mode and _COUNTRYLONG)>0) and (COUNTRY_POSITION[dbtype]<>0) then
			country_long:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + mid * (dbcolumn * 4 + 12) + 12 + 4 * (COUNTRY_POSITION[dbtype]-1))+3)
			else 
			country_long:=NOT_SUPPORTED;
			

			if ((mode and _REGION)>0) and (REGION_POSITION[dbtype]<>0) then
				region:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + mid * (dbcolumn * 4 + 12) + 12 + 4 * (REGION_POSITION[dbtype]-1)))
			 else 
				region:=NOT_SUPPORTED;
			

			if ((mode and _CITY)>0) and (CITY_POSITION[dbtype]<>0) then
				city:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + mid * (dbcolumn * 4 + 12) + 12 + 4 * (CITY_POSITION[dbtype]-1)))
			 else
				city:=NOT_SUPPORTED;
			

			if ((mode and _ISP)>0) and (ISP_POSITION[dbtype]<>0) then
				isp:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + mid * (dbcolumn * 4 + 12) + 12 + 4 * (ISP_POSITION[dbtype]-1)))
			 else 
				isp:=NOT_SUPPORTED;
			

			if ((mode and _LATITUDE)>0) and (LATITUDE_POSITION[dbtype]<>0) then
				latitude:=IP2Location_readFloat(handle, baseaddr + mid * (dbcolumn * 4 + 12) + 12 + 4 * (LATITUDE_POSITION[dbtype]-1))
			 else 
				latitude:=0.0;
			

			if ((mode and _LONGITUDE)>0) and (LONGITUDE_POSITION[dbtype]<>0) then
				longitude:=IP2Location_readFloat(handle, baseaddr + mid * (dbcolumn * 4 + 12) + 12 + 4 * (LONGITUDE_POSITION[dbtype]-1))
			 else 
				longitude:=0.0;
			
			if ((mode and _DOMAIN)>0) and (DOMAIN_POSITION[dbtype]<>0) then
				domain:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + mid * (dbcolumn * 4 + 12) + 12 + 4 * (DOMAIN_POSITION[dbtype]-1)))
			 else
				domain:=NOT_SUPPORTED;
			
			if ((mode and _ZIPCODE)>0) and (ZIPCODE_POSITION[dbtype]<>0) then
				zipcode:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + mid * (dbcolumn * 4 + 12) + 12 + 4 * (ZIPCODE_POSITION[dbtype]-1)))
			 else 
				zipcode:=NOT_SUPPORTED;
						
			if ((mode and _TIMEZONE)>0) and (TIMEZONE_POSITION[dbtype]<>0) then
				timezone:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + mid * (dbcolumn * 4 + 12) + 12 + 4 * (TIMEZONE_POSITION[dbtype]-1)))
			 else 
				timezone:=NOT_SUPPORTED;
			
			if ((mode and _NETSPEED)>0) and (NETSPEED_POSITION[dbtype]<>0) then
				netspeed:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + mid * (dbcolumn * 4 + 12) + 12 + 4 * (NETSPEED_POSITION[dbtype]-1)))
			 else 
				netspeed:=NOT_SUPPORTED;
				
			if ((mode and _IDDCODE)>0) and (IDDCODE_POSITION[dbtype]<>0) then
				iddcode:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + mid * (dbcolumn * 4 + 12) + 12 + 4 * (IDDCODE_POSITION[dbtype]-1)))
			 else 
				iddcode:=NOT_SUPPORTED;
			
			if ((mode and _AREACODE)>0) and (AREACODE_POSITION[dbtype]<>0) then
				areacode:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + mid * (dbcolumn * 4 + 12) + 12 + 4 * (AREACODE_POSITION[dbtype]-1)))
			 else 
				areacode:=NOT_SUPPORTED;
			
			if ((mode and _WEATHERSTATIONCODE)>0) and (WEATHERSTATIONCODE_POSITION[dbtype]<>0) then
				weatherstationcode:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + mid * (dbcolumn * 4 + 12) + 12 + 4 * (WEATHERSTATIONCODE_POSITION[dbtype]-1)))
			 else 
				weatherstationcode:=NOT_SUPPORTED;
			
			if ((mode and _WEATHERSTATIONNAME)>0) and (WEATHERSTATIONNAME_POSITION[dbtype]<>0) then
				weatherstationname:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + mid * (dbcolumn * 4 + 12) + 12 + 4 * (WEATHERSTATIONNAME_POSITION[dbtype]-1)))
			 else 
				weatherstationname:=NOT_SUPPORTED;
			
			if ((mode and _MCC)>0) and (MCC_POSITION[dbtype]<>0) then
				mcc:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + mid * (dbcolumn * 4 + 12) + 12 + 4 * (MCC_POSITION[dbtype]-1)))
			 else 
				mcc:=NOT_SUPPORTED;
			
			if ((mode and _MNC)>0) and (MNC_POSITION[dbtype]<>0) then
				mnc:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + mid * (dbcolumn * 4 + 12) + 12 + 4 * (MNC_POSITION[dbtype]-1)))
			 else 
				mnc:=NOT_SUPPORTED;
			
			if ((mode and _MOBILEBRAND)>0) and (MOBILEBRAND_POSITION[dbtype]<>0) then
				mobilebrand:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + mid * (dbcolumn * 4 + 12) + 12 + 4 * (MOBILEBRAND_POSITION[dbtype]-1)))
			 else 
				mobilebrand:=NOT_SUPPORTED;
			
			if ((mode and _ELEVATION)>0) and (ELEVATION_POSITION[dbtype]<>0) then
				elevation:=IP2Location_readFloat(handle, baseaddr + mid * (dbcolumn * 4 + 12) + 12 + 4 * (ELEVATION_POSITION[dbtype]-1))
			 else 
				elevation:=0.0;
						
			if ((mode and _USAGETYPE)>0) and (USAGETYPE_POSITION[dbtype]<>0) then
				usagetype:=IP2Location_readStr(handle, IP2Location_read32(handle, baseaddr + mid * (dbcolumn * 4 + 12) + 12 + 4 * (USAGETYPE_POSITION[dbtype]-1)))
			 else 
				usagetype:=NOT_SUPPORTED;
			
			exit;
        end
       else
 	   begin
	   if  mp_int_compare(ipno,ipfrom)<0 then 
				high:=mid-1 
				else 
				low:=mid+1;
	   end;
	   end;
	
	country_short:='-';
	country_long:='-';
	region:='-';
	city:='-';
	isp:='-';
	latitude:= 0;
	longitude:= 0;
	domain:='-';
	zipcode:='-';
	timezone:='-';
	netspeed:='-';
	iddcode:='-';
	areacode:='-';
	weatherstationcode:='-';
	weatherstationname:='-';
	mcc:='-';
	mnc:='-';
	mobilebrand:='-';
	elevation:= 0;
	usagetype:='-';

	 
	 end;

end;


// Description: Open the IP2Location database file
function IP2Location_open(db:PChar):TIP2Location;
var f:integer;
begin
 f:=FileOpen(db,fmOpenRead);
 if  f <> INVALID_HANDLE_VALUE then
  begin
   result.filehandle:=f;
   IP2Location_initialize(result);
  end;
end;

//Description: This function to set the DB access type.
function IP2Location_open_mem(loc:TIP2Location;mtype:TIP2Location_mem_type):integer;
begin
result:=-1;
if (loc.filehandle <>0) and not(openMemFlag) then
 begin
 openMemFlag:=True;
  case mtype of
   IP2LOCATION_FILE_IO      :result:=0;//Just return, by default its IP2LOCATION_FILE_IO
   IP2LOCATION_CACHE_MEMORY :result:=IP2Location_DB_set_memory_cache(loc.filehandle);
   IP2LOCATION_SHARED_MEMORY:result:=IP2Location_DB_set_shared_memory(loc.filehandle);
  end;
 end;
end;

// Description: Close the IP2Location database file
function IP2Location_close(loc:TIP2Location):DWORD;
begin
openMemFlag:=False;
 if loc.filehandle<>0 then
   IP2Location_DB_close(loc.filehandle);
result:=0;
end;

// Description: Get country code
function IP2Location_get_country_short(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
begin
if loc.ipversion=IPV6 then
 result:=IP2Location_get_ipv6_record(loc, ip, _COUNTRYSHORT)
else
 result:=IP2Location_get_record(loc, ip, _COUNTRYSHORT);
end;

// Description: Get country name
function IP2Location_get_country_long(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
begin
if loc.ipversion=IPV6 then
 result:=IP2Location_get_ipv6_record(loc, ip, _COUNTRYLONG)
else 
 result:=IP2Location_get_record(loc, ip, _COUNTRYLONG);
end;

// Description: Get the name of state/region
function IP2Location_get_country_region(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
begin
if loc.ipversion=IPV6 then
 result:=IP2Location_get_ipv6_record(loc, ip, _REGION)
else 
 result:=IP2Location_get_record(loc, ip, _REGION);
end;

// Description: Get city name
function IP2Location_get_country_city(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
begin
if loc.ipversion=IPV6 then
 result:=IP2Location_get_ipv6_record(loc, ip, _CITY)
else 
 result:=IP2Location_get_record(loc, ip, _CITY);
end;

// Description: Get ISP name
function IP2Location_get_country_isp(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
begin
if loc.ipversion=IPV6 then
 result:=IP2Location_get_ipv6_record(loc, ip, _ISP)
else 
 result:=IP2Location_get_record(loc, ip, _ISP);
end;

// Description: Get latitude
function IP2Location_get_country_latitude(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
begin
if loc.ipversion=IPV6 then
 result:=IP2Location_get_ipv6_record(loc, ip, _LATITUDE)
else 
 result:=IP2Location_get_record(loc, ip, _LATITUDE);
end;

// Description: Get longitude
function IP2Location_get_country_longitude(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
begin
if loc.ipversion=IPV6 then
 result:=IP2Location_get_ipv6_record(loc, ip, _LONGITUDE)
else 
 result:=IP2Location_get_record(loc, ip, _LONGITUDE);
end;

// Description: Get domain name
function IP2Location_get_country_domain(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
begin
if loc.ipversion=IPV6 then
 result:=IP2Location_get_ipv6_record(loc, ip, _DOMAIN)
else 
 result:=IP2Location_get_record(loc, ip, _DOMAIN);
end;

// Description: Get ZIP code
function IP2Location_get_country_zipcode(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
begin
if loc.ipversion=IPV6 then
 result:=IP2Location_get_ipv6_record(loc, ip, _ZIPCODE)
else 
 result:=IP2Location_get_record(loc, ip, _ZIPCODE);
end;

// Description: Get time zone
function IP2Location_get_country_timezone(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
begin
if loc.ipversion=IPV6 then
 result:=IP2Location_get_ipv6_record(loc, ip, _TIMEZONE)
else 
 result:=IP2Location_get_record(loc, ip, _TIMEZONE);
end;

// Description: Get net speed
function IP2Location_get_country_netspeed(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
begin
if loc.ipversion=IPV6 then
 result:=IP2Location_get_ipv6_record(loc, ip, _NETSPEED)
else 
 result:=IP2Location_get_record(loc, ip, _NETSPEED);
end;

// Description: Get IDD code
function IP2Location_get_country_iddcode(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
begin
if loc.ipversion=IPV6 then
 result:=IP2Location_get_ipv6_record(loc, ip, _IDDCODE)
else 
 result:=IP2Location_get_record(loc, ip, _IDDCODE);
end;

// Description: Get area code
function IP2Location_get_country_areacode(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
begin
if loc.ipversion=IPV6 then
 result:=IP2Location_get_ipv6_record(loc, ip, _AREACODE)
else 
 result:=IP2Location_get_record(loc, ip, _AREACODE);
end;

// Description: Get weather station code
function IP2Location_get_country_weatherstationcode(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
begin
if loc.ipversion=IPV6 then
 result:=IP2Location_get_ipv6_record(loc, ip, _WEATHERSTATIONCODE)
else 
 result:=IP2Location_get_record(loc, ip, _WEATHERSTATIONCODE);
end;

// Description: Get weather station name
function IP2Location_get_country_weatherstationname(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
begin
if loc.ipversion=IPV6 then
 result:=IP2Location_get_ipv6_record(loc, ip, _WEATHERSTATIONNAME)
else 
 result:=IP2Location_get_record(loc, ip, _WEATHERSTATIONNAME);
end;

// Description: Get mobile country code
function IP2Location_get_country_mcc(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
begin
if loc.ipversion=IPV6 then
 result:=IP2Location_get_ipv6_record(loc, ip, _MCC)
else 
 result:=IP2Location_get_record(loc, ip, _MCC);
end;

// Description: Get mobile national code
function IP2Location_get_country_mnc(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
begin
if loc.ipversion=IPV6 then
 result:=IP2Location_get_ipv6_record(loc, ip, _MNC)
else 
 result:=IP2Location_get_record(loc, ip, _MNC);
end;

// Description: Get mobile carrier brand
function IP2Location_get_country_mobilebrand(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
begin
if loc.ipversion=IPV6 then
 result:=IP2Location_get_ipv6_record(loc, ip, _MOBILEBRAND)
else 
 result:=IP2Location_get_record(loc, ip, _MOBILEBRAND);
end;

// Description: Get elevation
function IP2Location_get_country_elevation(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
begin
if loc.ipversion=IPV6 then
 result:=IP2Location_get_ipv6_record(loc, ip, _ELEVATION)
else 
 result:=IP2Location_get_record(loc, ip, _ELEVATION);
end;

// Description: Get usage type
function IP2Location_get_country_usagetype(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
begin
if loc.ipversion = IPV6 then
 result:=IP2Location_get_ipv6_record(loc, ip, _USAGETYPE)
else 
 result:=IP2Location_get_record(loc, ip, _USAGETYPE);
end;

// Description: Get all records
function IP2Location_get_country_all(loc:TIP2Location;ip:PChar):TIP2LocationRecord;
begin
if loc.ipversion = IPV6 then
 result:=IP2Location_get_ipv6_record(loc, ip, _ALL)
else 
 result:=IP2Location_get_record(loc, ip, _ALL);
end;

procedure IP2Location_free_record(_record:TIP2LocationRecord);
begin
end;

end.