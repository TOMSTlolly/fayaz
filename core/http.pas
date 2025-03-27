unit http;

interface

uses
  {$ifdef INSPECT}
    siAuto,graphics,
  {$endif}

  {$IFDEF  DQUEUE}
    OtlContainerObserver,
    OtlComm,
    OtlCommon,
  {$endif}

  Classes, blcksock, winsock, SysUtils, iniFiles,synaUtil,System.Json,
  db,JclStrings,dateUtils,kbmMemTable,aPolo,windows,variants,
  System.TypInfo,
  {$ifdef MSQL}
    dmdMsql,
  {$else}
    dmd,
  {$endif}
  Math,
  aEngine;

  const
    RAISEMISS=7;  // po tolika sessions vyhodim zadost o chybejici data
    CTestQueueLength=2000;


  type TmEvent= (eNone,eChck,eGuard,eLanName,eSensor,eEndTransfer, eRouteFound,eRouteUnknown,eStatLocked);
  type RBeacon=packed record
    User : string;
    ip   : string;
    localIp : string;
    mac  : string;
    clientPort  : integer;
    TagIdx : integer;
    localTime : TDateTime;
    EventType : TmEvent;

    SensorId   : integer;
    SensorName : string;
    PointCount : integer;
  end;

  type TOnTagIdx=procedure(Sender : TThread) of object;
  type TOnMsg =procedure (Sender : TThread; AMessage : string ) of object;
  type TOnBeacon= procedure (Sender: TThread; ABeacon  : RBeacon) of object;
  type TOnDPStatus=procedure(Sender : TThread; AIp,AMac : string; var Active: Boolean) of object;
  type THandleThreadData = procedure (Sender: TObject; const msg: TOmniMessage) of object;


  TTCPHttpThrd = class(TThread)
  private
    ob1 : TObject;
    fDmd     : TDmd;
    fkWrite  : TKbmMemTable;
    fkSerial : TkbmMemTable;
    fMessage : string;
    fPoint   : RLPoint;   // jedna udalost LAN-POINTU
    Sock:TTCPBlockSocket;
    fOnDaemonMessage : TOnMsg;
    fTextPath : string;
    fIniThread      : TIniFile;
    fTestujMissing : integer;

    // ukladani do souboru
    fDataTs   : TStringList;
    fFileSave    : string;
    fIdSyn: integer;
    fOrd  : integer;
   // fOnBeat : TOnBeacon;

    // seminko
    fBeacon : RBeacon;
    fStatusLocked : boolean;
    fOnDpStatus : TOnDPStatus;
    fOnTagIdx   : TOnTagIdx;
    fTagIdx: integer;

    fLastBeacon : integer;

    {$IFDEF DQUEUE}
      fDaemonQueue : TOmniMessageQueue;  // fronta pro komunikaci mezi Demonem a jeho http Slave threadem
      fBarQueue    : TOmniMessageQueue;
    {$ENDIF}

    // vyskladany keypad code
    fCode  : string;
    fLastRefresh: DWORD;
    procedure LogMsg(Sender: TThread; msg: string);
    procedure logMsgSyn;
    procedure encodePoint(ALine: string;var Result : rLPoint);
    procedure Append(APoint: RLPoint);
    procedure CreateTableFmt;
    procedure ClearPoint(var APoint: RLPoint);
    function  EvalRoute: boolean;
    procedure AddToFile;
    function  MemoryStreamToString(M: TMemoryStream): string;
    procedure ClearBeacon;
    function  RemoveChar(AChar: Char; AValue: string): string;
    function  ProcessHttpRequest(Request, URI: string): integer;
    function  LanPointRequest(ALine: string; var Respond: string): boolean;
    procedure httpRequest(ALine: string);
    function  ParseUri(Request, Uri: string): string;
    function  DataSetToJSONx(var Obj: TJsonObject; const ARName: string;ADataSet: TDataSet): TJSONValue;
    function  sqlTable(ts: TStringList): string;
    procedure CreateMetaJsonx(var obj: TJsonObject; const ARName: string;    ADataSet: TDAtaSEt);
    function  DataSetToJSONy(var Obj: TJsonObject; const ARName: string;      ADataSet: TDataSet): TJSONValue;
    function  sqlExec(sql: string): string;
    function  dec_dowslash(AValue: string): string;
    function  rep_rules(AValue: string): string;
    procedure DoBeacon(ABeacon : RBeacon);
    procedure SetBarQueue(const Value: TOmniMessageQueue);
    procedure SetDaemonQueue(const Value: TOmniMessageQueue);
    procedure SetLastRefresh(const Value: DWORD);
  public
    Headers                : TStringList;
    InputData,  OutputData : TMemoryStream;
    Constructor Create (hsock:tSocket);
    Destructor  Destroy    ; override;
    procedure   Execute    ; override;
   // function ProcessHttpRequest(Request, URI: string): integer;

    //  Zprava
    // property    OnDaemonMessage : TOnMsg  read fOnDaemonMessage write fOnDaemonMessage;
//    property    OnBeat    : TOnBeacon read fOnBeat    write fOnBeat;
    property    OnDpStatus : TOnDPStatus read fOnDpStatus write fOnDpStatus;
    property    OnTagIdx   : TOnTagIdx   read fOnTagIdx write fOnTagIdx;
   // property    OnHeartBeat        : TOnHeart

    property   TagIdx: integer read fTagIdx write fTagIdx;
    property   DaemonQueue : TOmniMessageQueue read fDaemonQueue write SetDaemonQueue;
    property   BarQueue    : TOmniMessageQueue read fBarQueue    write SetBarQueue;
    property   LastRefres  : DWORD read fLastRefresh write SetLastRefresh;



  end;

type
  TTCPHttpDaemon = class(TThread)
  private
    fPort         : integer;
    Sock          : TTCPBlockSocket;
    fOnMsg        : TOnMsg;
    fOnHttpBeat     : TOnBeacon;
    fSimpleThread : TTCPHttpThrd;
    fIniDaemon          : TIniFile;
    fHttpBeacon         : RBeacon;

    // vylepsene logovani do souboru
    fLastCHCK : DWORD;
    fStatusLocked : boolean;
    fLogTs    : TStringList;
    fLogName  : string;
    fOutputFolder : string;
    fLogFolder : string;
    fTagIdx   : integer;
    fMsg      : string;

    {$IFDEF DQUEUE}
      fDaemonQueue : TOmniMessageQueue;  // fronta pro komunikaci mezi Demonem a jeho http Slave threadem
      fBarQueue    : TOmniMessageQueue;
    {$ENDIF}

    fkStatus  : TkbmMemTable;   // bugleak
    procedure   CreateStatusTableMeta;
    procedure   ProcessStatistic(ABeacon: RBeacon);
    procedure   RefreshLastCHCK;
    procedure   DoHeartBeat(Sender: TThread; ABeacon: RBeacon);
    function    StatToString(eEvent: TmEvent): string;
    procedure   LogToFile;
    procedure   DoHTTPMessage(Sender: TTHread; Msg: string);
    function    IpIsAlive(AIP,AMac: string): boolean;
    procedure   DoDpStatus(Sender: TThread; AIp,AMac: STring; var Active: Boolean);
    procedure   DoDecTagIdx(Sender: TTHread);
    procedure   LogDaemonSyn;
    procedure   LogHeartBeat;
    function    Dpn(AValue: string; ACount: integer): string;
    procedure SetKStatus(const Value: TkbmMemTable);
    procedure SetDaemonQueue(const Value: TOmniMessageQueue);
    procedure SetHandleMainForm(const Value: THandleThreadData);
    procedure DoSockStatus(Sender: TObject; Reason: THookSocketReason;
      const Value: String);
  public
    procedure   HandleThreadData(Sender: TObject; const msg: TOmniMessage);

    constructor Create;
    Destructor  Destroy; override;
    procedure   Execute; override;

    procedure DoBeaconMainForm(ABeacon: RBeacon); // Demon jednou za cas vyrobi tabulku aktivnich/neaktivnich krabic


//    property    OnMessage : TOnMsg    read fOnMsg write fOnMsg;
    property    OnHeartBeat     : TOnBeacon read fOnHttpBeat write fOnHttpBeat;
    property    Port      : integer   read fPort write fPort;
    property    OutFolder : string    read fOutputFolder write fOutputFolder;
    property    LogFolder : string    read fLogFolder    write fLogFolder;

    // vystrcim ven kStatus
    property    kStatus : TkbmMemTable read fkStatus write SetKStatus;
    property    Beacon  : RBeacon read fHttpBeacon write fHttpBeacon;

    property  DaemonQueue : TOmniMessageQueue read fDaemonQueue write SetDaemonQueue;
    property  OnHandleMainForm   : THandleThreadData write SetHandleMainForm;


  end;


