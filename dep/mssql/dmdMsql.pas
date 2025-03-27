unit dmdMsql;

interface

uses
  aEngine,
  {$ifdef INSPECT}
    siAuto,graphics,
  {$endif}
  System.Generics.Collections,
  iniFiles, kbmMemTable,
  System.SysUtils, System.Classes,Data.DB,
  Vcl.ExtCtrls, UniProvider, SQLServerUniProvider,
  DBAccess, UniDacVcl, MemDS, Uni, OracleUniProvider;

type RProvider=(pNone,pMsSql,pOracle);

type RLPoint=record
   typ        : byte;
   info       : byte;
   dt         : TDateTime;
   chip       : string;
   sensorId   : integer;
   SensorName : string;
   ChipName   : string;
   ChipId     : integer;

   // nove vlastnosti
   IdSyn,RpSyn  : integer;
   Ord          : integer;
   User       : string;
   PointCount   : integer;
   DownloadTime : TDateTime;
   mac : string;
end;


type TDevState=(stConnecting,stConnected,stConnectError);

//type  TOnState(Sender: TObject; DevState : TState; const MSG: string) of object;
type TOnState=procedure(Sender : TObject; DevState : TDevState; AMsg : string) of object;

type
  Tdmd = class(TDataModule)
    fTimer    : TTimer;
    uniConn   : TUniConnection;
    uniQuery  : TUniQuery;
    uniDialog : TUniConnectDialog;
    sqlMicrosoft: TSQLServerUniProvider;
    sqlOracle: TOracleUniProvider;
    procedure DataModuleCreate(Sender: TObject);
    procedure fTimerTimer(Sender: TObject);
  private
    { Private declarations }
    fOnState : TOnState;
    fMessage : string;
    fDevState : TDevState;

    fPort : integer;
    fTextPath: string;
    fDataPath: string;
    fEngine: TEngine;

    // zdrojova databaze s daty
    fServer   : string;
    fServerPort: integer;
    fLogin    : string;
    fPassword : string;
    fDatabase : string;
    fLoginPrompt : boolean;

    // broker databaze pro prehazovani dat
    fBrokerServer : String;
    fBrokerPort: integer;
    fBrokerLogin: string;
    fBrokerPassword: string;
    fBrokerDatabase : string;
    fBrokerLoginPrompt  : boolean;


    fFindRoute: boolean;
    fSaveFolder: string;
    fSaveToTxt: boolean;
    fProvider: RProvider;

    procedure SetDataPath(const Value: string);
    procedure SetEngine(const Value: TEngine);
    function  formatMSDate(ADate: TDateTime): string;
    function  ConnectDataBase: boolean;
    procedure LogMsg(Sender: TObject; DevState: TDevState; msg: string);
    procedure logMsgSyn;
    procedure SetFindRoute(const Value: boolean);
    procedure SetSaveToFolder(const Value: string);
    procedure SetSaveToTxt(const Value: boolean);
    procedure SetServer(const Value: string);
    procedure SetProvider(const Value: string);
    function GetProvider: string;
    procedure SetServerPort(const Value: integer);
    procedure AddATV(APoint: rLPoint);
    procedure GetTextPath(const Value: string);
    function MasterSynPR(const AUser: string): integer;

  //  procedure DoMsqlDataSet(ASql : string; var ATable : TkbmMemTable);
  public
    { Public declarations }
    function  CheckMissing(const Adapt: string): integer;
    procedure LoadTables(const Value: string);
    procedure EqMS(ASql: string);
    procedure EqDataSet(ASql: string; var ATable: TkbmMemTable);

    procedure CreateClass;
    function  MasterSynPP(const ATypSyn: integer): integer;  // novy download ze vzdaleneho zdroje
    procedure AddPoint(APoint: rLPoint);                     // pridej novy bod do databaze
    function  MaxId: integer;
    function  IsSQLConnected: boolean;


    property  Engine   : TEngine read fEngine write SetEngine;
    property  TextPath : string read fTextPath write GetTextPath;
    property  DataPath : string read fDataPath write SetDataPath;
   // property  Port : integer read fPort write fPort;

    // sekce databazi ORACLE a MSSQL
    property Server : string read fServer write SetServer;
    property Login  : string read fLogin  write fLogin;
    property Password: string read fPassword write fPassword;
    property Database : string read fDatabase write fDatabase;
    property LoginPrompt : boolean read fLoginPrompt write fLoginPrompt;
    property ServerPort : integer read fServerPort write SetServerPort;
    property Provider : string read GetProvider write SetProvider;

    // sekce broker databaze
    property BrokerServer : string read fBrokerServer write fBrokerServer;
    property BrokerLogin : string read fBrokerLogin  write fBrokerLogin;
    property BrokerPassword: string read fBrokerPassword write fBrokerPassword;
    property BrokerDatabase : string read fBrokerDatabase write fBrokerDataBase;
    property BrokerPort  : integer read fBrokerPort write fBrokerPort;
    property BrokerLoginPrompt: boolean read fBrokerLoginPrompt write fBrokerLoginPrompt;

    // sekce FUNCTION
    property FindRoute   : boolean read fFindRoute write SetFindRoute;
    property SaveToTxt   : boolean read fSaveToTxt write SetSaveToTxt;
    property SaveFolder  : string  read fSaveFolder write SetSaveToFolder;

    // callbacky ven
    property  OnState : TOnState read fOnState write fOnState;



  end;

