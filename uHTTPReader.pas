unit uHTTPReader;

interface

uses
  Classes, IdHTTP;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
type
  tHTTPReaderThread = class(TThread)
  private
    fHTTP      : TIdHTTP;
    fURL       : string;
    fRunning   : Boolean;
    fFrequency : Cardinal;
    fOutput    : string;
    procedure SetFrequency( Value : Cardinal );
    procedure OutputText;
  protected
    procedure   Execute; override;
  public
    constructor Create( CreateSuspended : boolean = false ); reintroduce;
    destructor  Destroy; override;

    property    URL       : string   read fURL       write fURL;
    property    Running   : boolean  read fRunning   write fRunning;
    property    Frequency : Cardinal read fFrequency write SetFrequency;
  end;

var
  HTTPReaderThread : tHTTPReaderThread;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

implementation

uses
  Windows,
  uTest;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
constructor tHTTPReaderThread.Create( CreateSuspended : boolean = false );
begin
  fURL     := '';
  fRunning := false;
  fOutput  := '';
  fFrequency := 250;

  inherited;
  fHTTP := TIdHTTP.Create;
  fHTTP.ConnectTimeout := 500;
end;

destructor tHTTPReaderThread.Destroy;
begin
  fHTTP.free;
  inherited;
end;

procedure tHTTPReaderThread.Execute;
var
  S : string;
begin
  while NOT Terminated do
    begin
    if NOT fRunning OR ( fURL = '' ) then
      begin
      Sleep( 500 );
      Continue;
      end;

    try
      S := fHTTP.Get( fURL  );
    except
      S := '';
    end;

    if ( s <> '' ) then
      begin
      fOutput := s;
      Synchronize( OutputText );
      end;
    Sleep( fFrequency );
    end;
end;

procedure tHTTPReaderThread.SetFrequency( Value : Cardinal );
begin
  if NOT Assigned( self ) then
    Exit;
  if ( fFrequency = Value ) then
    Exit;
  if ( fFrequency < 1 ) OR ( fFrequency > 5*60000 ) then
    Exit;
  fFrequency := Value;
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
procedure tHTTPReaderThread.OutputText; // Synchronized since its probably accessing VCL ..
begin
  Form1.Memo1.Lines.Add( fOutput );
  fOutput := '';
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
procedure TerminateAndFree;
begin
  if NOT Assigned( HTTPReaderThread ) then
    Exit;
  if NOT HTTPReaderThread.Terminated then
    begin
    HTTPReaderThread.Terminate;
    while NOT HTTPReaderThread.Terminated do
      Sleep( 10 );
    HTTPReaderThread.free;
    end;
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

initialization
  HTTPReaderThread := tHTTPReaderThread.Create( false );

finalization
  TerminateAndFree;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

end.