implementation

{ TTCPHttpDaemon }
Destructor TTCPHttpDaemon.Destroy;
begin
  FreeAndNil(fLogTs);

//  fkStatus.ClearFields;
  FreeAndNil(fkStatus);

  Sock.free;
  FreeAndNil(fIniDaemon);

  inherited ;
end;


constructor TTCPHttpDaemon.Create;
var Path : string;
begin
  inherited create(false);

  {$IFDEF DQUEUE}
    FreeAndNil(fDaemonQueue);
    fDaemonQueue           := TOmniMessageQueue.Create(CTestQueueLength);
    fDaemonQueue.OnMessage := HandleThreadData;   // callback pro data z prtavych threadu

    FreeAndNil(fBarQueue);
    fBarQueue :=  TOmniMessageQueue.Create(CTestQueueLength);
    fBarQueue.OnMessage := nil;       // tohle si nastavim z main formy

  {$endif}

 // fOnMsg := AOnMessage;
  sock:=TTCPBlockSocket.create;
  FreeOnTerminate:=true;

  Path :=  ExtractFilePath(ParamStr(0))+'mz.ini';
  fIniDaemon        := TIniFile.Create(Path);
  fPort := fIniDaemon.ReadInteger('POOL','PORT',5002);
  fOutputFolder:= fIniDaemon.ReadString('DB','OUTFOLDER','c:\temp\outdata');
  fLogFolder   := fIniDaemon.ReadString('DB','LOGFOLDER','c:\temp\log');

  ///
  fLastCHCK := 0;
  fkStatus  := TkbmMemTable.Create(nil);
  fLogTs := TSTringList.Create;
  fLogName := formatdateTime('dd_mm_yyyy_hh_nn',Now);
  fLogName := fLogFolder +'\'+ fLogName + '.txt';

  if not DirectoryExists(fLogFolder) then
    raise Exception.CreateFmt('Adresar %s neexistuje',[fLogFolder]);


  if not DirectoryExists(fOutputFolder) then
    raise Exception.CreateFmt('Adresar %s neexistuje',[fOutputFolder]);


  {$IFDEF  INSPECT}
    SiMain.LogColored(clGreen,format('LogName: %s',[fLogFolder]));
    SiMain.LogColored(clGreen,format('LogName: %s',[fLogName]));
  {$endif}
  // vyrobime absolutni cestu
end;


procedure TTCPHttpDaemon.SetDaemonQueue(const Value: TOmniMessageQueue);
begin
  fDaemonQueue := Value;
end;

procedure TTCPHttpDaemon.SetHandleMainForm(const Value: THandleThreadData);
begin
  fBarQueue.OnMessage := Value;
end;

procedure TTCPHttpDaemon.SetKStatus(const Value: TkbmMemTable);
begin
  fkStatus := Value;
end;

function TTCPHttpDaemon.StatToString(eEvent : TmEvent) : string;
begin
  case eEvent of
   eNone:
      Result := 'None';
   eChck:
      Result := 'Check';
   eLanName:
      Result := 'LanName:';
   eRouteFound:
      Result := 'RouteFound';
   eRouteUnknown:
      Result := 'Unknown';
  end;
end;


function TTCPHttpDaemon.Dpn(AValue :string; ACount :integer) : string;
var i : integer;
begin
  Result := AValue;
  if ACount<=Length(AValue) then
    exit;

  for I := Length(AValue) to ACount do
    Result := Result+'.';
end;


// priprav vystup do MAIN formy
procedure TTCPHttpDaemon.RefreshLastCHCK;
var LastConnect       : TDateTime;
    Status,active     : integer;
    lanName,smf,ip,mac    : string;
    stSwitch          : boolean;
    ABeacon : RBeacon;
begin
  try
    fStatusLocked := true;

    fkStatus.Lock;
    fkStatus.DisableControls;
    fkStatus.First;
    while not fkStatus.Eof do
    begin
      LastConnect := fkStatus.FieldByName('LastConnect').AsDateTime;
      lanName     := fkStatus.FieldByName('user').AsString;
      ip          := fkStatus.FieldByName('ip').AsString;
      stSwitch := false;

      // 1 bit je znamka zivota dpoint z
      //status := fkSTatus.FieldByName('status').AsInteger ;
      active := fkStatus.FieldByName('active').AsInteger;
      if ((Now-LastConnect)>1/24/60) then // po minute vydam varovani
      begin
        // TimeOut !!!
        // pred akci byl dpoint aktivni ???
        if (active >0 ) then
        begin
          // ok pred tim byl dpoint aktivni !!!
          lanName := fkStatus.FieldByName('User').AsString;
          mac     := fkStatus.FieldByName('mac').AsString;
          smf := format('! Connection %s[mac: %s] %15s %s lost',[ip,mac,dateTimeToStr(Now),dpn(LanName,10)]);

          active := 0;
          stSwitch := true;
        end;
      end
      else
      begin
        if (active =0 ) then
        begin
          // ok pred tim byl dpoint neaktivni !!!
          lanName := fkStatus.FieldByName('User').AsString;
          mac     := fkStatus.FieldByName('mac').AsString;
          smf := format('! Connection %s[mac: %s] %15s %-10s established',[ip,mac,dateTimeToStr(Now),dpn(LanName,10)]);
          active := 1;
          stSwitch := true;
        end;
      end;

      // nahraj zmeny
      if stSwitch then
      begin
         fkStatus.Edit;
         fkStatus.FieldByName('active').asInteger := active;
         fkStatus.Post;

         // kazdy lanpoint se mi predstavi v smf string
         DoHTTPMessage(self,smf);    // zapisu do logu


         ABeacon.ip := ip;
         ABeacon.User := lanName;
         ABeacon.mac := mac;
         ABeacon.localTime := LastConnect;
         ABeacon.PointCount := fTagIdx;
         ABeacon.SensorName := smf; // sem schovam log

         DoBeaconMainForm(ABeacon);


        //  DoLogToFile(smf);  // do logu + smartinspectoru
        // fOnMsg(self,smf);  // do mainformy

      end;
      fkStatus.Next;
    end;
  finally
    fkStatus.EnableControls;
    fkStatus.Unlock;
    fStatusLocked := false;
  end;
end;


procedure TTCPHttpDaemon.DoBeaconMainForm(ABeacon : RBeacon);
var
  tv : TOmniValue;
  msg : string;
begin

  tv := TOmniValue.FromRecordUnsafe<RBeacon>(ABeacon);
  if not FBarQueue.Enqueue(TOmniMessage.Create(fTagIdx {ignored},tv )) then   // fTagIdx : Celkovy pocet httpThreadu
  begin
    {$IFDEF  INSPECT}
       msg := Format('TTCPHttpThrd.DoBeacon is full devid:%s, ip:%s',[ABeacon.user,ABeacon.ip]);
       SiMain.LogMessage(msg);
    {$endif}
  end;
end;




// status tabulka pro zjisteni LAN-clientu
procedure TTCPHttpDaemon.CreateStatusTableMeta;
begin
   with fkStatus.FieldDefs do
   begin
     Clear;
     Add('Pkey'        , ftAutoinc , 0 ,false);
     Add('User'        , ftString  , 40, false);
     Add('Status'      , ftInteger , 0 , false);
     Add('Active'      , ftInteger , 0, false);
     Add('StatDesc'    , ftString  , 40, False);
     Add('IP'          , ftString  , 16 , false);
     Add('LocalIP'     , ftString  , 16 , false);
     Add('MAC'         , ftString  , 17 , False);
     Add('TagIdx'      , ftInteger , 0, false);
     Add('TransferIdx' , ftInteger , 0, false);
     Add('LastConnect' , ftDateTime  , 0 , false);
     Add('LastTransfer', ftDateTime  , 0 , false);
     Add('LanTime'     , ftDateTime  , 0 , false);
   end;
   fkStatus.CreateTable;
   fkStatus.Open;
end;


(*
procedure TfMain.HandleThreadData(Sender: TObject; const msg: TOmniMessage);
var
  i : integer;
  AMer     : TMereni;
  msgx        : TOmniMessage;
  inQueueCount : TOmniAlignedInt32;
  s : string;
begin
  AMer:= msg.msgData.ToRecord<TMereni>;
  {$IFDEF  INSPECT}
     s := format('msgId: %d, idx:%d, cnt:%d,date:%s, t1=%f, hum=%d',[msgx.MsgID,AMer.idx,fChipuCnt,DateTimeToStr(AMer.dateTime),AMer.t1,AMer.hum]);
     siMain.LogMessage(s) ;
  {$endif}
  DoMereni(AMer);
  Inc(fChipuCnt);
end;
*)