var
  fdmd: Tdmd;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ Tdmd }

procedure Tdmd.CreateClass;
var sql : string;
begin
  inherited;
end;


// vezme tabulku REPO a vyrobi k ni string;
procedure Tdmd.EqMS(ASql: string);
var
 s : string;
begin
  try
    uniQuery.Active := false;
    uniQuery.SQL.Text := ASql;
    uniQuery.ExecSQL;
  except
    on E: Exception do
    begin
      s := format('Tdmd.eqMs error: %s',[e.Message]);
      LogMsg(self,stConnectError,s);
      {$IFDEF INSPECT}
        SiMain.LogColored(clRed,s);
      {$endif}
    end;
  end;
end;


procedure Tdmd.EqDataSet(ASql : string; var ATable :TkbmMemTable);
begin
  eqMs(ASql);
  ATable.loadFromDataSet(uniQuery,[mtcpoStructure,mtcpoProperties]);
end;


function Tdmd.MaxId  : integer;
var
  sql : string;
begin
  Result := -1;
  sql    := 'select max(idSyn) as maxSyn from [dbo].REPX';
  eqMs(sql);

  if not uniQuery.IsEmpty then
    Result := uniQuery.FieldByName('maxSyn').asInteger;
end;


function Tdmd.MasterSynPP(const ATypSyn : integer): integer;
var sql : string;
begin
  Result := -1;
  sql := format('insert into SYNMASTER (typSyn,CLID) values (%d,%d)',[ATypSyn,0]);
  eqMs(sql);
  //fQuery.Active := false;
  //fQuery.Sql.Text := sql;
  //fQuery.ExecSQL;

  //fQuery.Active:= false;
  sql := 'select max(idSyn) as maxSyn from SYNMASTER';
  eqMs(sql);
  //fQuery.Sql.Text := sql;
  //fQuery.Open;
  //Result := fQuery.FieldByName('maxSyn').AsInteger;
  Result := uniQuery.FieldByName('maxSyn').asInteger;
end;

// druha verzi master tabulky
// pouziju konecne client id pro zarazeni
function Tdmd.MasterSynPR(const AUser: string): integer;
var
  sql : string;
begin
  Result := -1;
  sql := format('insert into SYNMASTER (typSyn,CLID) values (%d,%d)',[AUser,0]);
  eqMs(sql);
end;


// vraci posledni chybejici zaznam za poslednich 14 dnu
function Tdmd.CheckMissing(const Adapt: string): integer;
var
  sql: string;
  id,iBef,i,j,iFirst: Integer;
  iArr : TList<Integer>;
  finish: boolean;
