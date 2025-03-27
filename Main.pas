unit Main;

interface

uses
  Windows,Messages, SysUtils,
  {$IFDEF  DQUEUE}
    OtlContainerObserver,
    OtlComm,
    OtlCommon,
  {$endif}

  {$ifdef INSPECT}
    siAuto,graphics,
  {$endif}
    vVersionInfo,
    http, aPolo,
  {$ifdef MSQL}
    dmdMSql,
  {$else}
  dmd,
  {$endif}

  iniFiles, aEngine,forms, Classes, ActnList, Menus, ImgList, Controls,
  ExtCtrls, DB, DBCtrls,
  Grids, DBGrids, StdCtrls, ComCtrls, kbmMemTable, System.Actions,
  System.ImageList, Vcl.Buttons;

type
  TfMain = class(TForm)
    mainPanel: TPanel;
    dsGRID: TDataSource;
    kbSeq: TkbmMemTable;
    kbSeqpit: TAutoIncField;
    kbSeqPointId: TIntegerField;
    dsSq: TDataSource;
    dsScore: TDataSource;
    tim: TTimer;
    pgMain: TPageControl;
    tbLog: TTabSheet;
    tbRoute: TTabSheet;
    labRouteName: TLabel;
    btSaveLog: TButton;
    btParse: TButton;
    btRoutes: TButton;
    edRoute: TEdit;
    edTest: TEdit;
    btCopy: TButton;
    bSearch: TButton;
    PageControl1: TPageControl;
    tabGrid: TTabSheet;
    dgPoints: TDBGrid;
    tabRoute: TTabSheet;
    dgSeq: TDBGrid;
    DBNavigator1: TDBNavigator;
    tabScore: TTabSheet;
    DBGrid2: TDBGrid;
    tabREPX: TTabSheet;
    dsStatus: TDataSource;
    imgList: TImageList;
    ListBox: TListBox;
    Panel1: TPanel;
    pMain: TMainMenu;
    pfile: TMenuItem;
    pSaveLog: TMenuItem;
    pClear: TMenuItem;
    acList: TActionList;
    acSaveLog: TAction;
    acClear: TAction;
    lview: TListView;
    lbLive: TListBox;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    tabMiss: TTabSheet;
    btMissing: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btSaveLogClick(Sender: TObject);
    procedure btParseClick(Sender: TObject);
    procedure btRoutesClick(Sender: TObject);
    procedure dgPointsCellClick(Column: TColumn);
    procedure btCopyClick(Sender: TObject);
    procedure bSearchClick(Sender: TObject);
    procedure acSaveLogExecute(Sender: TObject);
    procedure acClearExecute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure btMissingClick(Sender: TObject);
  private
    { Private declarations }
    fEngine : TEngine;
    fDmd    : TDmd;
    fVersionInfo : TVVersionInfo;

    ffDataPath : string;
    fDaemonThread : TTcpHttpDaemon;
    fDlfName : string;
    fTextPath : string;

    procedure DoLogMsg(AMessage: String);
    procedure loadIni;
    procedure copyToSeq;
    function AcquireDmd: TDmd;
    procedure logMsg(AMsg: string);
    procedure DoHeartBeat(Sender: TThread; ABeacon: RBeacon);
    procedure TableToView(ADataSource: TDataSet);
    procedure HandleThreadData(Sender: TObject; const msg: TOmniMessage);
  public
    { Public declarations }
  end;

var
  fMain: TfMain;

implementation

{$R *.dfm}

procedure TfMain.acClearExecute(Sender: TObject);
begin
   listBox.Items.Clear;
end;

function  TfMain.AcquireDmd: TDmd;
var ob1 : TObject;
begin
  // chci naplnit formu
  ob1 := fPolo.Acquire;
  if not assigned(ob1) then
  begin
    {$ifdef INSPECT}
     siMain.LogColored(clGreen,'No object in poool');
    {$endif}
    exit;
  end;

  fDmd := ob1 as TDmd;
  REsult :=  fDmd;

