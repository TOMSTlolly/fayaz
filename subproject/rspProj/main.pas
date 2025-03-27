unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdContext, Vcl.StdCtrls,
  inifiles, jclSysInfo, jclStrings,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdTCPServer, Vcl.ExtCtrls,
  IdTCPConnection, IdTCPClient, Vcl.WinXPickers;

type
  TForm1 = class(TForm)
    mem: TMemo;
    botPANEL: TPanel;
    edPORT: TEdit;
    Label1: TLabel;
    listBox: TListBox;
    idTcpClient: TIdTCPClient;
    btPUT: TButton;
    tim: TTimer;
    btTimer: TButton;
    btChk: TButton;
    btChk2: TButton;
    edServer: TEdit;
    SRV: TLabel;
    btStart: TButton;
    datePick: TDatePicker;
    procedure idTcpExecute(AContext: TIdContext);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btStartClick(Sender: TObject);
    procedure btPUTClick(Sender: TObject);
    procedure btTimerClick(Sender: TObject);
    procedure timTimer(Sender: TObject);
    procedure btChkClick(Sender: TObject);
    procedure listBoxClick(Sender: TObject);
    procedure btChk2Click(Sender: TObject);
  private
    { Private declarations }
    fTerminated : boolean;
    fIniFile : TInifile;
    fDlfName : string;
    fPort    : integer;
    fServer,fMac,fUser  : string;
    procedure loadIniFile(AFileName: string);
    procedure touch(AFileName: string);
    function BoolToStr(AValue: Boolean): string;
    procedure SendHeartBeat(AChk: string);
    procedure PutFile(AFileName: string);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}



procedure TForm1.touch(AFileName : string);
var
  Flags : Word;
  FS    : TFileStream;
  sOut  : string;
begin

  Flags := fmOpenReadWrite;
  if not FileExists(AFileName) then
    Flags := Flags or fmCreate;
  FS := TFileStream.Create(AFileName, Flags);
  sOut := ';This is test line'#13#10;
  FS.Write(sOut[1], Length(sOut) * SizeOf(Char));
  FS.Free;
end;




procedure TForm1.loadIniFile(AFileName : string);
begin
  if not FileExists(AFileName) then
    Touch(AFileName);



  fIniFile := TInifile.Create(AFileName);
  fPort    := fIniFile.ReadInteger('SERVER','PORT',8080);
  fServer  := fIniFile.ReadString('SERVER','IP','127.0.0.1') ;
  fMac     := fIniFile.ReadString('SERVER','MAC','B827EB269C76');
  fUser    := fIniFile.ReadString('SERVER','USER','RP0') ;
end;


procedure TForm1.SendHeartBeat(AChk : string);
  var s: string;
    j : integer;