begin
  // vyberu vsechny cisla lokalnich synchronizaci pro [create_user], to je zkriplene cislo adapteru
  //sql := format('select distinct id from REPX where [CREATE_USER] like ''%s'' ',[Adapt]);
  try
    sql := format('SELECT DISTINCT TOP(10) ID FROM REPX WHERE [CREATE_USER] LIKE ''%s''  ORDER BY ID DESC',[Adapt]);
    EqMS(sql);

    // vysledek je v uniQuery, zajima me jenom sloupec "ID"
    Result := 0;
    if (uniQuery.FieldCount<=0) then
      exit;

    // projdi vsechny lokalni synchronizace z repx a hledej diry
    uniQuery.First;
    iBef := uniQuery.FieldByName('id').AsInteger;
    iFirst := iBef;
    uniQuery.Next;

    // tabulka je sestupne
    finish := false;
    iArr := TList<Integer>.Create;
    while not uniQuery.EOF and not Finish do
    begin
      id := uniQuery.FieldByName('ID').AsInteger;
      i  := iBef-id;
      if (i>1) then
      begin
        //for j := id+1 to iBef-1 do
        //   iArr.Add(j);
        for j := iBef-1 downto id+1 do
            iArr.add(j);
      end;
      iBef := id;

      i := iFirst-iBef;
      finish := i>10;
      uniQuery.Next;
    end;

    if iArr.Count>0 then
      Result := iArr[0];


  except
    on E: Exception do
    begin
      siMain.LogColored(clRed,'Chyba v TDM.CheckMissing')
    end;


  end;
end;


function Tdmd.formatMSDate(ADate: TDateTime): string;
var
  s: string;
begin

   if ADate < 1 then
   begin
      Result := 'NULL' ;
      exit;
   end;

  Result := FormatDateTime('yyyy-mm-dd hh:nn:ss', ADate);
  Result := format('CONVERT(datetime, ''%s'', 120)', [Result])
end;


// poskladam sql string do MSSQL
procedure Tdmd.AddPoint(APoint : rLPoint);
var sql : string;
begin
  sql := format(
        'INSERT INTO REPX (SENSORID, idSyn, DOWNLOAD, ORDEN, [NAME], CHIP, [TYPE], INFO, TOUCH, [CREATE_USER], [ID]) VALUES  '
          + '(%d,%d,%s,%d,''%s'',''%s'',%d,%d,%s,''%s'',%d )',
        [APoint.sensorId, APoint.IdSyn, formatMSDate(APoint.DownloadTime), APoint.Ord, APoint.ChipName, APoint.Chip,
        APoint.typ, APoint.Info, formatMSDate(APoint.dt), APoint.User,APoint.rpSyn]);

 // fQuery.Active := false;
 // fQuery.SQL.Text := sql;
 // fQuery.ExecSQL;
 eqMs(sql);
end;

procedure Tdmd.AddATV(APoint : rLPoint);
var sql : string;
begin
  sql := format(
        'INSERT INTO REPX (SENSORID, idSyn, DOWNLOAD, ORDEN, [NAME], CHIP, [TYPE], INFO, TOUCH, [CREATE_USER],[ID]) VALUES  '
          + '(%d,%d,%s,%d,''%s'',''%s'',%d,%d,%s,''%s'',%d )',
        [APoint.sensorId, APoint.IdSyn, formatMSDate(APoint.DownloadTime), APoint.Ord, APoint.ChipName, APoint.Chip,
        APoint.typ, APoint.Info, formatMSDate(APoint.dt), APoint.User,APoint.RpSyn]);

 // fQuery.Active := false;
 // fQuery.SQL.Text := sql;
 // fQuery.ExecSQL;
 eqMs(sql);
end;