end;


procedure TfMain.logMsg(AMsg : string);
begin
  //listBox.items.Clear;
  listBox.items.Add (AMsg);
  listBox.itemIndex:= listBox.Items.Count-1;
  Application.ProcessMessages;
end;


procedure TfMain.btRoutesClick(Sender: TObject);
begin
 AcquireDmd;
 fEngine := fDmd.Engine;

 if not Assigned(fEngine) then
    logMsg('Engine not assigned');

 fTextPath := fDmd.TextPath;

 fEngine.RouteIdx := '';
 dsGrid.DataSet := fEngine.Route;
end;

procedure TfMain.btSaveLogClick(Sender: TObject);
begin
  // uloz log
  listBox.Items.SaveToFile(fDlfName+'log.txt');
end;

procedure TfMain.acSaveLogExecute(Sender: TObject);
var Fmt,AFileName : string;
begin
  AFileName := fDaemonThread.OutFolder + 'listbox.txt';
  listBox.Items.SaveToFile(AFileName);

  Fmt := format('ListBox saved into folder: %s',[AFileName]);
  logMsg(Fmt);

end;

procedure TfMain.bSearchClick(Sender: TObject);
var aRoute : rRoute;
    bod  : integer;
begin
  aRoute:=fEngine.RouteDef[5];
  labRouteName.Caption := aRoute.RouteName;

  // ted mam v singleRoute definovanou trasu
  with fEngine do
  begin
    bod := 10;
    if not kSingleRoute.locate('POINT',bod,[]) then
      raise Exception.CreateFmt('Bod %d nenalezen',[bod]);
    kSingleRoute.Edit;
    kSingleroute.Delete;
    //kSingleRoute.Post;
    bod := 12;
    if not kSingleRoute.locate('POINT',bod,[]) then
      raise Exception.CreateFmt('Bod %d nenalezen',[bod]);
    kSingleRoute.Edit;
    kSingleroute.Delete;
     //kSingleRoute.Post;
    bod := 11;
    if not kSingleRoute.locate('POINT',bod,[]) then
      raise Exception.CreateFmt('Bod %d nenalezen',[bod]);
    kSingleRoute.Edit;
    kSingleroute.Delete;

    bod := 8;
    if not kSingleRoute.locate('POINT',bod,[]) then
      raise Exception.CreateFmt('Bod %d nenalezen',[bod]);
    kSingleRoute.Edit;
    kSingleroute.Delete;

    // pridej bod na vybranou pozici
    AddPointToRoute(6,1);
  end;

  // najdi trasu
  kbSeq.LoadFromDataSet(fEngine.kSingleRoute,[mtCpoStructure,mtCpoProperties]);
  fEngine.RoutePrep(kbSeq);
  dsScore.DataSet := fEngine.kScore;
end;


procedure TfMain.copyToSeq;
begin
  //
end;

procedure TfMain.btCopyClick(Sender: TObject);
begin
  edTest.Text := edRoute.Text;
end;

procedure TfMain.btMissingClick(Sender: TObject);
var
  i: Integer;
  s: string;
begin
   s := 'D4028C04';
   i := fDmd.CheckMissing('242412070E');
   s := Format('Dira pro adapter %s, id: %d',[s,i]) ;
end;

procedure TfMain.btParseClick(Sender: TObject);
begin
  // parse & find route
  fEngine.RouteIdx := 'search_idx';
  dsGrid.DataSet := fEngine.Route;
end;

procedure TfMain.dgPointsCellClick(Column: TColumn);
var FieldName : string;
    idRoute : integer;
    s : string;
    aRoute :rRoute;
    kPoint : TkbmMemTable;