procedure TTCPHttpDaemon.DoHeartBeat(Sender : TThread; ABeacon: RBeacon);
begin
  //
 // ProcessStatistic(ABeacon);
end;


procedure TTCPHttpDaemon.LogHeartBeat;
begin
  if Assigned(fOnHttpBeat) then
    fOnHttpBeat(self,fHttpBeacon);
end;

{$IFDEF  DQUEUE}
procedure TTCPHttpDaemon.HandleThreadData(Sender : TObject; const msg : TOmniMessage);
var
  i : integer;
  ABeacon     : RBeacon;
  msgx        : TOmniMessage;
  inQueueCount : TOmniAlignedInt32;
  s : string;
begin
  ABeacon:= msg.msgData.ToRecord<RBeacon>;
  ProcessStatistic(ABeacon);
end;
{$ENDIF}

// zpracuj jakoukoli znamku zivota DPOINTU
procedure TTCPHttpDaemon.ProcessStatistic(ABeacon : RBeacon);
var smt : string;
    nota : boolean;
begin
   {$ifdef INSPECT}
    // smt := format('%d %d',[ABeacon.User,ABeacon.ip,ABeacon.EventType
     SiMain.Watch('Check ',Ord(ABeacon.EventType));
     SiMain.Watch('Time',TimeToStr(now));
     //SiMain.LogMessage(ABeacon.ip+' ' +ABeacon.user) ; /// ip + cislo adapteru
   {$endif}

   if not Assigned(fkStatus) then
    exit;

   // zpracovavam jenom heartbeat nebo prenos
   nota :=(ABeacon.EventType=eChck) or (ABeacon.EventType=eLanName) or (ABeacon.EventType=eEndTransfer) ;  //or (ABeacon.EventType := eGuard);
   if not nota then
    exit;

   if (ABeacon.EventType=eEndTransfer) then
   begin
     smt := format('! Transfer: %s[%s] %s  usr:%s sensor:%d[%s] Cnt:%d',[ABeacon.ip, ABeacon.mac,DateTimeToStr(Now), ABeacon.User,ABeacon.SensorId,Abeacon.SensorName,ABeacon.PointCount]);
     DoHTTPMessage(self,smt);  // zapis do souboru / nebo do main formy ????
   end;

   ABeacon.ip  := Trim(ABeacon.ip);
   ABeacon.mac := Trim(ABeacon.mac);
   if fkStatus.Tag>0 then
   begin
     // uz jsem resil pred tim, nechci aby mi to sem lezlo, kdyz nemam hotovy predesly run
     ABeacon.EventType := eStatLocked;
     fHttpBeacon := ABeacon;
//     Synchronize(LogHeartBeat);
     exit;
   end;

   fkStatus.Tag := 1;
   fkStatus.Lock;
   fkStatus.Open;

   if not fkStatus.Locate('ip;mac',VarArrayOf([ABeacon.ip,ABeacon.mac]),[]) then
   begin
     {$ifdef INSPECT}
         smt := Format('new ip/mac',[ABeacon.ip,ABeacon.mac]);
         siMain.LogDataSet(smt,fkStatus);
     {$endif}

     fkStatus.Append;
     fkStatus.FieldByName('ip').AsString := ABeacon.ip;
     fkStatus.FieldByName('mac').AsString:= ABeacon.mac;
     fkStatus.FieldByName('user').AsString := ABeacon.User;
     fkStatus.FieldByName('tagIdx').AsInteger:=0;
     fkStatus.FieldByName('TransferIdx').AsInteger :=0;
    // fkStatus.FieldByName('LastConnect').asDateTime := 0;
    // fkStatus.Post;
   end
   else
     fkStatus.Edit;

   // jde o datovy prenos ?
   if (ABeacon.EventType=eLanName) then
   begin
     fkStatus.FieldByName('TransferIdx').AsInteger   :=  fkStatus.FieldByName('TransferIdx').AsInteger+1;
     fkStatus.FieldByName('LastTransfer').AsDateTime :=  now;
   end;
   fkStatus.FieldByName('TagIdx').AsInteger:= fkStatus.FieldByName('TagIdx').AsInteger+1;//AStat.tagIdx;
   fkStatus.FieldByName('mac').AsString := ABeacon.mac;
   fkStatus.FieldByName('Status').AsInteger  := Ord(ABeacon.EventType);
   fkStatus.FieldByName('StatDesc').AsString := StatToString(ABeacon.EventType);
   if (Trim(ABeacon.User)<>'') then
     fkStatus.FieldByName('User').AsString := ABeacon.User;
   fkStatus.FieldByName('LanTime').AsDateTime   := ABeacon.localTime;
   fkStatus.FieldByName('LastConnect').AsDateTime := now;
   fkStatus.Post;
   fkStatus.Unlock;

   fkStatus.Tag := 0;

  {$ifdef TESTDEL}
   fHttpBeacon := ABeacon;
   Synchronize(LogHeartBeat);
  {$endif}
end;



function TTCPHttpDaemon.IpIsAlive(AIP,AMac: string) : boolean;
var ip : string;
begin
  try
   if fkStatus.Tag>0 then
     exit;

   fkStatus.Lock;
   fkStatus.Tag := 1;
   fkStatus.Open;

   // mam tu zaznam k teto IP ?
   Result := false;

   // musim poresit provoz na verejne IP versus provoz na lokalni siti
   if fkStatus.Locate('mac',AMac,[]) then
   begin
     if not fkStatus.Locate('localIP;mac',varArrayOf([AIp,AMac]),[]) then
     begin
       fkStatus.Edit;
       fkStatus.FieldByName('localIP').AsString := AIp;
       fkStatus.Post;
     end;
     REsult :=  fkStatus.FieldByName('active').AsInteger>0;
   end;

   //if fkStatus.Locate('ip;mac',varArrayOf([AIp,AMac]),[]) then
   //  Result := fkStatus.FieldByName('active').AsInteger>0;

  finally
    fkStatus.Unlock ;
    fkStatus.Tag := 0;
  end;

end;



procedure TTCPHttpDaemon.DoDpStatus(Sender : TThread; AIp,AMac : STring; var Active: Boolean);
begin
  ACtive := IpIsALive(AIp,AMac);
end;


procedure TTCPHttpDaemon.DoSockStatus(Sender: TObject; Reason: THookSocketReason;const Value: String);
begin
  {$ifdef INSPECT}
  SiMain.LogMessage('DoSockStatus '+Value);
  {$ENDIF}
end;

procedure TTCPHttpDaemon.Execute;
var
  ClientSock:TSocket;
  s        : string;
  fLastRefresh : DWord;
  label konec;
begin
  {$IFDEF INSPECT}
     SiMain.LogMessage('TTCPHttpDaemon.Execute');
  {$endif}

//  Sock.OnStatus := DoSockStatus;

  with sock do
    begin
      CreateSocket;
      setLinger(true,10000);
      bind('0.0.0.0',IntToStr(fPort));
      listen;

      fStatusLocked := true;
//      fkStatus := TkbmMemTable.Create(nil);
      CreateStatusTableMeta;
      fkStatus.Open;
      {$ifdef INSPECT}
        s := format('Server listening at port %d',[fPort]);
        siMain.LogMessage(s);
      {$endif}
     if assigned(fOnMsg) then
       fOnMsg(self,s);

     // LogDaemonSyn;

      fStatusLocked := false;
      fLastRefresh := GetTickCount;
      fTagIdx := 0;

      repeat
        // po cca sekunde zkontroluj tabulky
        if (getTickCount-fLastRefresh)>1000 then
          if not fStatusLocked then
            RefreshLastCHCK;

        if terminated then
           goto konec;


        if canread(1000) then
          begin
            ClientSock:=accept;
            if lastError=0 then
            begin
               fSimpleThread := TTCPHttpThrd.create(ClientSock);
              // fSimpleThread.OnDaemonMessage    := DoDaemonMessage ;//fOnMsg;
 //            fSimpleThread.OnBeat             := DoHeartBeat   ;
               fSimpleThread.OnDpStatus         := DoDPStatus ; //
               fSimpleThread.OnTagIdx           := DoDecTagIdx;
               fSimpleThread.TagIdx             := fTagIdx;
               fSimpleThread.DaemonQueue        := fDaemonQueue;
               Inc(fTagIdx);
            end;
          end;
      until false or Terminated;

 //     repeat
 //        Sleep(1000);
 //     until terminated;
    end;

