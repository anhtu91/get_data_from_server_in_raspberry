unit uTest;

interface

uses
  Classes, Controls, Forms,
  StdCtrls;

type
    TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

uses
  uHTTPReader, SysUtils;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  try
    HTTPReaderThread.URL := 'http://192.168.11.122:8080';
    HTTPReaderThread.Running := True;
  except
    
  end;
end;

end.