begin
  // FieldName := Column.
  // zjistim index trasy
  try
    dgPoints.DataSource.DataSet.DisableControls;

    idRoute := fEngine.Route.FieldByName('routeID').AsInteger;
    aRoute:=fEngine.RouteDef[idRoute];
    s := aRoute.List;
    edRoute.Text := s;
    labRouteName.Caption := aRoute.RouteName;

    // nakopiruj do tabulky trasu
    kPoint := fEngine.kSingleRoute;
    kbSeq.LoadFromDataSet(fEngine.kSingleRoute,[mtCpoStructure,mtCpoProperties]);
  finally
    //
    dgPoints.DataSource.DataSet.EnableControls;
  end;
end;



procedure TfMain.loadIni;
var Path : string;
    AppIni : TiniFile;
begin
   Path :=  ExtractFilePath(ParamStr(0))+'mz.ini';
   AppIni        := TIniFile.Create(Path);
   with AppIni do begin
     //fPoolSize := ReadInteger('POOL', 'PoolSize', 2);
     //fAutoGrow := ReadBool('POOL','AutoGrow',false);
     ffDataPath:= ReadString('DB','Path','localpath');
   end;
   AppIni.Free;
end;


procedure TfMain.TableToView(ADataSource : TDataSet);
var s : string;
    listItem : TListItem;
    time : TDateTime;
begin

  ADataSource.First;
  ADataSource.DisableControls;
  lView.Items.Clear;
  while not ADataSource.Eof do
  begin
    listItem := lView.Items.Add;


    if ADataSource.FieldByName('Active').AsInteger>0 then
    begin
      //listItem.SubItems.Add('1');
      listItem.ImageIndex:=0   ;

    end
    else
      listItem.ImageIndex:=1;
      //listItem.SubItems.Add('0');

    // ip adresa
    s := ADataSource.FieldByName('ip').AsString;
    listItem.SubItems.Add(s);

    // lokalni ip ziskana dotazem v shellu
    s := ADataSource.FieldByName('Localip').AsString;
    listItem.SubItems.Add(s);

    // mac adresa
    s := ADataSource.FieldByName('mac').AsString;
    listItem.SubItems.Add(s);

    // user
    s := ADataSource.FieldByName('user').AsString;
    listItem.SubItems.Add(s);

    // stat
    s := ADataSource.FieldByName('statDesc').AsString;
    listItem.SubItems.Add(s);

    // TagIdx
    s := ADataSource.FieldByName('tagIdx').AsString;
    listItem.SubItems.Add(s);

    // Pocet prenosu
    s := ADataSource.FieldByName('TransferIdx').AsString;
    listItem.SubItems.Add(s);

    // Cas od posledniho zapisu
    time := now - ADataSource.FieldByName('lastConnect').AsDateTime;
    s := FormatDateTime('hh:nn:ss',time) ;
    listItem.SubItems.Add(s);

    // lastConnect
    s := ADataSource.FieldByName('lastTransfer').AsString;
    listItem.SubItems.Add(s);

    ADataSource.Next;
  end;
  ADataSource.EnableControls;
  Application.ProcessMessages;
end;





// je to callback na ProcessStatistics
procedure TfMain.DoHeartBeat(Sender: TThread; ABeacon : RBeacon);
var msg : string;
begin
  if lbLive.Items.Count>10 then
    lbLive.Items.Clear;

  if (ABeacon.EventType = eEndTransfer) then
  begin
    msg := format('!   Transfer: %s[%s] %s  usr:%s sensor:%d[%s] Cnt:%d',[ABeacon.ip, ABeacon.mac,DateTimeToStr(Now), ABeacon.User,ABeacon.SensorId,Abeacon.SensorName,ABeacon.PointCount]);
    // logMsg(msg);
    lbLive.Items.Add(msg);
    lbLive.ItemIndex := lbLive.Items.Count-1;
  end;

  //
  if (ABeacon.EventType = eChck) then
  begin
    msg := format('%s %s %s',[DateTimeToStr(Now),ABeacon.ip,ABeacon.User]);
    lbLive.Items.Add(msg);
    lbLive.ItemIndex := lbLive.Items.Count-1;

    TableToView(fDaemonThread.kStatus);
    //dsStatus.DataSet := fTh.kStatus;
  end;

  if (ABeacon.EventType= eStatLocked) then
  begin
    msg := format('LOCKED ! %s %s %s',[DateTimeToStr(Now),ABeacon.ip,ABeacon.User]);
   // lbLive.Items.Clear;
    lbLive.Items.Add(msg);
    lbLive.ItemIndex := lbLive.Items.Count-1;
  end;