konec:
//  fkStatus.DestroyIndexes(true);
 // FreeAndNil(fkStatus);
end;



procedure   TTCPHttpDaemon.DoDecTagIdx(Sender : TTHread);
begin
   Dec(fTagIdx);
end;


Constructor TTCPHttpThrd.Create(Hsock:TSocket);
begin
  sock:=TTCPBlockSocket.create;
  Headers := TStringList.Create;
  InputData := TMemoryStream.Create;
  OutputData := TMemoryStream.Create;
  Sock.socket:=HSock;
  FreeOnTerminate:=true;
  // fIni := TIniFile.Create(fDlfName+');

  Randomize;

// fOnBeat := nil;
  {$ifdef SERVICE}
    fDmd := nil;
  {$else}
    fDmd := dmdMsql.fdmd;
  {$endif}

  inherited create(false);
end;

Destructor TTCPHttpThrd.Destroy;
begin
  Sock.free;
  Headers.Free;
  InputData.Free;
  OutputData.Free;
  fOnTagIdx(Self);
  // FreeAndNil(fkStatus);


  inherited Destroy;
end;

procedure TTCPHttpDaemon.LogToFile;
var ALog : string;
begin
  //
  fLogTs.BeginUpdate;
  ALog := format('%s',[fMsg]);    // pridej cas udalosti
  fLogTs.Add(Alog) ;
  fLogTs.EndUpdate;
  fLogTs.SaveToFile(fLogName);

  // vsechno co mi stoji za to zalogovat napisu i sem !!!
  {$ifdef INSPECT}
  SiMain.LogColored(clMaroon,ALog);
  {$endif}
end;


// sem se dostanu z THttpThreadu
procedure TTCPHttpDaemon.DoHTTPMessage(Sender : TTHread; Msg: string);
begin
  fMsg := Msg;
  {$ifdef TESTDEL}
  Synchronize( LogDaemonSyn);    // log do main formy, u sluzby je to jenom vystup do SmartInspectora
  {$endif}
  //Synchronize(LogToFile);
  LogToFile;
end;


procedure TTCPHttpDaemon.LogDaemonSyn;
begin
  if Assigned(fOnMsg) then
    fOnMsg(self,fMsg);
end;


(**********************************************************************************)
procedure TTCPHttpThrd.LogMsg(Sender: TThread; msg: string);
begin
  fMessage := msg;
  //Synchronize(LogMsgSyn);
end;

procedure TTCPHttpThrd.logMsgSyn;
begin
  if Assigned(fOnDaemonMessage) then
    fOnDaemonMessage(self,fMessage);
end;


type TEnumConverter = class
public
  class function EnumToInt<T>(const EnumValue: T): Integer;
  class function EnumToString<T>(EnumValue: T): string;
end;

class function TEnumConverter.EnumToInt<T>(const EnumValue: T): Integer;
begin
  Result := 0;
  Move(EnumValue, Result, sizeOf(EnumValue));
end;

class function TEnumConverter.EnumToString<T>(EnumValue: T): string;
begin
  Result := GetEnumName(TypeInfo(T), EnumToInt(EnumValue));
end;

procedure TTCPHttpThrd.CreateMetaJsonx(var obj : TJsonObject; const ARName : string; ADataSet  : TDAtaSEt) ;
var
  Rows: TJSONArray;
  Row: TJSONObject;
  Col : integer;
  Data : TJSONValue;
  Field : TField;
  s : string;
begin
  Rows := TJSONArray.Create;
  obj.AddPair(TJsonPair.Create(ARNAME,Rows));

  ADataSet.First;
  Row := TJSONObject.Create;
  for Col := 0 to ADataSet.FieldCount - 1 do
  begin
      Field := ADataSet.Fields[Col];
      if Field.IsNull then
        Data := TJSONNull.Create
      else
        //Data := TJSONString.Create(
        s  := TEnumConverter.EnumToString(Field.DataType);

      Row.AddPair(Field.FieldName, Data);
  end;
  Rows.Add(Row);
end;


function TTCPHttpThrd.DataSetToJSONx(var Obj: TJsonObject;const ARName : string; ADataSet: TDataSet): TJSONValue;
var
  Col: Integer;
  Data: TJSONValue;
  Field: TField;
  Rows: TJSONArray;
  Row: TJSONObject;
  S,sUtf8 : String;
  fIdx: integer;
  fmtDateTime : string;
begin
 // obj  := TJSONObject.Create;  // NOVE
  Rows := TJSONArray.Create;
  obj.AddPair(TJsonPair.Create(ARNAME,Rows));
  {$ifdef INSPECT}
  siMain.logDataSet(ADataSet.Name,ADataSet);
  {$endif}

  fIdx := 0;
  ADataSet.First;
  if not ADataSet.Eof then
  begin
    Row := TJSONObject.Create;
    for Col := 0 to ADataSet.FieldCount - 1 do
    begin
        Field := ADataSet.Fields[Col];
        s  := TEnumConverter.EnumToString(Field.DataType);
        Data := TJSONString.Create(s);
        Row.AddPair(Field.FieldName, Data);
    end;
    Rows.Add(Row);
  end;


  fIdx := 0;
  ADataSet.First;
  while not ADataSet.Eof do
  begin
    Row := TJSONObject.Create;

    for Col := 0 to ADataSet.FieldCount - 1 do
    begin
      Field := ADataSet.Fields[Col];
      if Field.IsNull then
        Data := TJSONNull.Create
      else
        case Field.DataType of
          ftSmallint, ftInteger, ftWord, ftCurrency, ftLargeint, ftLongWord,
          ftShortint, ftByte, ftAutoInc,ftFMTBcd:
            Data := TJSONNumber.Create(Field.AsInteger);

          ftFloat:
            Data := TJSONNumber.Create(Field.AsFloat);

          ftBoolean:
            if Field.AsBoolean then
              Data := TJSONTrue.Create
            else
              Data := TJSONFalse.Create;

          ftDateTime:
            begin
              if Field.AsFloat>1 then
              begin
                fmtDateTime := formatDateTime('dd.mm.yyyy hh:nn:ss',field.Value);
                Data := TJSONString.Create(fmtDateTime)
                //Data := TJSONString.Create(field.AsString)
              end
              else
                Data := TJSONNull.Create;
            end;

        else
        begin
            //s := UTF8ToString(field.AsString);
            //sUtf8 :=  UTF8ToString(field.AsString);
            sUtf8 :=  UTF8Encode(field.AsString);
            Data := TJSONString.Create(sUtf8);
        end;
      end;
      Row.AddPair(Field.FieldName, Data);
    end;
    Rows.Add(Row);
    ADataSet.Next;
    Inc(fIdx);
  end;

  Result := obj;
end;


function TTCPHttpThrd.DataSetToJSONy(var Obj: TJsonObject;const ARName : string; ADataSet: TDataSet): TJSONValue;
var
  Col: Integer;
  Data: TJSONValue;
  Field: TField;
  Rows: TJSONArray;
  Row: TJSONObject;
  S : String;
  fIdx: integer;
begin
 // obj  := TJSONObject.Create;  // NOVE
  Rows := TJSONArray.Create;
  obj.AddPair(TJsonPair.Create(ARNAME,Rows));
  {$ifdef INSPECT}
  siMain.logDataSet(ADataSet.Name,ADataSet);
  {$endif}

  fIdx := 0;
  ADataSet.First;
  while not ADataSet.Eof do
  begin
    Row := TJSONObject.Create;

    for Col := 0 to ADataSet.FieldCount - 1 do
    begin
      Field := ADataSet.Fields[Col];
      if Field.IsNull then
        Data := TJSONNull.Create
      else
        case Field.DataType of
          ftSmallint, ftInteger, ftWord, ftCurrency, ftLargeint, ftLongWord,
          ftShortint, ftByte, ftAutoInc,ftFMTBcd:
            Data := TJSONNumber.Create(Field.AsInteger);

          ftFloat:
            Data := TJSONNumber.Create(Field.AsFloat);

          ftBoolean:
            if Field.AsBoolean then
              Data := TJSONTrue.Create
            else
              Data := TJSONFalse.Create;

        else
        begin
            Data := TJSONString.Create(field.AsString);
        end;
      end;
      Row.AddPair(Field.FieldName, Data);
    end;
    Rows.Add(Row);
    ADataSet.Next;
    Inc(fIdx);
  end;

  Result := obj;
end;



