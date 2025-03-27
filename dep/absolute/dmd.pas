unit dmd;

interface

uses
  {$ifdef INSPECT}
  siAuto,graphics,
  {$endif}
  SysUtils, Classes, DB, ABSMain,
  aEngine,kbmMemTable;

(*
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
   IdSyn        : integer;
   Ord          : integer;
   User       : string;
   DownloadTime : TDateTime;
end;
*)

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
   IdSyn        : integer;
   Ord          : integer;
   User       : string;
   PointCount   : integer;
   DownloadTime : TDateTime;
end;



type
  TDmd = class(TDataModule)
    absMain: TABSDatabase;
    absQuery: TABSQuery;
    absPOINT: TABSTable;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    fPort     : integer;
    fRouteIdx : string;
    fEngine   : TEngine;
    fDataPath : string;
    fTextPath : string;

    fFindRoute  : boolean;
    fSaveFolder : string;
    fSaveToTxt  : boolean;

    procedure LoadTables(ADataPath: string);
    procedure SetDataPath(const Value: string);
    procedure SetOutputPath(const Value: string);
    procedure LoadRoute;

    procedure SetFindRoute(const Value: boolean);
    procedure SetSaveToTxt(const Value: boolean);
    procedure SaveToFolder(const Value: string);

  public
    { Public declarations }
    procedure LoadTabs;

    property Port       : integer read fPort write fPort;
    property DataPath   : string read fDataPath write SetDataPath;
    property TextPath   : string read fTextPath write SetOutputPath;
    property Engine     : TEngine read fEngine write fEngine;

    property FindRoute   : boolean read fFindRoute write SetFindRoute;
    property SaveToTxt   : boolean read fSaveToTxt write SetSaveToTxt;
    property SaveFolder  : string  read fSaveFolder write SaveToFolder;

  end;

var
  fDmd: TDmd;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}


procedure TDmd.SetOutputPath(const Value: string);
begin
  fTextPath := Value;
end;


procedure TDmd.SetSaveToTxt(const Value: boolean);
begin
  fSaveToTxt := Value;
end;

// natahni potrebne tabulky do cache
procedure TDmd.DataModuleCreate(Sender: TObject);
begin
  inherited;
  fEngine := nil;
end;


(*
procedure Tdmd.DoReloadRoute(Sender : TObject);
begin
  LoadRoute;
end;
*)

procedure Tdmd.LoadRoute;
begin
    // natahni tabulku sensoru
  absQuery.Active := false;
  absQuery.SQL.Text :=
  'select ROUTE.ID AS ROUTEID,ROUTE.NAME as ROUTENAME,ROUTE.SETTINGS,'+
  'POINT.NAME AS NAMEPOINT,POINT.CHIP,ROUTEPOINTS.ORDEN AS ORD ,POINT FROM ROUTEPOINTS '+
  'right join ROUTE on ROUTE.ID=ROUTEPOINTS.ROUTE  '+
  'right join POINT on POINT.ID=ROUTEPOINTS.POINT  '+
  'where ROUTE.VALID_TO IS NULL order by ROUTE.ID, ROUTEPOINTS.ORDEN  ';
  absQuery.Active := true;
  fEngine.Route := absQuery;
end;

procedure Tdmd.LoadTabs;
begin
   // natahni tabulku bodu
  absQuery.Active := false;
  absQuery.SQL.Text := 'select * from POINT where VALID_TO is NULL';
  absQuery.Active := true;
  fEngine.Point := absQuery;

  // natahni tabulku sensoru
  absQuery.Active := false;
  absQuery.SQL.Text := 'select * from SENSOR where VALID_TO is NULL';
  absQuery.Active := true;
  fEngine.Sensor := absQuery;

  // natahni tabulku strazniku
  absQuery.Active := false;
  absQuery.SQL.Text := 'select * from GUARD where VALID_TO is NULL';
  absQuery.Active := true;
  fEngine.Guard   := absQuery;

  LoadRoute;

  {$ifdef INSPECT}
  siMain.LogColored(clMoneyGreen,'Reloading tables');
  {$endif}
end;


procedure Tdmd.LoadTables(ADataPath : string);
begin
  //
  if not Assigned(fEngine) then
    raise Exception.Create('fEngine class was not initialized');

  absMain.Connected := false;
  absMain.DatabaseFileName := fDataPath + '\winkontrol.abs';
  absMain.Connected:=true;

  LoadTabs;

  {$ifdef INSPECT}
  siMain.logDataSet('fkRoute',fEngine.Route);
  {$endif}
end;


procedure TDmd.SaveToFolder(const Value: string);
begin
  fSaveFolder := Value;
end;

procedure TDmd.SetDataPath(const Value: string);
begin
  fDataPath := Value;
  {$ifdef INSPECT}
  siMain.logMessage('fdataPath: '+fDataPath);

  {$endif}

  // natahneme do cache tabulku bodu
  LoadTables(Value);
end;



procedure TDmd.SetFindRoute(const Value: boolean);
begin
  fFindRoute := Value;
end;

end.