procedure Tdmd.LoadTables(const Value: string);
var sql : string;
begin
  //
  //fQuery.Active := false;
  //fQuery.SQL.Text := 'select * from POINT where VALID_TO is NULL';
  //fQuery.Active:=true;
  //fEngine.Point := fQuery;
  sql := 'select * from POINT where VALID_TO IS NULL';
  eqMs(sql);
  fEngine.Point := uniQuery;

  // natahni tabulku sensoru
  //fQuery.Active := false;
  //fQuery.SQL.Text := 'select * from SENSOR where VALID_TO is NULL';
  //fQuery.Active := true;
  //fEngine.Sensor := fQuery;
  sql := 'select * from SENSOR where VALID_TO is NULL';
  eqMs(Sql);
  fEngine.Sensor := uniQuery;


  // natahni tabulku strazniku
  //fQuery.Active := false;
  //fQuery.SQL.Text := 'select * from GUARD where VALID_TO is NULL';
  //fQuery.Active := true;
  //fEngine.Guard   := fQuery;
  sql := 'select * from GUARD where VALID_TO is NULL';
  eqMs(sql);
  fEngine.Guard := uniQuery;


  // natahni trasy
  (*
  fQuery.Active := false;
  fQuery.SQL.Text :=
  'select ROUTE.ID AS ROUTEID,ROUTE.NAME as ROUTENAME,ROUTE.SETTINGS,'+
  'POINT.NAME AS NAMEPOINT,POINT.CHIP,ROUTEPOINTS.ORDEN AS ORD ,POINT FROM ROUTEPOINTS '+
  'right join ROUTE on ROUTE.ID=ROUTEPOINTS.ROUTE  '+
  'right join POINT on POINT.ID=ROUTEPOINTS.POINT  '+
  'where ROUTE.VALID_TO IS NULL order by ROUTE.ID, ROUTEPOINTS.ORDEN  ';
  fQuery.Active := true;
  fEngine.Route := fQuery;
  *)
  // natazeni tras
  sql :=
  'select ROUTE.ID AS ROUTEID,ROUTE.NAME as ROUTENAME,ROUTE.SETTINGS,'+
  'POINT.NAME AS NAMEPOINT,POINT.CHIP,ROUTEPOINTS.ORDEN AS ORD ,POINT FROM ROUTEPOINTS '+
  'right join ROUTE on ROUTE.ID=ROUTEPOINTS.ROUTE  '+
  'right join POINT on POINT.ID=ROUTEPOINTS.POINT  '+
  'where ROUTE.VALID_TO IS NULL order by ROUTE.ID, ROUTEPOINTS.ORDEN  ';
  eqMs(sql);
  fEngine.Route := uniQuery;


  // natahni eventy
  sql :=
  'select * from EVENT where VALID_TO is NULL';
  eqMs(sql);
  fEngine.Event := uniQuery;

end;


procedure TDmd.LogMsg(Sender: TObject; DevState : TDevState; msg: string);
begin
  fDevState := DevState;
  fMessage := msg;
 // Synchronize(LogMsgSyn);
  LogMsgSyn;
end;

procedure TDmd.logMsgSyn;
begin
  if Assigned(fOnState) then
    fOnState(self,fDevState,fMessage);
end;




procedure Tdmd.DataModuleCreate(Sender: TObject);
var AppIni : TIniFile;
    Path   : string;
    Provider : string;
begin
  //inherited;
  fEngine := nil;


  {$ifNdef SERVICE}
    // musim inicializovat, kdyz nemam nastartovany pool
    Path :=  ExtractFilePath(ParamStr(0))+'mz.ini';
    AppIni        := TIniFile.Create(Path);
    with AppIni do begin

      // o jaky stroj se jedna
      Provider := ReadString('PROVIDER','Provider','MSSQL');
      if UpperCase(Provider)='ORACLE' then
      begin
        fServer   := ReadString('ORACLE','Server','127.0.0.1');
        fLogin    := ReadString('ORACLE','Login' ,'sa');
        fPassword := ReadString('ORACLE','Password' ,'tomstr26');
        fDatabase := ReadString('ORACLE','Database' ,'dpoint');
        fLoginPrompt:= ReadBool('ORACLE','LoginPrompt',false);
        fServerPort := ReadInteger('MSSQL','ServerPort',1521);

        uniconn.ProviderName := 'Oracle';
      end
      else if UpperCase(Provider)='MSSQL' then
      begin
        // sekce MSSQL
        fServer   := ReadString('MSSQL','Server','DPOINT-SERVER\NTAUTHORITY');
        fLogin    := ReadString('MSSQL','Login' ,'sa');
        fPassword := ReadString('MSSQL','Password' ,'123456789');
        fDatabase := ReadString('MSSQL','Database' ,'dpoint');
        fLoginPrompt:= ReadBool('MSSQL','LoginPrompt',false);
        fServerPort := ReadInteger('MSSQL','ServerPort',1433);

        uniconn.ProviderName := 'SQL Server';
      end;

      // sekce function
      fFindRoute  := ReadBool('FUNCTION','FindRoute',false);   // hledej trasu
      fSaveToTxt  := ReadBool('FUNCTION','SaveToTxt',false);   // data uloz do txt souboru
      fSaveFolder := ReadString('FUNCTION','SaveFolder','');   // uloz do adresare
      fTextPath   := ReadString('DB','OUTFOLDER','c:\temp');
    end;

     fTimer.Enabled:= false;
     Sleep(1000);
     if not ConnectDataBase then
     begin
       {$IFDEF INSPECT}
       SiMain.LogColored(clRed,'Nelze se pripojit k databazi');
       {$ENDIF}

       raise Exception.Create('Nelze se pripojit k databazi');
     end;
     fEngine := TEngine.Create;
  {$endif}