function TTCPHttpThrd.sqlTable(ts : TStringList) : string;
var sql,tableName : string;
    obj : TJsonObject;
    ktb : TkbmMemTable;
begin
  //sql := StrReplace(ASql,'_',' ',[]);
  try
    sql := ts[0];
    sql := rep_rules(sql);
    //StrReplace(Sql,'_',' ',[rfReplaceAll]);

    // vyzadej si objekt z poolu
     ob1 := fPolo.Acquire;
     if not assigned(ob1) then
     begin
         {$ifdef INSPECT}
              siMain.LogColored(clGreen,'No object in poool');
         {$endif}
             //Result:=-10;
         Result := 'ERR '#13#10;
         exit;
     end;

    {$ifdef SERVICE}
      fDmd := ob1 as TDmd;
      if fdmd=nil then
          exit;
    {$endif}

    // sql dotaz a navrat z tabulky
    {$IFNDEF  ABS}
      fdmd.EqMS(sql);
    {$endif}
    obj := TJSONObject.Create;

    tableName := 'AR1' ;
    if ts.Count>1 then
      tableName := ts[1];

      {$IFNDEF  ABS}
    DataSetToJsonx(obj,tableName,fdmd.uniQuery);
    {$endif}
    Result := obj.ToString;
  finally
   obj.Free;
   fPolo.Release(ob1);
  end;
end;


function TTCphttpThrd.rep_rules(AValue: string): string;
begin
  StrReplace(AValue,'/','_',[rfReplaceAll]);
  StrReplace(AValue,'__','#',[rfReplaceAll]);
  StrReplace(AValue,'_',' ',[rfReplaceAll]);
  StrReplace(AValue,'#','_',[rfReplaceAll]);
  Result := Avalue;
end;


procedure TTCPHttpThrd.SetBarQueue(const Value: TOmniMessageQueue);
begin
  fBarQueue := Value;
end;

procedure TTCPHttpThrd.SetDaemonQueue(const Value: TOmniMessageQueue);
begin
  fDaemonQueue := Value;
end;



procedure TTCPHttpThrd.SetLastRefresh(const Value: DWORD);
begin
  fLastRefresh := Value;
end;

// dvojity __ nahradi jednoduchym _
function TTCPHttpThrd.dec_dowslash(AValue : string) : string;
begin
  StrReplace(AValue,'__','#',[rfReplaceAll]);
end;


function TTCPHttpThrd.sqlExec(sql : string) : string;
//var
  //sql : string;
  //obj : TJsonObject;
begin
  try
    Result := 'ERROR '+#13#10;
    //sql := ts[1];
    sql := rep_rules(sql);

    {$ifdef INSPECT}
      siMain.LogColored(clLime,sql);
    {$endif}

    // vyzadej si objekt z poolu
    ob1 := fPolo.Acquire;
    if not assigned(ob1) then
     begin
       {$ifdef INSPECT}
         siMain.LogColored(clGreen,'No object in poool');
       {$endif}
       //Result:=-10;
       Result := 'ERR '#13#10;
       exit;
    end;

    {$IFDEF SERVICE}
      fDmd := ob1 as TDmd;
      if fdmd=nil then
          exit;
    {$endif}

    {$ifdef INSPECT}
      siMain.LogColored(clYellow,sql);
    {$endif}

    // sql dotaz a navrat z tabulky
    {$IFNDEF  ABS}
    fdmd.EqMS(sql);
    {$ENDIF}

    //obj := TJSONObject.Create;
    Result := 'OK '+#13#10;
  finally
   fPolo.Release(ob1);
  end;
end;


// z winkontrolu prijde http se sql stringem/jmenem tabulky
// result vraci json string
function TTCPHttpThrd.ParseUri(Request, Uri : string): string;
var i1 : integer;
    ts : TStringList;
    sql : string;
begin
  Result := '';
   i1 := pos('/datasnap/rest/',uri);
   if i1<1 then
     exit;

  uri :=  copy(uri,i1+15,length(uri));
  if uri='' then
    exit;

  ts := TStringList.Create;
  StrToStrings(uri,'/',ts);
  i1 := pos('iSql',uri);
  if i1>0 then
  begin
    sql := copy(uri,i1+5,length(uri)-5);
    Result := sqlExec(sql);
  end        ;

  i1 := pos('iTable',uri);
  if i1>0 then
  begin
    sql :=copy(uri ,i1+7,length(uri)-7);     // string za slashem iTable/ ? REPX
    ts.Clear;
    StrToStrings(sql,'/',ts);
    Result := sqlTable(ts);
  end;

  (*
  if  (UpperCase(ts[0])=UpperCase('iSql')) then
  begin
     if ts.Count<1 then
       raise exception.CreateFmt('Spatne uri, chybi sql string: %s',[Uri]);

     Result := sqlExec(ts);
   end
   else if (UpperCase(ts[0])=UpperCase('iTable')) then
   begin
     Result := sqlTable(ts);
   end;
   *)
   FreeAndNil(ts);
end;

function TTCPHttpThrd.ProcessHttpRequest(Request, URI: string): integer;
var
  l: TStringlist;
  s: string;

begin
//sample of precessing HTTP request:
// InputData is uploaded document, headers is stringlist with request headers.
// Request is type of request and URI is URI of request
// OutputData is document with reply, headers is stringlist with reply headers.
// Result is result code
  result := 504;
  if request = 'GET' then
  begin
    headers.Clear;
    headers.Add('Content-type: Text/Html');
    l := TStringList.Create;
    try
      //l.LoadFromFile('c:\temp\osoby.txt');
      s := ParseUri(Request,Uri);
      l.Add(s);

      (*
      l.Add('<html>');
      l.Add('<head></head>');
      l.Add('<body>');
      l.Add('Request Uri: ' + uri);
      l.Add('<br>');
      l.Add('This document is generated by Synapse HTTP server demo!');
      l.Add('</body>');
      l.Add('</html>');
      *)

      l.SaveToStream(OutputData);
      //Dec(fLock);
    finally
      l.free;
    end;
    Result := 200;
  end;
end;



function TTCPHttpThrd.MemoryStreamToString(M: TMemoryStream): string;
begin
  SetString(Result, PAnsiChar(M.Memory), M.Size div SizeOf(AnsiChar));
end;


procedure TTCPHTTPThrd.httpRequest(ALine : string);
var
  method, uri, protocol: string;
  size: integer;
  x, n: integer;
  resultcode: integer;
  s : string;
  timeout: integer;
  close : boolean;
begin
  (*** rozeber HTTP protokol ***)
   s := ALine;
    method := fetch(s, ' ');
    if (s = '') or (method = '') then
      Exit;
    uri := fetch(s, ' ');
    if uri = '' then
      Exit;
    protocol := fetch(s, ' ');
    headers.Clear;
    size := -1;
    close := false;
    //read request headers
    if protocol <> '' then
    begin
      if pos('HTTP/', protocol) <> 1 then
        Exit;
      if pos('HTTP/1.1', protocol) <> 1 then
        close := true;
      repeat
        s := sock.RecvString(Timeout);
        if sock.lasterror <> 0 then
          Exit;
        if s <> '' then
          Headers.add(s);
        if Pos('CONTENT-LENGTH:', Uppercase(s)) = 1 then
          Size := StrToIntDef(SeparateRight(s, ' '), -1);
        if Pos('CONNECTION: CLOSE', Uppercase(s)) = 1 then
          close := true;
      until s = '';
    end;

    //recv document...
    InputData.Clear;
    if size >= 0 then
    begin
      InputData.SetSize(Size);
      x := Sock.RecvBufferEx(InputData.Memory, Size, Timeout);
      InputData.SetSize(x);
      if sock.lasterror <> 0 then
        Exit;
    end;
    OutputData.Clear;

    ResultCode := ProcessHttpRequest(method, uri);

    sock.SendString(protocol + ' ' + IntTostr(ResultCode) + CRLF);
    if protocol <> '' then
    begin
      headers.Add('Content-length: ' + IntTostr(OutputData.Size));
      if close then
        headers.Add('Connection: close');
      headers.Add('Date: ' + Rfc822DateTime(now));
      headers.Add('Server: Synapse HTTP server demo');
      headers.Add('');
      for n := 0 to headers.count - 1 do
        sock.sendstring(headers[n] + CRLF);
    end;
    if sock.lasterror <> 0 then
      Exit;

    Sock.SendBuffer(OutputData.Memory, OutputData.Size);

    (*** rozeber HTTP protokol ****)

end;

procedure TTCPHttpThrd.Execute;
var
  timeout: integer;
  s,sp: string;


  close,res: boolean;