end;

procedure TfMain.HandleThreadData(Sender : TObject; const msg : TOmniMessage);
var
  i : integer;
  ABeacon     : RBeacon;
  msgx        : TOmniMessage;
  inQueueCount : TOmniAlignedInt32;
  s : string;
begin
  ABeacon:= msg.msgData.ToRecord<RBeacon>;
  {$IFDEF INSPECT}
    SiMain.LogColored(clMoneyGreen,ABeacon.SensorName); // sem jsem schoval naformatovanou zpravu o aktivite/mrtvolnosti krabice
  {$endif}
  DoLogMsg(ABeacon.SensorName);
end;

procedure TfMain.FormActivate(Sender: TObject);
begin
  {$Ifdef  BUGHUNT}
  fDaemonThread := nil;
  {$else}
  fDaemonThread := TTCPHttpDaemon.create;
  fDaemonThread.onHeartBeat := DoHeartBeat;
 // fDaemonThread.onMessage := DoLogMsg;
  fDaemonThread.OnHandleMainForm := HandleThreadData;


  // pripojim Status dpointu
//  dsStatus.DataSet := fDaemonThread.kStatus;
  {$endif}
end;


// tento callback se vola z hlavniho threadu, neni treba synchro
// loguje jneom zmenu stavu
procedure TfMain.DoLogMsg(AMessage: String);
begin
  listBox.items.Add(AMessage);
  listBox.itemIndex:= listBox.items.count-1;

//  TableToView(fDaemonThread.kStatus);

  {$ifdef INSPECT}
  //  siMain.LogDataSet('main.kStatus',fTh.kStatus);
  {$endif}

  Application.ProcessMessages;

end;

procedure TfMain.FormCreate(Sender: TObject);
var fMaxItemWidth : integer;
begin
  fVersionInfo := TVVersionInfo.Create(self);
  Caption := format('%s: %s',[fVersionInfo.ProductName,fVersionInfo.FileVersion]);

  fDlfName  := ExtractFilePath(ParamStr(0));
  fEngine   := nil;

  {$ifdef SERVICE}
  fDmd      := nil;
  {$else}
  self.fDmd := dmdMsql.fDmd;
  {$endif}


  //{$ifdef SERVICE}
  // tohle je uplne separe thread
  fMaxItemWidth := 10;

  {$ifdef MSQL}
    Caption := format('LAN POINT MSSQL %s: %s',[fVersionInfo.ProductName,fVersionInfo.FileVersion]);
  {$else}
    Caption := 'LAN POINT Route finder';
  {$endif}

  lView.Columns[1].Width:=70;
  lView.Columns[2].Width:=70;


 // SendMessage(ListBox.Handle, LB_SELITEMRANGEEX, FMaxItemWidth, 0);
  //{$ENDIF}
end;


procedure TfMain.FormDeactivate(Sender: TObject);
begin
  {$IFDEF INSPECT}
    SiMain.LogColored(clRed,'FormDeactivate');
  {$ENDIF}
end;

procedure TfMain.FormDestroy(Sender: TObject);
begin
  // {$ifdef SERVICE}
 //  Sleep(1000);

   if fDaemonThread<>nil then
     fDaemonThread.Terminate;
   fDaemonThread.Destroy;

   FreeAndNil(fVersionInfo);

  // inherited Destroy;
  // {$endif}
  //  FreeAndNil(fEngine);
end;

end.