end;


function Tdmd.IsSQLConnected: boolean;
begin
  Result := uniConn.Connected;
end;


function Tdmd.ConnectDataBase : boolean;
var
  ConnectionString : string;
begin
   //Server=90.177.112.119\SQLTOMST
   //Database=raspberry
   //User_Name=sa
   //Password=tomstr26
  //DriverID=MSSQL
  try
    (*
    fdConnect.Close;
    fdConnect.Params.Clear;
    fdConnect.Params.Add('Server='+fServer);
    fdConnect.Params.Add('DataBase='+fDatabase);
    fdConnect.Params.Add('User_Name='+fLogin);
    fdConnect.Params.Add('Password='+fPassword);
    fdConnect.Params.Add('DriverID=MSSQL');
    fdConnect.Open;
    *)
    Result := true;
    {$ifdef INSPECT}
      ConnectionString := format('Server:%s,Database:%s,Login:%s,Password:%s,ServerPort:%d',[fServer,fDatabase,fLogin,fPassword,fServerPort]);
      siMain.LogMessage(ConnectionString);
    {$endif}

//    uniConn.Close;
    if fProvider=pOracle then
    begin
      //Provider Name=Oracle;Direct=True;Host=127.0.0.1;SID=XE;User ID=KRATA;Password=tomstr26;Schema=KRATA
     // ConnectionString := format('Provider Name=Oracle;Direct=True;Host=%s;SID=%s;User ID=%s;Password=%s;Schema=%s',
     // [
      uniconn.SpecificOptions.Values['Direct'] := 'True';
     // uniConn.SpecificOptions:=
      uniConn.ProviderName := 'Oracle'
    end
    else if fProvider=pMsSql then
      uniConn.ProviderName := 'SQL Server';

    uniConn.Server      := fServer;
    uniConn.Database    := fDatabase;
    uniConn.Username    := fLogin;
    uniConn.Password    := fPassword;
    uniConn.Port        := fServerPort;

    //uniDialog.UserName.Caption  := ini.DB.msSqllogin;
//    uniConn.LoginPrompt := true;
    uniConn.Open;
    uniConn.Connect;

  except
     {$ifdef INSPECT}
       siMain.LogColored(clRed,'Connect to database ERROR');
     {$endif}
     REsult := false;
  end;
end;

procedure Tdmd.fTimerTimer(Sender: TObject);
var msg : string;
begin
  fTimer.Enabled:= false;

  // nastav parametry z ini souboru
  ConnectDataBase;
  LoadTables(fDataPath);

  {$ifdef INSPECT}
   msg := format('.. pool %d created OK',[Tag]);
   if tag>0 then siMain.LogColored(clMoneyGreen,msg)
   else          siMain.LogMessage(msg);
   siMain.LogDataSet('...Table Point',fEngine.Point);
  {$endif}
end;



procedure Tdmd.SetDataPath(const Value: string);
begin
  fDataPath := Value;
  fTimer.Enabled:=true;
  // LoadTables(Value);
end;

procedure Tdmd.SetEngine(const Value: TEngine);
begin
  fEngine := Value;
end;

procedure Tdmd.SetFindRoute(const Value: boolean);
begin
  fFindRoute := Value;
end;

procedure Tdmd.SetProvider(const Value: string);
begin
  //
  if UpperCase(Value)='ORACLE' then
    fProvider := pOracle
  else if UpperCase(Value)='MSSQL' then
    fProvider := pMsSql
  else
    fProvider := pNone;
end;

function Tdmd.GetProvider: string;
begin
  if fProvider=pOracle then
    Result := 'Oracle'
  else if fProvider=pMsSql then
    Result := 'MsSql'
  else
    Result := 'Null';

end;

procedure Tdmd.GetTextPath(const Value: string);
begin
  fTextPath := Value;
end;

procedure Tdmd.SetSaveToFolder(const Value: string);
begin
  fSaveFolder := Value;
end;

procedure Tdmd.SetSaveToTxt(const Value: boolean);
begin
  fSaveToTxt := Value;
end;

procedure Tdmd.SetServer(const Value: string);
begin
  fServer := Value;
end;

procedure Tdmd.SetServerPort(const Value: integer);
begin
  fServerPort := Value;
end;

end.