begin
  timeout := 19000;
  flastBeacon := GetTickCount;

  //OutputData.Clear;
  repeat
    s := sock.RecvString(timeout);
    if sock.lasterror <> 0 then
      Continue;
    if s = '' then
     continue   ;

    // vsechno krome CHK

    //{$define TEST}

    {$ifdef TEST}
      if ((pos('CHK',s)>0) or (pos('END',s)>0) or (pos('GST',s)>0) {or (pos('BTN',s)>0)}) then
      begin
       {$ifdef INSPECT} siMain.LogMessage('<<%s',[s]); {$ENDIF}
        sp := 'ACK '+#13+#10;
        if sock.lasterror = 0 then
          sock.SendString(sp);
      end
      else
      begin
        res:= false;
        res := LanPointRequest(s,sp);
        if res then
        begin
          if (sock.lasterror = 0) and (Trim(sp)<>'') then
            sock.SendString(sp);
          //continue;
        end;

      end;
    {$else}

      if (Pos('CHK',s)<=0) and (Pos('GDA',s)<=0) and (Pos('GST',s)<=0) then
       begin
         LogMsg(self,s);
         {$ifdef INSPECT} siMain.LogMessage('<<%s',[s]); {$ENDIF}
       end;

      res := LanPointRequest(s,sp);
      if res and (Trim(sp)<>'') then
      begin
        if sock.lasterror = 0 then
          sock.SendString(sp);
        continue;
      end;

     httpRequest(s);
      if close then
        Break;
    {$endif}

  until Sock.LastError <> 0;
end;


procedure  TTCPHttpThrd.encodePoint(ALine : string; var Result :rLPoint) ;
var ts,td,tt : TStringList;
    year,month,day : integer;
    hh,mm,ss : integer;
    ARChip :rChip;

    key,typ,info    : integer;
    s:      string;
begin
   ts := TStringList.Create;
   StrToStrings(Aline,' ',ts);

   if ts.Count<3 then
     raise Exception.CreateFmt('PES/BTN wrong format: %s',[ALine]);

   if (ts[0]='PES') then
     Result.typ := 1;

   if (ts[0]='BTN') then
     Result.typ :=3;

   if (ts[0]='KEY') then
     Result.typ :=8;

   // nastav cas
   if (ts[0]='GST') then
     Result.typ :=5;

   if (ts[0]='ATV') then
     Result.typ := 100;

   // rozstrotuj datum/cas
   if pos('-',ts[1])<1 then
     raise Exception.CreateFmt('string: %s is not date',[ts[1]]);

   td := TStringList.Create;
   StrToStrings(ts[1],'-',td);

   if not TryStrToInt(td[0],year) then
     raise Exception.CreateFmt('Cannot convert year from: %s',[td[0]]);

   if not TryStrToInt(td[1],month) then
     raise Exception.CreateFmt('Cannot convert month from: %s',[td[1]]);

   if not TryStrToInt(td[2],day) then
     raise Exception.CreateFmt('Cannot convert day from: %s',[td[2]]);

   StrToStrings(ts[2],':',td);
   if not TryStrToInt(td[0],hh) then
     raise Exception.CreateFmt('Cannot convert year from: %s',[td[0]]);

   if not TryStrToInt(td[1],mm) then
     raise Exception.CreateFmt('Cannot convert year from: %s',[td[1]]);

   if not TryStrToInt(td[2],ss) then
     raise Exception.CreateFmt('Cannot convert year from: %s',[td[2]]);

   if not TryEncodeDateTime(year,month,day,hh,mm,ss,0,Result.dt) then
     Result.dt := 0;
   //Result.dt   := EncodeDateTime(year,month,day,hh,mm,ss,0);

   // atv
   if (Result.typ=100) then
   begin
     if not Assigned(fdmd) then
       exit;

     s := ts[3];
     if not TryStrToInt(s,typ) then
         raise Exception.CreateFmt('atv code contains no-numeric char',[ts[3]]);
     Result.typ := typ+100;


     s := ts[4];
     if not TryStrToInt(s,info) then
         raise Exception.CreateFmt('atv code contains no-numeric char',[ts[3]]);
     Result.info := info;
   end;

   // keypad
   if Result.typ=8 then
   begin
     if not Assigned(fdmd) then
       exit;

       s := ts[3];
       if not TryStrToInt(s,key) then
         raise Exception.CreateFmt('keypad code contains no-numeric char',[ts[3]]);

       case key  of
         0..9 :
           fcode := fcode+intToStr(key);
         $C:
           fcode := '';
         $E:
           begin
             Result.ChipName  := fDmd.Engine.EventName(fcode);
             Result.chip      := fcode;
             Result.typ       := 8+32;
             fcode := '';
           end;
       end;

     //ArChip          := fDmd.Engine.Chip(ts[3]);
     //Result.chip     := ts[3];
     //Result.ChipName := ArChip.ChipName;
     //Result.chip     := Archip.Chip;
     //Result.ChipId   := ArChip.Id;
   end;

   if Result.typ=1 then
   begin
     if not TryStrToInt(ts[3],Result.sensorId) then
       Result.sensorId := 0;
     if not Assigned(fdmd) then
       exit;
     Result.SensorName := fDmd.Engine.SensorName(ts[3]);
   end;

   if Result.typ=3 then
   begin
     if not Assigned(fdmd) then
       exit;
     ArChip          := fDmd.Engine.Chip(ts[3]);
     Result.chip     := ts[3];
     Result.ChipName := ArChip.ChipName;
     Result.chip     := Archip.Chip;
     Result.ChipId   := ArChip.Id;
   end;
   FreeAndNil(ts);
   FreeAndNil(td);
end;

procedure TTCPHttpThrd.ClearPoint(var APoint : RLPoint);
begin
  Apoint.typ := 0;
  Apoint.info :=0;
  Apoint.dt:=0;
  APoint.chip :='';
  Apoint.sensorId := 0;
  APoint.SensorName := '';
  APoint.ChipName   :='';
  APoint.ChipId     :=0;
  APoint.IdSyn :=0;
  APoint.Ord := 0;
end;

function TTCPHttpThrd.EvalRoute : boolean;
var  Route : rResult;
     sFmt  : string;
     dt    : TDateTime;
     d     : double;
begin
    if not fDmd.FindRoute then
    begin
     {$ifdef INSPECT}
       SiMain.LogMessage('FindRoute is disabled: exit');
     {$endif}
     exit;
    end;

    // zkus spocitat trasu
    Route := fDmd.Engine.RoutePrep(fkWrite);

    fPoint.typ := 4;
    fPoint.ChipName := Route.RouteName;
    fPoint.chip := '';

    if Route.Miss>0 then
      fPoint.Info:= 4 ;
    if Route.Add>0 then
      fPoint.Info := fPoint.Info+8;

    if Route.TotalPoints=Route.Shot then
      if Route.Score<2*Route.TotalPoints then
        fPoint.info := fPoint.info + 16;

    fBeacon.EventType := eRouteUnknown;
    if Route.TotalPoints<=0 then
      exit;

    d := (Route.Shot/Route.TotalPoints) * 100;
    if d>=40 then // trasa je uznana pokud je umisteno 40% bodu
    begin
      fBeacon.EventType := eRouteFound;
      sFmt :=  format('%s;%d;%d;%d;%s;%s;%s',[fPoint.SensorName,fPoint.SEnsorId,fPoint.typ,fPOint.info,fPoint.ChipName,fPoint.Chip,DateTimeToStr(fPoint.dt)]);
      fDataTs.Add(sFmt);
    end;
    // uloz data do textaku
    {$ifdef INSPECT}
      sFmt := format('Save to %s',[fFileSave]);
      siMain.LogMessage(sFmt);
    {$endif}
end;


procedure TTCPHttpThrd.AddToFile;
var sFmt : string;
begin
  if fDmd.SaveToTxt then
  begin
    // ulozim do textoveho souboru
    sFmt :=  format('%s;%d;%d;%d;%s;%s;%s',[fPoint.SensorName,fPoint.SEnsorId,fPoint.typ,fPOint.info,fPoint.ChipName,fPoint.Chip,DateTimeToStr(fPoint.dt)]);
    fDataTs.Add(sFmt);
  end;
end;


procedure TTCPHttpThrd.ClearBeacon;
begin
  fBeacon.User :='';
  fBeacon.ip   :='';
  fBeacon.localTime := 0;
  fBeacon.EventType := eNone;
  fBeacon.mac  := '';
  fBeacon.clientPort := 0;

  {$ifdef INSPECT}
  //  siMain.logMessage('...ClearBeacon');
  {$endif}