begin
    idTcpClient.Port := StrToInt(edPort.Text);
    idTcpClient.Host := edServer.Text;

    try
      if not Assigned(idTcpClient.IOHandler) then
        idTcpClient.Connect;

      idTcpClient.IOHandler.Open;
      //s := 'CHK '#13#10;
      s := AChk;

      idTcpClient.Socket.WriteLn(s);
      s := idTcpClient.Socket.ReadLn;
      j := pos(#13#10,s);
      if j>0 then
         delete(s,length(s)-2,2);
      if s<>'' then
         mem.Lines.Add('<<'+s);
    except
      on E: Exception  do
        mem.Lines.Add ('No connection');

    end;
end;

procedure TForm1.btChk2Click(Sender: TObject);
var s : string;
begin
  s := Format('CHK %s %s',[fMac,fUser]);
  SendHeartBeat(s+#13#10);
end;

procedure TForm1.btChkClick(Sender: TObject);
begin
  SendHeartBeat('CHK '#13#10);
end;


procedure TForm1.btPUTClick(Sender: TObject);
begin
   //btPUT.Tag := 1 - btPUT.Tag;
   btPUT.Enabled := false;
   try
     PutFile(fDlfName+'txt.txt');
   finally
     btPUT.Enabled := True;
   end;
end;

procedure TForm1.timTimer(Sender: TObject);
var s: string;
begin
    s := Format('CHK %s %s',[fMac,fUser]);
    SendHeartBeat(s+#13#10);
  //SendHeartBeat('CHK '#13#10);
end;


procedure TForm1.PutFile(AFileName : string);
var tip,tok : TStringList;
      i,j : integer;
      s ,ss: string;
      sLine,line : string;
      btn,sdTime  : string;
      dStart : TDateTime;
begin
  try
    tim.Enabled:=False;



    tip := TStringList.Create;
    tip.LoadFromFile(AFileName);

    // ted to odeslu radek po radek
    idTcpClient.Port := StrToInt(edPort.Text);
    idTcpClient.Host := fServer;

    if not Assigned(idTcpClient.IOHandler) then
      idTcpClient.Connect;
    idTcpClient.IOHandler.Open;

    // chci se vyhnout duplicitam v case

    for i := 0 to tip.Count-1 do
    begin
     if fTerminated  then
     begin
       exit;
     end;

     sLine := tip[i];
     StrReplace(sLine,'<<','',[rfReplaceAll]);

     // reakci ocekavam, jenom kdyz je CHCK
     if Pos('CHK',sLine)>0 then
     begin
       // vymen mac adresu za nastavenou z ini souboru
       tok := TStringList.Create;
       StrToStrings(sLine,' ',tok);
       if tok.Count>=2 then
       begin
         tok[1] := fMac;
         tok[2] := fUser;
         s:= StringsToStr(tok,' ');
       end;
       FreeAndNil(tok);
       idTcpClient.Socket.WriteLn(s);
       mem.Lines.Add('>>'+s);

       // vymaz konec radku
       s := idTcpClient.Socket.ReadLn(#13#10,100,-1,nil);
       j := pos(#13#10,s);
       if j>0 then
         delete(s,length(s)-2,2);
       if s<>'' then
         mem.Lines.Add('<<'+s);
     end
     else if (pos('BTN',sLine)>0) then
     begin
       (*
       dStart := now-Trunc(now);  // ciste hh:nn:ss
       dStart := dStart - Trunc(dStart);
       dStart := Trunc(datePick.date)+dStart;

       tok := TStringList.Create;
       StrToSTrings(s,' ',tok);
       btn := tok[3];
       sdTime := formatDateTime('yyyy-mm-dd hh:nn:ss',dStart);
       sleep(500);

       line   := format('BTN %s %s',[sdTime,btn]);
       *)
       sline   := sline + #13#10;
       idTcpClient.Socket.WriteLn(sline);
       mem.Lines.Add('>>'+sline);
       sleep(10);
     end
     else
     begin

       idTcpClient.Socket.WriteLn(sLine);
       mem.Lines.Add('>>'+sLine);
     end;

    end;
  finally
    if idTcpClient.IOHandler <> nil then
      if idTcpClient.IOHandler.Connected then
        idTcpClient.IOHandler.CloseGracefully;

    FreeAndNil(tip);
    tim.Enabled := true;
    Application.ProcessMessages;
  end;

end;


procedure TForm1.FormCreate(Sender: TObject);
var tip,tma: TSTringList;
    ips,mac : string;
    i   : integer;
    ob  : TObject;
begin
  fDlfName := ExtractFilePath(ParamStr(0));
  loadIniFile(fDlfName+'cticom.ini');
  edPort.Text := IntToStr(fPort);
  edServer.Text := fServer;

 // ips := GetIPAddress('localhost');
  listBox.Items.Clear;
  tip := TStringList.Create;
  GetIpAddresses(tip);

  datePick.Date := now - 31;

  (*
  for i := 0 to tip.Count-1 do
  begin
    ips := tip[i];
    tma := TStringList.Create;
    GetMacAddresses(ips,tma);


    //listBox.Items.AddStrings(line);
    listBox.Items.AddObject(mac+tma[0],TObject(mac));
    FreeAndNil(tma);
  end;
  *)
  listBox.Items.AddStrings(tip);

  (*
  // nastav TCP/IP server
  idTcp.Active:= false;
  idTCP.DefaultPort := fPort;
  idTcp.Active:=true;
  *)
end;


procedure TForm1.listBoxClick(Sender: TObject);
var ip,line : string;
    tma: TStringList;
begin
  //
  if listBox.Items.Count<0 then
    exit;

  ip := listBox.Items[listBox.ItemIndex];
  if Pos('/',ip)>0 then
  begin
    ip := StrBefore('/',ip);
    exit;
  end;

  tim.Enabled := false;

  tma := TStringList.Create;
  GetMacAddresses(ip,tma);

  // predelej radek
  line := ip + '/' + tma[0];
  listBox.Items[listBox.ItemIndex] := line;

  FreeAndNil(tma);
  Tim.Enabled:= true;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  fIniFile.WriteInteger('SERVER','PORT',fPort);
  fIniFile.UpdateFile;
  fIniFile.Free;
end;



procedure TForm1.btStartClick(Sender: TObject);
var tip : TStringList;
    i   : integer;
begin
  btStart.Tag :=  1 -btStart.Tag;
  fPort := StrToInt(edPort.Text);

  // aktivace
  if btStart.Tag=1 then
  begin
    btStart.Caption := 'Started !';
    edPort.Enabled:= false;
    fTerminated := false;
  end
  else
  begin
    btStart.Caption := 'DISABLED';
    edPort.Enabled:= true;
    fTerminated := true;
  end;

  if btStart.Tag=0then
    exit;

  for i := 0 to 100 do
  begin
   PutFile( fDlfName+'test.txt' );
   Sleep(500);
  end;


end;

function TForm1.BoolToStr(AValue : Boolean): string;
begin
  if AValue then Result := 'Enabled'
  else           Result := 'Disabled';
end;


procedure TForm1.btTimerClick(Sender: TObject);
begin
 btTimer.Tag     := 1 - btTimer.Tag;
 tim.Enabled     := btTimer.Tag=1 ;
 btTimer.Caption := 'Tim '+BoolToStr(tim.Enabled);
end;

procedure TForm1.idTcpExecute(AContext: TIdContext);
var s : string;
begin
  //
 // s := string(AContext.data);

  with AContext.Connection do
  begin
     s:=IOHandler.ReadLn;
     mem.Lines.Add(s);

     // vracime to same
     if s='CHK ' then
       IOHandler.WriteLn('ACK '+#13+#10);

     if pos('END',s)>0 then
       IOHandler.WriteLn('ACK '+#13+#10);
  end;

end;

end.
