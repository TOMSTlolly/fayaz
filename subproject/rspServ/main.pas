unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdContext, IdBaseComponent, IdComponent,
  IdCustomTCPServer, IdTCPServer, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    idTcpSrv: TIdTCPServer;
    Mem: TMemo;
    procedure idTcpSrvExecute(AContext: TIdContext);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.idTcpSrvExecute(AContext: TIdContext);
var s,ip : string;
begin
  IP := AContext.Connection.Socket.Binding.PeerIP;
  mem.Lines.Add('ip '+ip) ;

  with AContext.Connection do
  begin

     s:=IOHandler.ReadLn;
     mem.Lines.Add(s);

     // vracime to same
     if pos('CHK',s)>0 then
       IOHandler.WriteLn('ACK '+#13+#10);

     if pos('END',s)>0 then
       IOHandler.WriteLn('ACK '+#13+#10);

     if pos('GST',s)>0 then
       IOHandler.WriteLn('ACK '+#13+#10);

     if pos('RMD',s)>0 then
       IOHandler.WriteLn('ACK '+#13+#10);

  end;

end;

end.