end;


function TTCPHttpThrd.RemoveChar(AChar: Char; AValue : string) : string ;
var i : integer;
begin
  Result := '';
  for I := 1 to Length(AValue) do
     if AValue[i]<>AChar then
       Result:= Result + AValue[i];
end;


procedure TTCPHttpThrd.DoBeacon(ABeacon : RBeacon);
var
  tv : TOmniValue;
  msg : string;
begin
  //   if Assigned(fOnBeat) then
  //        fOnBeat(self,fBeacon);
  tv := TOmniValue.FromRecordUnsafe<RBeacon>(ABeacon);
  if not FDaemonQueue.Enqueue(TOmniMessage.Create(fTagIdx {ignored},tv )) then   // fTagIdx : Celkovy pocet httpThreadu
  begin
    {$IFDEF  INSPECT}
       msg := Format('TTCPHttpThrd.DoBeacon is full devid:%s, ip:%s',[ABeacon.user,ABeacon.ip]);
       SiMain.LogMessage(msg);
    {$endif}
  end;
end;




function TTCPHttpThrd.LanPointRequest(ALine : string; var Respond: string) :boolean;
var
  //l: TStringlist;
  i: integer;
  typ : byte;
  spom,sFmt,ips,mac,s : string;
  d  : double;
  Active : Boolean;
  ts : TStringList;
  diff : DWord;

  // keypad
  // kodovani keypadu
begin
  try
    Result := false;
    Respond:='';
    fBeacon.EventType :=eNone;
    ALine := Trim(ALine);

    {$ifdef INSPECT}
      siMain.LogMessage('LanpointRequest: '+ALine);
    {$endif}

    // HeartBeat GSM-POINTU (zatim zapojeni v desce SIMCOM)
    if Pos('GSM',ALine)>0 then
    begin
      raise Exception.Create('Testovaci vyjimka');
     // Result :=  'GCK '#13#10;
    end;


    // Get Check live, neni proces chciply ?
    // GCL 10.0.0.237
    if Pos('GDA',ALine)>0 then
    begin
      spom := StrAfter('GDA',ALine);
      spom := Trim(spom);

      // je tu mac adresa ?
      mac :='';
      if Pos(':',spom)>0 then
      begin
        ips := StrBefore(' ',spom);
        mac := StrAfter(' ', spom);

        // ano, vyhod ':' a zarad
        mac := RemoveChar(':',mac);
        mac := UpperCase(mac);
      end
      else
        ips := spom;

      fBeacon.EventType := eGuard;
      fBeacon.mac       := mac ;
      fBeacon.localIp   := ips;
      fBeacon.ip        := ips;


//      {$IFDEF  TESTDEL}
        //if Assigned(fOnBeat) then
        //  fOnBeat(self,fBeacon);
      DoBeacon(fBeacon);
//      {$endif}

      // je dpoint nazivu nebo ne ?
      if not Assigned(fOnDpStatus) then
        raise Exception.Create('OnDpStatus not assigned');
      fOnDpStatus(self,ips,mac,Active);
      if Active then
         Respond := 'ACK '#13#10
      else
         Respond := 'NCK '#13#10;
      Result := true;
    end;

    (*
    if POS('RMD',ALine)>0 then
    begin
      Respond := format('RMD %d %d',[307,1]);
      Result := true;
    end;
    *)

    // client se chysta zjistit, ktery blok dat chybi
    if pos('RMD',ALine)>0 then
    begin

      ts := TStringList.Create;
      StrToStrings(ALine,' ',ts);
      if ts.Count>2 then
      begin
        fBeacon.user  := ts[1];
        fBeacon.mac := ts[2];

        // VYZADEJ SI OBJEKT Z POOLU
        if not assigned(fPolo) then
         begin
             {$ifdef INSPECT}
              siMain.LogColored(clGreen,'No object in poool');
             {$endif}
             //Result:=-10;
             Respond := 'ERR '#13#10;
             exit;
         end;
         ob1 := fPolo.Acquire;
         if not assigned(ob1) then
         begin
             {$ifdef INSPECT}
              siMain.LogColored(clGreen,'No object in poool');
             {$endif}
             //Result:=-10;
             Respond := 'ERR '#13#10;
             exit;
         end;

         fDmd := ob1 as TDmd;

         if (fDmd = nil) then
         begin
           Respond := 'ERROR '+#13#10;
           {$IFDEF INSPECT}
             SiMain.LogColored(clRed,'fDmd is NULL');
           {$ENDIF}
           exit;

         end;
         i := fDmd.CheckMissing(ts[1]);
         s := Format('Dira pro adapter %s, id: %d',[s,i]) ;
         Respond := format('RMD %d %d',[i,-1]);
         Respond := Respond +  #13#10;
         {$IFDEF  INSPECT}
         SiMain.LogColored(clRed,ALine+'->'+Respond);
         {$endif}

         {$IFDEF  SERVICE}
          fPolo.Release(ob1);
         {$endif}

      end
      else
      begin
        // zadna dira
        Respond := format('RMD %d %d',[-1,-1]);
        Respond := Respond +  #13#10;
       {$IFDEF  INSPECT}
        SiMain.LogColored(clTeal,ALine+'->'+Respond);
       {$endif}
      end;
      Result := True;

      FreeAndNil(ts);

      //s := 'D4028C04';
      //i := fDmd.CheckMissing('D4028C04');
      //s := Format('Dira pro adapter %s, id: %d',[s,i]) ;
    end;


    // HeartBeat LANPOINTU
    if Pos('GST',ALine)>0 then
    begin
      //Result := 'GST '#13#10;
      //spom := StrAfter('GST',ALine);
      //ts := TStringList.Create;
      //StrToStrings(spom,'-',ts);
      encodePoint(ALine,fPoint);  // text na fPoint

      if (Abs(now-fPoint.dt) < 1/24/6) then // akceptovatelnych je 10 minut
      begin
        Respond := 'ACK '#13#10;
      end
      else
        Respond := 'SST '+FormatDateTime('yyyy-mm-dd hh:nn:ss',now)+#13#10;
      // Result := 'ACK '#13#10;
      Result := true;

      Inc(fTestujMissing);
    end;

    // HeartBeat LANPOINTU
    if Pos('CHK',ALine)>0 then
    begin
      // je za CHK mac adresa ?
      Respond := 'ACK '#13#10;

      (*** odesli beacon ***)
      ClearBeacon;
      fBeacon.EventType  := eChck;
      fBeacon.ip         := Sock.GetRemoteSinIP;
      fBeacon.clientPort := Sock.GetRemoteSinPort;
      fBeacon.TagIdx     := fTagIdx;

      // je tu mac adresa a nazev d-pointu ?
      ts := TStringList.Create;
      StrToStrings(ALine,' ',ts);
      if ts.Count>2 then
      begin
        fBeacon.mac  := ts[1];
        fBeacon.User := ts[2];
      end;
      FreeAndNil(ts);

     // fBeacon.User :=     Sock.
     // if Assigned(fOnBeat) then
     //   fOnBeat(self,fBeacon);

   //  {$IFDEF  TESTDEL}
       diff := GetTickCount-fLastBeacon;
   //    if (diff>1000) then
       begin
        // Synchronize(DoBeacon);
         DoBeacon(fBeacon);
         Result := true;
         fLastBeacon := GetTickCount;
       end;
   //  {$endif}
    end;

    if Trim(ALine)='END' then
    begin
      {$ifdef INSPECT}
        spom := format('!   Transfer: [%s] %s  usr:%s sensor:%d[%s] Cnt:%d',[fBeacon.mac,DateTimeToStr(Now), fBeacon.User,fBeacon.SensorId,fbeacon.SensorName,fBeacon.PointCount]);
        siMain.logColored(clGreen,spom);
      {$endif}

      if fPoint.Ord>0 then
      begin
        EvalRoute;
        if fDmd.SaveToTxt then
        begin
          fDataTs.SaveToFile(fFileSave);
          FreeAndNil(fDataTs);
        end;
      end;

      {$IFDEF  SERVICE}
        fPolo.Release(ob1);
      {$endif}

      if fBeacon.PointCount>0 then
        Respond := 'ACK '#13#10;

      FreeAndNil(fkWrite);

      // beacon jde primarne do formy
      fBeacon.EventType := eEndTransfer;
      DoBeacon(fBeacon);
      //if Assigned(fOnBeat) then
      //  fOnBeat(self,fBeacon);


      Result := true;
    end;
    // zpracovani dat
    typ := 0;

     // je to zacatek novych dat ?
    if Pos('USR',ALine) >0 then
    begin
       // ukladani do
       fDataTs := TstringList.Create;
       ClearPoint(fPoint);

       {$IFDEF SERVICE}
         // vyzadej si objekt z poolu
         if not assigned(fPolo) then
         begin
             {$ifdef INSPECT}
              siMain.LogColored(clGreen,'No object in poool');
             {$endif}
             //Result:=-10;
             Respond := 'ERR '#13#10;
             exit;
         end;
         ob1 := fPolo.Acquire;
         if not assigned(ob1) then
         begin
             {$ifdef INSPECT}
              siMain.LogColored(clGreen,'No object in poool');
             {$endif}
             //Result:=-10;
             Respond := 'ERR '#13#10;
             exit;
         end;

         fDmd := ob1 as TDmd;
         if fdmd=nil then
         exit;
       {$endif}

       {$IFNDEF ABS}
       fDmd.LoadTables('');
       {$endif}
       fTextPath := fDmd.TextPath;

       // vynuluj tabulku bodu
       typ := 1;
       CreateTableFmt;
       // zaloz nove cislo synchronizace
       {$ifdef MSQL}
         fIdSyn   := fDmd.MasterSynPP(10);
         //fIdSyn   := fDmd.MaxId;
         //Inc(fIdSyn);
       {$endif}

       fPoint.IdSyn := fIdSyn;
       fPoint.DownloadTime := now;
       fPOint.Ord  := 0;
       fPoint.PointCount := 0;
       fPoint.User := '?';

       fBeacon.PointCount := 0;
       StrToStrings(ALine,' ',fDataTs);
       if fDataTs.Count>1 then
       begin
         fPoint.User := fDataTs[1];

         (***ODESLI BEACON ****)
         fBeacon.EventType := eLanName;
         fBeacon.User := fDataTs[1];
         fBeacon.ip   := Sock.GetRemoteSinIP;
         if fDataTs.Count>2 then
           fBeacon.mac := fDataTs[2];

         // if Assigned(fOnBeat) then
         //   fOnBeat(self,fBeacon);
         DoBeacon(fBeacon);
       end;
       fDataTs.Clear;
       Respond := 'ACK '#13#10;
       Result := true;
    end;

    if pos('IDS',ALine)>0 then
    begin
       ts:= TStringList.Create;
       StrToStrings(ALine,' ',ts);
       if ts.Count>1 then
       begin
         //fBeacon.mac  := ts[1];
         //fBeacon.User := ts[2];
         spom := ts[1] ;
         if not TryStrToInt(spom,fPoint.RpSyn) then
           fPoint.RpSyn := 0;

         spom := ts[2];
         fPoint.mac := spom;
       end;
       FreeAndNil(ts);

       //spom := StrAfter(' ',ALine);
       //fPoint.rpSyn := spom.ToInteger;
    end;

    if POS('PES',ALine)>0 then
    begin
       typ :=  1;
       encodePoint(ALine,fPoint);  // z textu preved na fPoint
       fFileSave  := fTextPath+'\'+formatDateTime('dd_mm_yyyy_hh_nn',now)+'_'+IntToStr(fPoint.SensorId)+'.txt';

       fBeacon.SensorId   := fPoint.sensorId;
       fBeacon.SensorName := fPoint.SensorName;
       Respond := #13#10;
       Result  := true;
    end;

    if pos('KEY',ALine)>0 then
    begin
       typ := 8;
       encodePoint(ALine,fPoint);
       if fPoint.typ=40 then
       begin
         fPoint.typ := 8;
         fPoint.ChipName := fDmd.Engine.EventName(fPoint.Chip);
         {$ifdef MSQL}
         fDmd.AddPoint(fPoint);
         {$endif}
         fCode := '';
       end;
       Result := true;
    end;

    if pos('ATV',ALine)>0 then
    begin
       encodePoint(ALine,fPoint);
       if fPoint.typ>0 then
       begin
         //fPoint.typ := 8;
         //fPoint.ChipName := fDmd.Engine.EventName(fPoint.Chip);

         fPoint.ChipName := fdmd.Engine.avtName(fpoint.typ);
         {$ifdef MSQL}
         fDmd.AddPoint(fPoint);
         {$endif}
         fCode := '';
       end;
       Result := true;
    end;


    (*** zpracovani nalezeneho buttonu ***)
    if Pos('BTN',ALine)>0 then
    begin
       Result := true;
       // uloz eventuelni keypad
       if fCode<>'' then
       begin
         fPoint.typ := 8;
         fPoint.ChipName := fDmd.Engine.EventName(fCode);
         //if not TryStrToInt(fCode,fPoint.ChipId) then
         //  fPoint.ChipId := -1;
         fPoint.chip  := fCode;

         {$ifdef MSQL}
         fDmd.AddPoint(fPoint);
         {$endif}

         fCode := '';
       end;
       typ :=  3;
       encodePoint(ALine,fPoint);  // text na fPoint

       if fDmd=nil then
         exit;

       // je to straznik ?
       if fDmd.Engine.Guard.locate('CHIP',fPoint.Chip,[]) then
       begin
         // urcim trasu, ulozim a uklidim fts
         EvalRoute;  // do urceni trasy vstupuje fkWrite
 //        if Assigned(fOnBeat) then
 //          fOnBeat(self,fBeacon);
         DoBeacon(fBeacon);
         encodePoint(ALine,fPoint);
         fPoint.typ := 2;
         fPoint.ChipName:= fDmd.Engine.Guard.fieldbyName('name').asString;

         // mam tu hook od databaze ?
         {$ifdef MSQL}
         fDmd.AddPoint(fPoint);
         {$endif}

         fkWrite.EmptyTable;
         // Inc(fPoint.Ord);
         fPoint.Ord := 0;
       end
       else
       begin
         Inc(fPoint.Ord);
         //////  jenom propsane chipy muzou do databaze a urceni trasy
         // if (fPoint.ChipId<=0) then
         //   exit;

         // uloz bod do databaze
         {$ifdef MSQL}
         fDmd.AddPoint(fPoint);
         {$endif}
         Append(fPoint);
         // sFmt :=  format('%s;%d;%d;%d;%s;%s;%s',[fPoint.SensorName,fPoint.SEnsorId,fPoint.typ,fPOint.info,fPoint.ChipName,fPoint.Chip,DateTimeToStr(fPoint.dt)]);
         //fTs.Add(sFmt);
       end;
       Inc(fPoint.PointCount);
       Inc(fBeacon.PointCount);
       Synchronize(AddToFile);  // pridej do textoveho souboru
    end;

  except
    // pokud nastane pruser, vrat objekt do poolu
    if Assigned(ob1) then
      fPolo.Release(ob1);
  end;
end;


procedure TTCPHttpThrd.Append(APoint : RLPoint);
begin
  // pridej bod do tabulky pro vypocet trasy
  fkWrite.Append;
  fkWrite.FieldByName('ChipName').AsString   := APoint.ChipName;
  fkWrite.FieldByName('Point').AsINteger     := APoint.ChipId;
  fkWrite.FieldByName('Chip').AsString       := APoint.chip;
  fkWrite.FieldByName('SensorId').AsINteger  := APoint.sensorId;
  fkWrite.FieldByName('SensorName').AsString := APoint.SensorName;
  fkWrite.FieldByName('Touch').AsDAteTime := APoint.dt;
  fkWrite.Post;
end;

procedure TTCPHttpThrd.CreateTableFmt;
begin
  fkWrite := TkbmMemTable.Create(nil);
  with fkWrite.FieldDefs do
  begin
     Clear;
     Add('Pit'         , ftAutoinc , 0 ,false);
     Add('SensorName'  , ftString  , 40, false);
     Add('SensorId'    , ftString , 10,false);
     Add('typ'         , ftInteger , 0 ,false);
     Add('IsRoute'     , ftInteger , 0 ,false);

     Add('Point'       , ftInteger , 0 ,false);
     Add('ChipName'    , ftString,  40, false);
     Add('Chip'        , ftString,  10, false);
     Add('Touch'       , ftDateTime, 0 ,false);
     Add('FirstPoint'  , ftBoolean, 0, False);

  end;
  fkWrite.CreateTable;
  fkWrite.Open;
end;

(*
procedure TTCPHttpThrd.CreateSerie;
begin
  fkSerial := TkbmMemTable.Create(nil);
  with fkSerial.fieldDefs do
  begin
    Clear;
    Add('Point'         , ftInteger , 0 ,false);
  end;
end;
*)


end.
